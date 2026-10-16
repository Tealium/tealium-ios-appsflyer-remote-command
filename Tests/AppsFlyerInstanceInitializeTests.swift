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
#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
#endif

/// Exercises the real `AppsFlyerInstance` body against the
/// `AppsFlyerLib.shared()` singleton. Mock-based coverage in
/// `AppsFlyerRemoteCommandTests` only verifies the payload-to-command
/// dispatch — these tests verify the settings-to-SDK property mapping,
/// the Facebook Deferred AppLinks fallback, and the `onReady`/session-mode
/// behaviour that live inside the real implementation.
class AppsFlyerInstanceInitializeTests: XCTestCase {

    var spyLogHandler: MockLogHandler!
    var instance: AppsFlyerInstance!

    override func setUp() {
        super.setUp()
        spyLogHandler = MockLogHandler()
        let logger = RemoteCommandLogger(logLevel: .debug, handler: spyLogHandler)
        // Built without credentials, so construction never marks the instance ready, whichever
        // test last left real credentials on the singleton.
        instance = stubbingCredentials(false) { AppsFlyerInstance(sessionMode: .automatic, logger: logger) }
    }

    /// The real `isSessionReady()` depends on whatever the singleton went through earlier in the
    /// process, and a real `registerSessionReadyListener` could fire `start()` later, so every test
    /// runs with the session not ready and registrations swallowed. Tests that care nest their own stub.
    override func invokeTest() {
        stubbingSessionReady(false) {
            _ = countingListenerRegistrations { super.invokeTest() }
        }
    }

    /// Resets shared singleton state in tearDown, not setUp, so a class that runs after this one
    /// doesn't inherit whatever these tests last left on `AppsFlyerLib.shared()`. `appsFlyerDevKey`/
    /// `appleAppID` are skipped — every test's `instance.initialize` overwrites them anyway.
    override func tearDown() {
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
        lib.isStopped = false
        // Left registered, this fires `start()` during an unrelated later test.
        lib.unregisterSessionReadyListener()
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

    /// The SDK property is `UInt`, so converting a negative value would trap. The SDK default is
    /// 5 s, so this asserts the value is left alone rather than asserting it is `0`.
    func testInitializeIgnoresNegativeMinTimeBetweenSessions() {
        let before = AppsFlyerLib.shared().minTimeBetweenSessions
        instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: ["time_between_sessions": -1])
        XCTAssertEqual(AppsFlyerLib.shared().minTimeBetweenSessions, before)
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

    // MARK: - onReady

    func testOnReadyQueuedUntilInitializeThenReleasedOnceInFIFOOrderOnMain() {
        var released: [Int] = []
        var allOnMain = true
        stubbingCredentials(false) {
            for index in 0..<3 {
                instance.onReady { _ in
                    allOnMain = allOnMain && Thread.isMainThread
                    released.append(index)
                }
            }
        }
        XCTAssertEqual(released, [], "Expected onReady to queue while AppsFlyer has no credentials")
        XCTAssertTrue(spyLogHandler.messages(for: .debug).contains { $0.contains("queued") })

        stubbingSessionReady(false) {
            _ = countingListenerRegistrations {
                instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
                instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
            }
        }

        XCTAssertEqual(released, [0, 1, 2], "Expected queued blocks released exactly once, in FIFO order")
        XCTAssertTrue(allOnMain, "Expected onReady blocks to run on the main thread")
    }

    func testOnReadyRunsImmediatelyOnceCredentialsExist() {
        let instance = makeInstance(.appManaged)
        var ran = false
        stubbingCredentials(true) {
            instance.onReady { _ in ran = true }
        }
        XCTAssertTrue(ran)
    }

    /// Covers an app that calls `AppsFlyerLib.shared().initialize(devKey:appId:)` after building the
    /// instance and never maps the `initialize` command.
    func testOnReadyReleasedWhenAppInitializedAfterConstruction() {
        let registrations = stubbingSessionReady(false) {
            countingListenerRegistrations {
                stubbingCredentials(true) {
                    var ran = false
                    instance.onReady { _ in ran = true }
                    XCTAssertTrue(ran)
                }
            }
        }
        XCTAssertEqual(registrations, 1, "Expected .automatic to register the listener once credentials are found")
    }

    // MARK: - Credentials at construction

    func testCredentialsAtConstructionMarkReady() {
        var instance: AppsFlyerInstance!
        let registrations = stubbingSessionReady(false) {
            countingListenerRegistrations {
                stubbingCredentials(true) { instance = makeInstance(.automatic) }
            }
        }
        XCTAssertEqual(registrations, 1, "Expected .automatic to register the listener at construction")

        var ran = false
        stubbingCredentials(false) {
            instance.onReady { _ in ran = true }
        }
        XCTAssertTrue(ran, "Expected onReady to have been published at construction")
    }

    func testNoCredentialsAtConstructionDoesNotMarkReady() {
        var instance: AppsFlyerInstance!
        let registrations = stubbingSessionReady(false) {
            countingListenerRegistrations {
                stubbingCredentials(false) { instance = makeInstance(.automatic) }
            }
        }
        XCTAssertEqual(registrations, 0)

        var ran = false
        stubbingCredentials(false) {
            instance.onReady { _ in ran = true }
        }
        XCTAssertFalse(ran)
    }

    // MARK: - Session modes

    func testAutomaticRegistersListenerOnInitializeAndListenerCallsStart() {
        let listener = stubbingSessionReady(false) {
            capturingListenerRegistration {
                instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
            }
        }
        guard let listener else { return XCTFail("Expected initialize to register a session-ready listener") }

        XCTAssertEqual(countingSDKStartCalls { listener() }, 1)
    }

    /// The SDK keeps a single listener slot; a ready session means someone else owns it.
    func testAutomaticSkipsRegistrationWhenSessionAlreadyReady() {
        var released = false
        stubbingCredentials(false) {
            instance.onReady { _ in released = true }
        }

        let registrations = stubbingSessionReady(true) {
            countingListenerRegistrations {
                instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
            }
        }

        XCTAssertEqual(registrations, 0, "Expected the existing session-ready listener to be left in place")
        XCTAssertTrue(released, "Expected queued commands to be released without our own listener")
        XCTAssertTrue(spyLogHandler.messages(for: .error).contains { $0.contains("already ready") })
    }

    func testAppManagedNeverRegistersOrStarts() {
        let instance = makeInstance(.appManaged)
        var registrations = -1
        let sdkStartCalls = countingSDKStartCalls {
            registrations = stubbingSessionReady(false) {
                countingListenerRegistrations {
                    instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
                    instance.onReady { _ in }
                }
            }
        }
        XCTAssertEqual(registrations, 0)
        XCTAssertEqual(sdkStartCalls, 0)
    }

    /// `onReady` subscribers run before the listener is registered, so an app can adjust the SDK first.
    func testOnReadyPublishedBeforeListenerRegistration() {
        var order: [String] = []
        stubbingCredentials(false) {
            instance.onReady { _ in order.append("onReady") }
        }
        stubbingSessionReady(false) {
            recordingListenerRegistrations({ order.append("register") }) {
                instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
            }
        }
        XCTAssertEqual(order, ["onReady", "register"])
    }

    // MARK: - Credentials validation

    func testInitializeWithEmptyCredentialsLogsErrorAndSkipsSDKInitialize() {
        for (appId, devKey) in [("", "test_dev_key"), ("test_app_id", ""), ("", "")] {
            spyLogHandler = MockLogHandler()
            let label = "appId: \(appId.debugDescription) devKey: \(devKey.debugDescription)"
            let instance = stubbingCredentials(false) { makeInstance(.automatic) }
            var released = false
            var sdkInitializeCalls = -1
            let registrations = stubbingSessionReady(false) {
                countingListenerRegistrations {
                    stubbingCredentials(false) {
                        instance.onReady { _ in released = true }
                        sdkInitializeCalls = countingSDKInitializeCalls {
                            instance.initialize(appId: appId, appDevKey: devKey, settings: nil)
                        }
                    }
                }
            }
            XCTAssertEqual(sdkInitializeCalls, 0, label)
            XCTAssertEqual(registrations, 0, label)
            XCTAssertFalse(released, label)
            XCTAssertTrue(spyLogHandler.messages(for: .error).contains { $0.contains("cannot be empty") }, label)
        }
    }

    func testInitializeWarnsWhenAlreadyInitialized() {
        stubbingSessionReady(false) {
            _ = countingListenerRegistrations {
                stubbingCredentials(true) {
                    instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
                }
            }
        }
        XCTAssertTrue(spyLogHandler.messages(for: .warning).contains { $0.contains("already initialized") })
    }

    func testInitializeDoesNotWarnWithoutPriorCredentials() {
        stubbingSessionReady(false) {
            _ = countingListenerRegistrations {
                stubbingCredentials(false) {
                    instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
                }
            }
        }
        XCTAssertEqual(spyLogHandler.messages(for: .warning), [])
    }

    /// `registerSessionReadyListener` reads `UIApplication.applicationState`, so it must reach the SDK
    /// on the main thread even though commands run on `TealiumQueues.backgroundSerialQueue`.
    func testInitializeRegistersListenerOnMainThreadWhenCalledOffMain() {
        let expectation = expectation(description: "registerSessionReadyListener called")
        var calledOnMainThread = false

        stubbingSessionReady(false) {
            installingListenerRegistrationRecorder(fulfilling: expectation,
                                                    recordingMainThreadInto: { calledOnMainThread = $0 }) {
                TealiumQueues.backgroundSerialQueue.async {
                    self.instance.initialize(appId: "test_app_id", appDevKey: "test_dev_key", settings: nil)
                }
            }
        }

        XCTAssertTrue(calledOnMainThread, "Expected registerSessionReadyListener to reach the SDK on the main thread")
    }

    private func makeInstance(_ sessionMode: AppsFlyerSessionMode) -> AppsFlyerInstance {
        AppsFlyerInstance(sessionMode: sessionMode,
                          logger: RemoteCommandLogger(logLevel: .debug, handler: spyLogHandler))
    }

    /// Calls `onRegister` for each registration while `body` runs, without installing a real listener.
    private func recordingListenerRegistrations(_ onRegister: @escaping () -> Void, _ body: () -> Void) {
        guard let method = class_getInstanceMethod(AppsFlyerLib.self,
                                                   NSSelectorFromString("registerSessionReadyListener:")) else {
            return XCTFail("AppsFlyerLib.registerSessionReadyListener: not found")
        }
        let original = method_getImplementation(method)
        let recorder: @convention(block) (AnyObject, Any?) -> Void = { _, _ in onRegister() }
        method_setImplementation(method, imp_implementationWithBlock(recorder))
        defer { method_setImplementation(method, original) }
        body()
    }

    /// Swaps `AppsFlyerLib.registerSessionReadyListener:` for a block that records
    /// `Thread.isMainThread` and fulfils `expectation`, runs `body`, waits for `expectation`, then
    /// restores the original implementation. Unlike `countingListenerRegistrations`'s `defer`, the
    /// restore happens after the wait, not right after `body` returns — `body` here only starts the
    /// async call, so an immediate `defer` would remove the swizzle before it has run.
    private func installingListenerRegistrationRecorder(fulfilling expectation: XCTestExpectation,
                                                          recordingMainThreadInto record: @escaping (Bool) -> Void,
                                                          _ body: () -> Void) {
        guard let method = class_getInstanceMethod(AppsFlyerLib.self,
                                                   NSSelectorFromString("registerSessionReadyListener:")) else {
            XCTFail("AppsFlyerLib.registerSessionReadyListener: not found")
            return
        }
        let original = method_getImplementation(method)
        let recorder: @convention(block) (AnyObject, Any?) -> Void = { _, _ in
            record(Thread.isMainThread)
            expectation.fulfill()
        }
        method_setImplementation(method, imp_implementationWithBlock(recorder))
        body()
        wait(for: [expectation], timeout: 2)
        method_setImplementation(method, original)
    }

    /// Counts registrations while `body` runs, without installing a listener that would later fire
    /// `start()` into an unrelated test.
    private func countingListenerRegistrations(_ body: () -> Void) -> Int {
        guard let method = class_getInstanceMethod(AppsFlyerLib.self,
                                                   NSSelectorFromString("registerSessionReadyListener:")) else {
            XCTFail("AppsFlyerLib.registerSessionReadyListener: not found")
            return -1
        }
        Self.listenerRegistrationCount = 0
        let original = method_getImplementation(method)
        let counter: @convention(block) (AnyObject, Any?) -> Void = { _, _ in Self.listenerRegistrationCount += 1 }
        method_setImplementation(method, imp_implementationWithBlock(counter))
        defer { method_setImplementation(method, original) }
        body()
        return Self.listenerRegistrationCount
    }

    private static var listenerRegistrationCount = 0


}

// Shared method-swizzling helpers for stubbing `AppsFlyerLib.shared()`, so tests can exercise the
// real `AppsFlyerInstance` initialize/start code paths without registering a listener with the real
// SDK or waiting on it to call back.

/// Real readiness needs a foreground cycle and a live session, so the getter is stubbed instead.
func stubbingSessionReady<T>(_ ready: Bool, _ body: () -> T) -> T {
    guard let method = class_getInstanceMethod(AppsFlyerLib.self, NSSelectorFromString("isSessionReady")) else {
        XCTFail("AppsFlyerLib.isSessionReady() not found")
        return body()
    }
    let original = method_getImplementation(method)
    let stub: @convention(block) (AnyObject) -> Bool = { _ in ready }
    method_setImplementation(method, imp_implementationWithBlock(stub))
    defer { method_setImplementation(method, original) }
    return body()
}

/// Swaps `AppsFlyerLib.registerSessionReadyListener:` for a block that keeps the listener passed
/// to it, so a test can fire it by hand instead of waiting for a real foreground cycle.
func capturingListenerRegistration(_ body: () -> Void) -> (() -> Void)? {
    guard let method = class_getInstanceMethod(AppsFlyerLib.self,
                                               NSSelectorFromString("registerSessionReadyListener:")) else {
        XCTFail("AppsFlyerLib.registerSessionReadyListener: not found")
        return nil
    }
    var capturedListener: (() -> Void)?
    let original = method_getImplementation(method)
    let capture: @convention(block) (AnyObject, @escaping @convention(block) () -> Void) -> Void = { _, listener in
        capturedListener = listener
    }
    method_setImplementation(method, imp_implementationWithBlock(capture))
    defer { method_setImplementation(method, original) }
    body()
    return capturedListener
}

/// Swaps `AppsFlyerLib.start()` for a counter while `body` runs, so a forwarded call can be
/// observed without the SDK opening a real session.
func countingSDKStartCalls(_ body: () -> Void) -> Int {
    guard let method = class_getInstanceMethod(AppsFlyerLib.self, NSSelectorFromString("start")) else {
        XCTFail("AppsFlyerLib.start() not found")
        return -1
    }
    var count = 0
    let original = method_getImplementation(method)
    let counter: @convention(block) (AnyObject) -> Void = { _ in count += 1 }
    method_setImplementation(method, imp_implementationWithBlock(counter))
    defer { method_setImplementation(method, original) }
    body()
    return count
}

/// Swaps the `appleAppID`/`appsFlyerDevKey` getters while `body` runs. The SDK has no way to clear
/// credentials once set, so tests that need "not initialized" stub them instead.
func stubbingCredentials<T>(_ present: Bool, _ body: () -> T) -> T {
    guard let appId = class_getInstanceMethod(AppsFlyerLib.self, NSSelectorFromString("appleAppID")),
          let devKey = class_getInstanceMethod(AppsFlyerLib.self, NSSelectorFromString("appsFlyerDevKey")) else {
        XCTFail("AppsFlyerLib credential getters not found")
        return body()
    }
    let originalAppId = method_getImplementation(appId)
    let originalDevKey = method_getImplementation(devKey)
    let appIdStub: @convention(block) (AnyObject) -> NSString = { _ in present ? "stub_app_id" : "" }
    let devKeyStub: @convention(block) (AnyObject) -> NSString = { _ in present ? "stub_dev_key" : "" }
    method_setImplementation(appId, imp_implementationWithBlock(appIdStub))
    method_setImplementation(devKey, imp_implementationWithBlock(devKeyStub))
    defer {
        method_setImplementation(appId, originalAppId)
        method_setImplementation(devKey, originalDevKey)
    }
    return body()
}

/// Swaps `AppsFlyerLib.initialize(devKey:appId:)` for a counter while `body` runs.
func countingSDKInitializeCalls(_ body: () -> Void) -> Int {
    guard let method = class_getInstanceMethod(AppsFlyerLib.self, NSSelectorFromString("initWithDevKey:appleAppId:")) else {
        XCTFail("AppsFlyerLib.initialize(devKey:appId:) not found")
        return -1
    }
    var count = 0
    let original = method_getImplementation(method)
    let counter: @convention(block) (AnyObject, NSString, NSString) -> Void = { _, _, _ in count += 1 }
    method_setImplementation(method, imp_implementationWithBlock(counter))
    defer { method_setImplementation(method, original) }
    body()
    return count
}
