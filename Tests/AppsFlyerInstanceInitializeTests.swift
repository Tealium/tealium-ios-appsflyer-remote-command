//
//  AppsFlyerInstanceInitializeTests.swift
//  TealiumAppsFlyerTests
//
//  Created by Sebastian Krajna on 5/21/26.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest
@testable import TealiumAppsFlyer
import AppsFlyerLib

/// Exercises the real `AppsFlyerInstance` body against the
/// `AppsFlyerLib.shared()` singleton. Mock-based coverage in
/// `AppsFlyerRemoteCommandTests` only verifies the payload-to-command
/// dispatch — these tests verify the settings-to-SDK property mapping,
/// the Facebook Deferred AppLinks fallback and the `isStopped` handling
/// that live inside the real implementation.
class AppsFlyerInstanceInitializeTests: XCTestCase {

    var spyLogHandler: MockLogHandler!
    var instance: AppsFlyerInstance!

    override func setUp() {
        super.setUp()
        spyLogHandler = MockLogHandler()
        let logger = RemoteCommandLogger(logLevel: .debug, handler: spyLogHandler)
        instance = AppsFlyerInstance(logger: logger)
        // Reset shared singleton state to keep tests isolated. `appsFlyerDevKey`/`appleAppID` are
        // read-only in SDK 7 (set only via `initialize(devKey:appId:)`), so they are not reset here
        // — every test calls `instance.initialize` with its own values, which overwrites them.
        let lib = AppsFlyerLib.shared()
        lib.isDebug = false
        lib.anonymizeUser = false
        lib.disableAdvertisingIdentifier = false
        lib.disableIDFVCollection = false
        lib.deepLinkTimeout = 0
        lib.oneLinkCustomDomains = []
        lib.disableSKAdNetwork = false
        lib.disableAppleAdsAttribution = false
        lib.shouldCollectDeviceName = false
        lib.minTimeBetweenSessions = 0
        lib.customData = nil
        lib.facebookDeferredAppLink = nil
        // Left set, this would make the session-ready listener registered by every later
        // `initialize` skip its `start()` call.
        lib.isStopped = false
        lib.unregisterSessionReadyListener()
    }

    /// Every `initialize` call registers a session-ready listener on the shared singleton. Left in
    /// place it can fire during an unrelated later test, calling `start()` and publishing `onReady`
    /// mid-test.
    override func tearDown() {
        AppsFlyerLib.shared().unregisterSessionReadyListener()
        super.tearDown()
    }

    /// Asserts on the configuration the SDK actually uses, instead of on the public getter.
    ///
    /// SDK 7 moved configuration into an internal `AppsFlyerLibConfig` object (the `sdkConfig`
    /// property) and repointed the setters at it, but left the getters for `isDebug`,
    /// `disableSKAdNetwork` and `disableIDFVCollection` reading the now-unused legacy ivars
    /// (`_isDebug` and friends). Those getters therefore return the default value forever,
    /// whatever was assigned — so asserting through them cannot verify our mapping.
    /// The setters themselves work, so runtime behaviour is correct; only the read-back is broken.
    /// Confirmed on both 7.0.1 and 7.0.2 by reading the legacy ivar (stays `false`) and
    /// `sdkConfig` (holds the assigned value) side by side.
    ///
    /// `disableAdvertisingIdentifier` and `disableAppleAdsAttribution` are unaffected — their
    /// getters forward correctly — so those keep using the public API.
    ///
    /// Reaching into `sdkConfig` via KVC is deliberate but fragile: if AppsFlyer renames these
    /// internals the guard below fails the test with an explanatory message rather than crashing.
    /// The key's existence is checked with the runtime before `value(forKey:)` reads it, because
    /// KVC raises an `NSUnknownKeyException` on an unknown key and Swift cannot catch that — it
    /// would abort the whole test bundle instead of failing this assertion.
    /// Switch back to the public getters once the getters are fixed upstream.
    ///
    /// Reported to AppsFlyer: https://github.com/AppsFlyerSDK/AppsFlyerFramework/issues/334
    private func assertEffectiveConfigFlag(_ key: String,
                                           _ expected: Bool,
                                           file: StaticString = #filePath,
                                           line: UInt = #line) {
        guard class_getInstanceVariable(AppsFlyerLib.self, "_sdkConfig") != nil,
              let config = AppsFlyerLib.shared().value(forKey: "sdkConfig") as AnyObject?,
              class_getProperty(type(of: config), key) != nil
                || class_getInstanceVariable(type(of: config), "_" + key) != nil,
              let actual = config.value(forKey: key) as? Bool else {
            return XCTFail("Could not read `sdkConfig.\(key)`. AppsFlyer SDK internals changed — "
                           + "recheck whether the public getter works again.",
                           file: file, line: line)
        }
        XCTAssertEqual(actual, expected, "sdkConfig.\(key)", file: file, line: line)
    }

    func testInitializeAppliesCredentials() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
        XCTAssertEqual(AppsFlyerLib.shared().appsFlyerDevKey, "test_dev_key")
        XCTAssertEqual(AppsFlyerLib.shared().appleAppID, "test_app_id")
    }

    func testInitializeAppliesMinTimeBetweenSessions() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["time_between_sessions": 60])
        XCTAssertEqual(AppsFlyerLib.shared().minTimeBetweenSessions, 60)
    }

    /// The SDK property is `UInt`, so converting a negative value would trap.
    func testInitializeIgnoresNegativeMinTimeBetweenSessions() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["time_between_sessions": -1])
        XCTAssertEqual(AppsFlyerLib.shared().minTimeBetweenSessions, 0)
    }

    func testInitializeIgnoresNegativeDeepLinkTimeout() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["deep_link_timeout": -1])
        XCTAssertEqual(AppsFlyerLib.shared().deepLinkTimeout, 0)
    }

    func testInitializeAppliesAppleSettings() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: [
            "disable_apple_ad_tracking": true,
            "disable_apple_ads_attribution": true
        ])
        assertEffectiveConfigFlag("disableSkAdNetwork", true)
        XCTAssertTrue(AppsFlyerLib.shared().disableAppleAdsAttribution)
    }

    func testInitializeAppliesCollectDeviceName() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["collect_device_name": true])
        XCTAssertTrue(AppsFlyerLib.shared().shouldCollectDeviceName)
    }

    func testInitializeAppliesCustomData() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: [
            "custom_data": ["custom_key": "custom_value"]
        ])
        XCTAssertEqual(AppsFlyerLib.shared().customData?["custom_key"] as? String, "custom_value")
    }

    func testInitializeAppliesFacebookDeferredAppLink() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: [
            "facebook_deferred_app_link": "https://example.com/deferred"
        ])
        XCTAssertEqual(AppsFlyerLib.shared().facebookDeferredAppLink?.absoluteString,
                       "https://example.com/deferred")
    }

    /// These have no readable SDK property, so the assertion is that the branches run
    /// and apply cleanly rather than what they set.
    func testInitializeAcceptsSettingsWithoutReadableState() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: [
            "enable_tcf_data_collection": true,
            "push_notification_deep_link_path": ["af_push_link"],
            "deep_link_parameters": [
                ["contains": "onelink.me", "parameters": ["utm_source": "appsflyer"]]
            ]
        ])
        XCTAssertEqual(AppsFlyerLib.shared().appsFlyerDevKey, "test_dev_key")
        XCTAssertEqual(spyLogHandler.messages(for: .error), [])
    }

    func testInitializeAppliesDebugSetting() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["debug": true])
        assertEffectiveConfigFlag("isDebug", true)
    }

    func testInitializeAppliesAnonymizeUser() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["anonymize_user": true])
        XCTAssertTrue(AppsFlyerLib.shared().anonymizeUser)
    }

    func testInitializeAppliesDeepLinkTimeout() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["deep_link_timeout": 5000])
        XCTAssertEqual(AppsFlyerLib.shared().deepLinkTimeout, 5000)
    }

    func testInitializeAppliesOneLinkCustomDomains() {
        let domains = ["a.example.com", "b.example.com"]
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["one_link_custom_domains": domains])
        XCTAssertEqual(AppsFlyerLib.shared().oneLinkCustomDomains ?? [], domains)
    }

    /// Facebook Deferred AppLinks fallback: when the Facebook SDK class is not linked, the code
    /// path must surface an error log instead of crashing.
    func testInitializeLogsErrorWhenFacebookSDKMissing() {
        instance.initialize(
            appId: "test_app_id",
            appDevKey: "test_dev_key",
            settings: ["enable_facebook_deferred_applinks": true]
        )
        XCTAssertTrue(spyLogHandler.messages(for: .error).contains { $0.contains("Facebook SDK not found") },
                      "Expected error log when FBSDKAppLinkUtility class is unavailable")
    }

    /// Disabling the Facebook flag must take the `else` branch and not log an error.
    func testInitializeDoesNotLogWhenFacebookFlagDisabled() {
        instance.initialize(
            appId: "test_app_id",
            appDevKey: "test_dev_key",
            settings: ["enable_facebook_deferred_applinks": false]
        )
        XCTAssertEqual(spyLogHandler.messages(for: .error), [])
    }

    /// Android cross-platform alias maps to the same two SDK properties as the iOS key.
    func testInitializeAcceptsDisableAdvertisingIdentifiersAlias() {
        instance.initialize(
            appId: "test_app_id",
            appDevKey: "test_dev_key",
            settings: ["disable_advertising_identifiers": true]
        )
        XCTAssertTrue(AppsFlyerLib.shared().disableAdvertisingIdentifier)
        assertEffectiveConfigFlag("disableIdfvCollection", true)
    }

    /// `disable_idfv_collection` is applied after `disable_ad_tracking` so it can override the
    /// IDFV portion independently. The IDFV assertion has to go through `sdkConfig`: the public
    /// getter returns `false` unconditionally, which made this test pass vacuously — it would have
    /// held even if the override had never been applied.
    func testInitializeDisableIDFVCollectionOverridesAfterDisableAdTracking() {
        instance.initialize(
            appId: "test_app_id",
            appDevKey: "test_dev_key",
            settings: [
                "disable_ad_tracking": true,
                "disable_idfv_collection": false
            ]
        )
        XCTAssertTrue(AppsFlyerLib.shared().disableAdvertisingIdentifier)
        assertEffectiveConfigFlag("disableIdfvCollection", false)
    }

    /// The SDK ignores `start` while `isStopped` is set, so a tag mapping `resume_tracking` to
    /// `start` alone silently resumes nothing. The warning is the only signal an integrator gets.
    func testStartWarnsWhileTrackingStopped() {
        AppsFlyerLib.shared().isStopped = true

        instance.start()

        XCTAssertTrue(spyLogHandler.messages(for: .warning).contains { $0.contains("stop_tracking: false") },
                      "Expected a warning naming the parameter that clears the stop flag")
    }

    func testStartDoesNotWarnWhileTrackingActive() {
        instance.start()

        XCTAssertEqual(spyLogHandler.messages(for: .warning), [])
    }

}

