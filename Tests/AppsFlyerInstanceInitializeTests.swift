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

    var spyLogHandler: SpyLogHandler!
    var instance: AppsFlyerInstance!

    override func setUp() {
        super.setUp()
        spyLogHandler = SpyLogHandler()
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
    }

    /// `initialize` body runs inside `DispatchQueue.main.async` — flush the
    /// main queue before asserting on `AppsFlyerLib.shared()` properties.
    private func waitForMainQueue() {
        let exp = expectation(description: "main queue flushed")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
    }

    func testInitializeAppliesCredentials() {
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
        waitForMainQueue()
        XCTAssertEqual(AppsFlyerLib.shared().appsFlyerDevKey, "test_dev_key")
        XCTAssertEqual(AppsFlyerLib.shared().appleAppID, "test_app_id")
    }

    func testInitializeAppliesDebugSetting() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["debug": true])
        waitForMainQueue()
        XCTAssertTrue(AppsFlyerLib.shared().isDebug)
    }

    func testInitializeAppliesAnonymizeUser() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["anonymize_user": true])
        waitForMainQueue()
        XCTAssertTrue(AppsFlyerLib.shared().anonymizeUser)
    }

    func testInitializeAppliesDeepLinkTimeout() {
        instance.initialize(appId: "id", appDevKey: "key", settings: ["deep_link_timeout": 5000])
        waitForMainQueue()
        XCTAssertEqual(AppsFlyerLib.shared().deepLinkTimeout, 5000)
    }

    func testInitializeAppliesOneLinkCustomDomains() {
        let domains = ["a.example.com", "b.example.com"]
        instance.initialize(appId: "id", appDevKey: "key", settings: ["one_link_custom_domains": domains])
        waitForMainQueue()
        XCTAssertEqual(AppsFlyerLib.shared().oneLinkCustomDomains ?? [], domains)
    }

    // Facebook Deferred AppLinks fallback: when the Facebook SDK class is
    // not linked, the code path must surface an error log instead of crashing.
    func testInitializeLogsErrorWhenFacebookSDKMissing() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: ["enable_facebook_deferred_applinks": true]
        )
        waitForMainQueue()
        XCTAssertTrue(spyLogHandler.errors.contains { $0.contains("Facebook SDK not found") },
                      "Expected error log when FBSDKAppLinkUtility class is unavailable")
    }

    // Disabling the Facebook flag must take the `else` branch and not log an error.
    func testInitializeDoesNotLogWhenFacebookFlagDisabled() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: ["enable_facebook_deferred_applinks": false]
        )
        waitForMainQueue()
        XCTAssertTrue(spyLogHandler.errors.isEmpty)
    }

    // Android cross-platform alias maps to the same two SDK properties as the iOS key.
    func testInitializeAcceptsDisableAdvertisingIdentifiersAlias() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: ["disable_advertising_identifiers": true]
        )
        waitForMainQueue()
        XCTAssertTrue(AppsFlyerLib.shared().disableAdvertisingIdentifier)
        XCTAssertTrue(AppsFlyerLib.shared().disableIDFVCollection)
    }

    // `disable_idfv_collection` is applied after `disable_ad_tracking` so it can
    // override the IDFV portion independently.
    func testInitializeDisableIDFVCollectionOverridesAfterDisableAdTracking() {
        instance.initialize(
            appId: "id",
            appDevKey: "key",
            settings: [
                "disable_ad_tracking": true,
                "disable_idfv_collection": false
            ]
        )
        waitForMainQueue()
        XCTAssertTrue(AppsFlyerLib.shared().disableAdvertisingIdentifier)
        XCTAssertFalse(AppsFlyerLib.shared().disableIDFVCollection)
    }
}

// MARK: - Spy

/// Captures log messages so tests can assert against the Facebook fallback branch.
class SpyLogHandler: LogHandler {
    var debugs: [String] = []
    var infos: [String] = []
    var warnings: [String] = []
    var errors: [String] = []

    func log(level: RemoteCommandLogLevel, message: String) {
        switch level {
        case .debug: debugs.append(message)
        case .info: infos.append(message)
        case .warning: warnings.append(message)
        case .error: errors.append(message)
        case .silent: break
        }
    }
}
