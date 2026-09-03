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

/// Exercises the real `AppsFlyerInstance.initialize` body against the
/// `AppsFlyerLib.shared()` singleton. Mock-based coverage in
/// `AppsFlyerRemoteCommandTests` only verifies the payload-to-`initialize`
/// dispatch — these tests verify the settings-to-SDK property mapping
/// and the Facebook Deferred AppLinks fallback that lives inside the
/// real implementation.
class AppsFlyerInstanceInitializeTests: XCTestCase {

    var spyLogHandler: MockLogHandler!
    var instance: AppsFlyerInstance!

    override func setUp() {
        super.setUp()
        spyLogHandler = MockLogHandler()
        let logger = RemoteCommandLogger(logLevel: .debug, handler: spyLogHandler)
        instance = AppsFlyerInstance(logger: logger)
        // Reset shared singleton state to keep tests isolated.
        let lib = AppsFlyerLib.shared()
        lib.appsFlyerDevKey = ""
        lib.appleAppID = ""
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
    }

    func testInitializeAppliesCredentials() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
        XCTAssertEqual(AppsFlyerLib.shared().appsFlyerDevKey, "test_dev_key")
        XCTAssertEqual(AppsFlyerLib.shared().appleAppID, "test_app_id")
    }

    func testInitializeAppliesMinTimeBetweenSessions() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["time_between_sessions": 60])
        XCTAssertEqual(AppsFlyerLib.shared().minTimeBetweenSessions, 60)
    }

    /// The SDK property is `UInt`, so converting a negative value would trap.
    func testInitializeIgnoresNegativeMinTimeBetweenSessions() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["time_between_sessions": -1])
        XCTAssertEqual(AppsFlyerLib.shared().minTimeBetweenSessions, 0)
    }

    func testInitializeIgnoresNegativeDeepLinkTimeout() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["deep_link_timeout": -1])
        XCTAssertEqual(AppsFlyerLib.shared().deepLinkTimeout, 0)
    }

    func testInitializeAppliesAppleSettings() {
        instance.initialize(appId: "id", appDevKey: "key", settings: [
            "disable_apple_ad_tracking": true,
            "disable_apple_ads_attribution": true
        ])
        XCTAssertTrue(AppsFlyerLib.shared().disableSKAdNetwork)
        XCTAssertTrue(AppsFlyerLib.shared().disableAppleAdsAttribution)
    }

    func testInitializeAppliesCollectDeviceName() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["collect_device_name": true])
        XCTAssertTrue(AppsFlyerLib.shared().shouldCollectDeviceName)
    }

    func testInitializeAppliesCustomData() {
        instance.initialize(appId: "id", appDevKey: "key", settings: [
            "custom_data": ["custom_key": "custom_value"]
        ])
        XCTAssertEqual(AppsFlyerLib.shared().customData?["custom_key"] as? String, "custom_value")
    }

    func testInitializeAppliesFacebookDeferredAppLink() {
        instance.initialize(appId: "id", appDevKey: "key", settings: [
            "facebook_deferred_app_link": "https://example.com/deferred"
        ])
        XCTAssertEqual(AppsFlyerLib.shared().facebookDeferredAppLink?.absoluteString,
                       "https://example.com/deferred")
    }

    /// These have no readable SDK property, so the assertion is that the branches run
    /// and apply cleanly rather than what they set.
    func testInitializeAcceptsSettingsWithoutReadableState() {
        instance.initialize(appId: "id", appDevKey: "key", settings: [
            "enable_tcf_data_collection": true,
            "push_notification_deep_link_path": ["af_push_link"],
            "wait_for_att_user_authorization_timeout_interval": NSNumber(value: 45),
            "deep_link_parameters": [
                ["contains": "onelink.me", "parameters": ["utm_source": "appsflyer"]]
            ]
        ])
        XCTAssertEqual(AppsFlyerLib.shared().appsFlyerDevKey, "key")
        XCTAssertEqual(spyLogHandler.messages(for: .error), [])
    }

    func testInitializeAppliesDebugSetting() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["debug": true])
        XCTAssertTrue(AppsFlyerLib.shared().isDebug)
    }

    func testInitializeAppliesAnonymizeUser() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["anonymize_user": true])
        XCTAssertTrue(AppsFlyerLib.shared().anonymizeUser)
    }

    func testInitializeAppliesDeepLinkTimeout() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["deep_link_timeout": 5000])
        XCTAssertEqual(AppsFlyerLib.shared().deepLinkTimeout, 5000)
    }

    func testInitializeAppliesOneLinkCustomDomains() {
        let domains = ["a.example.com", "b.example.com"]
        instance.initialize(appId: "id", appDevKey: "key", settings: ["one_link_custom_domains": domains])
        XCTAssertEqual(AppsFlyerLib.shared().oneLinkCustomDomains ?? [], domains)
    }

    /// Facebook Deferred AppLinks fallback: when the Facebook SDK class is not linked, the code
    /// path must surface an error log instead of crashing.
    func testInitializeLogsErrorWhenFacebookSDKMissing() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: ["enable_facebook_deferred_applinks": true]
        )
        XCTAssertTrue(spyLogHandler.messages(for: .error).contains { $0.contains("Facebook SDK not found") },
                      "Expected error log when FBSDKAppLinkUtility class is unavailable")
    }

    /// Disabling the Facebook flag must take the `else` branch and not log an error.
    func testInitializeDoesNotLogWhenFacebookFlagDisabled() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: ["enable_facebook_deferred_applinks": false]
        )
        XCTAssertEqual(spyLogHandler.messages(for: .error), [])
    }

    /// Android cross-platform alias maps to the same two SDK properties as the iOS key.
    func testInitializeAcceptsDisableAdvertisingIdentifiersAlias() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: ["disable_advertising_identifiers": true]
        )
        XCTAssertTrue(AppsFlyerLib.shared().disableAdvertisingIdentifier)
        XCTAssertTrue(AppsFlyerLib.shared().disableIDFVCollection)
    }

    /// `disable_idfv_collection` is applied after `disable_ad_tracking` so it can override the
    /// IDFV portion independently.
    func testInitializeDisableIDFVCollectionOverridesAfterDisableAdTracking() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: [
                "disable_ad_tracking": true,
                "disable_idfv_collection": false
            ]
        )
        XCTAssertTrue(AppsFlyerLib.shared().disableAdvertisingIdentifier)
        XCTAssertFalse(AppsFlyerLib.shared().disableIDFVCollection)
    }
}

