//
//  AppsFlyerInstanceDelegateTests.swift
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

/// Tests for AppsFlyerInstance delegate methods that relay attribution events
/// to Tealium. Uses a spy subclass to intercept tealiumTrack calls without
/// requiring a real Tealium instance.
class AppsFlyerInstanceDelegateTests: XCTestCase {

    var instance: SpyAppsFlyerInstance!

    override func setUp() {
        instance = SpyAppsFlyerInstance(logger: RemoteCommandLogger(logLevel: .silent))
    }

    override func tearDown() {
        AppsFlyerLib.shared().delegate = nil
        AppsFlyerLib.shared().deepLinkDelegate = nil
        super.tearDown()
    }

    // MARK: - Delegate registration

    /// `init(tealium:)` is the only path that registers for attribution callbacks — the
    /// initializer the RemoteCommand uses deliberately leaves the delegate unset.
    func testInitWithTealiumRegistersAsSDKDelegate() {
        let config = TealiumConfig(account: "test", profile: "test", environment: "dev")
        config.collectors = []
        config.dispatchers = []
        let tealium = Tealium(config: config)
        let instance = AppsFlyerInstance(tealium: tealium, logLevel: .silent)

        XCTAssertTrue(AppsFlyerLib.shared().delegate === instance)
        XCTAssertNil(AppsFlyerInstance(logger: RemoteCommandLogger(logLevel: .silent)).tealium)
    }

    /// Attribution tracking on the RemoteCommand path has no Tealium instance, so it must
    /// no-op rather than crash.
    func testTealiumTrackWithoutTealiumInstanceDoesNothing() {
        AppsFlyerInstance(logger: RemoteCommandLogger(logLevel: .silent))
            .tealiumTrack(title: "conversion_data_received", data: ["af_status": "Organic"])
    }

    // MARK: - onConversionDataSuccess

    func testConversionDataSuccessTracksOnFirstLaunch() {
        let data: [AnyHashable: Any] = [
            "is_first_launch": true,
            "af_status": "Non-organic",
            "source": "facebook",
            "campaign": "summer_sale"
        ]
        instance.onConversionDataSuccess(data)
        XCTAssertEqual(instance.trackedTitle, "conversion_data_received")
        XCTAssertEqual(instance.trackedData?["is_first_launch"] as? Bool, true)
        XCTAssertEqual(instance.trackedData?["af_status"] as? String, "Non-organic")
        XCTAssertEqual(instance.trackedData?["source"] as? String, "facebook")
        XCTAssertEqual(instance.trackedData?["campaign"] as? String, "summer_sale")
    }

    func testConversionDataSuccessTracksOnFirstLaunchWithOrganicStatus() {
        let data: [AnyHashable: Any] = [
            "is_first_launch": true,
            "af_status": "Organic"
        ]
        instance.onConversionDataSuccess(data)
        XCTAssertEqual(instance.trackedTitle, "conversion_data_received")
    }

    func testConversionDataSuccessDoesNotTrackOnSubsequentLaunch() {
        let data: [AnyHashable: Any] = [
            "is_first_launch": false,
            "af_status": "Non-organic"
        ]
        instance.onConversionDataSuccess(data)
        XCTAssertNil(instance.trackedTitle)
    }

    func testConversionDataSuccessDoesNotTrackWhenFirstLaunchKeyMissing() {
        let data: [AnyHashable: Any] = [
            "af_status": "Non-organic"
        ]
        instance.onConversionDataSuccess(data)
        XCTAssertNil(instance.trackedTitle)
    }

    func testConversionDataSuccessDoesNotTrackForNonStringDictionary() {
        // Keys are NSNumber, not String — cast to [String: Any] must fail.
        let data: [AnyHashable: Any] = [NSNumber(value: 1): true]
        instance.onConversionDataSuccess(data)
        XCTAssertNil(instance.trackedTitle)
    }

    func testConversionDataSuccessDoesNotTrackWhenFirstLaunchIsNotBool() {
        // Key present but wrong type — `as? Bool` cast fails, second guard returns early.
        let data: [AnyHashable: Any] = [
            "is_first_launch": "true",
            "af_status": "Non-organic"
        ]
        instance.onConversionDataSuccess(data)
        XCTAssertNil(instance.trackedTitle)
    }

    func testConversionDataSuccessWithMissingStatus() {
        // af_status absent — track still fires before the status guard returns.
        let data: [AnyHashable: Any] = [
            "is_first_launch": true
        ]
        instance.onConversionDataSuccess(data)
        XCTAssertEqual(instance.trackedTitle, "conversion_data_received")
        XCTAssertEqual(instance.trackedData?["is_first_launch"] as? Bool, true)
        XCTAssertNil(instance.trackedData?["af_status"])
    }

    func testConversionDataSuccessWithNonOrganicButMissingSourceOrCampaign() {
        // Non-organic with neither source nor campaign — track still fires, only logger call is skipped.
        let data: [AnyHashable: Any] = [
            "is_first_launch": true,
            "af_status": "Non-organic"
        ]
        instance.onConversionDataSuccess(data)
        XCTAssertEqual(instance.trackedTitle, "conversion_data_received")
        XCTAssertEqual(instance.trackedData?["af_status"] as? String, "Non-organic")
    }

    // MARK: - onConversionDataFail

    func testConversionDataFailTracksErrorEvent() {
        let error = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "network error"])
        instance.onConversionDataFail(error)
        XCTAssertEqual(instance.trackedTitle, "appsflyer_error")
        XCTAssertEqual(instance.trackedData?["error_name"] as? String, "conversion_data_failure")
        XCTAssertEqual(instance.trackedData?["error_description"] as? String, error.localizedDescription)
    }

    // MARK: - didResolveDeepLink

    /// A direct deep link is what the removed `onAppOpenAttribution` used to report, so it still
    /// tracks `app_open_attribution`, forwarding the SDK's click event as the event data.
    func testDidResolveDeepLinkTracksDirectLink() {
        guard let result = makeDeepLinkResult(deferred: false),
              let clickEvent = result.deepLink?.clickEvent, !clickEvent.isEmpty else {
            return XCTFail("Expected the SDK to populate `clickEvent` from the OneLink parameters")
        }

        instance.didResolveDeepLink(result)

        XCTAssertEqual(instance.trackedTitle, "app_open_attribution")
        XCTAssertEqual(instance.trackedData as NSDictionary?, clickEvent as NSDictionary)
    }

    /// SDK 7's callback also fires for deferred links, where `onAppOpenAttribution` never did.
    /// `onConversionDataSuccess` already reports that install as `conversion_data_received`, so
    /// tracking it here would double-report the same install.
    func testDidResolveDeepLinkSkipsDeferredLink() {
        guard let result = makeDeepLinkResult(deferred: true) else { return }

        instance.didResolveDeepLink(result)

        XCTAssertNil(instance.trackedTitle)
    }

    /// The `.failure` branch builds its error payload from `DeepLinkResult.error` directly, unlike
    /// the removed `onAppOpenAttributionFailure(_ error: Error)` which received the error as its
    /// own parameter — this pins down that the new mapping (title, error_name, error_description)
    /// still lands correctly.
    func testDidResolveDeepLinkTracksFailure() {
        guard let result = makeDeepLinkFailureResult(), let error = result.error else {
            return XCTFail("Expected the SDK to populate `error` for a `.failure` result")
        }

        instance.didResolveDeepLink(result)

        XCTAssertEqual(instance.trackedTitle, "appsflyer_error")
        XCTAssertEqual(instance.trackedData?["error_name"] as? String, "app_open_attribution_failure")
        XCTAssertEqual(instance.trackedData?["error_description"] as? String, error.localizedDescription)
    }

    /// `DeepLinkResult` and `DeepLink` declare `init`/`new` as `NS_UNAVAILABLE` and expose readonly
    /// properties only, so both are built through the SDK's own internal constructors reached via
    /// the ObjC runtime: `+[AppsFlyerDeepLink withOneLink:]` for a direct link,
    /// `+[AppsFlyerDeepLink withParameters:]` for a deferred one — that one is the deferred
    /// constructor proper, returning `nil` unless the parameters carry `found: true`, which is also
    /// what it derives `isDeferred` from. `-[AppsFlyerDeepLinkResult initWithDeepLink:error:]` wraps
    /// the link. Deliberate but fragile, like the `sdkConfig` reads in
    /// `AppsFlyerInstanceInitializeTests`: each step fails the test with an explanatory message
    /// instead of crashing if AppsFlyer renames these internals, and the state it produced
    /// (`isDeferred`, `status`) is asserted, so a test can never pass through the wrong branch.
    /// Verified against 7.0.2.
    private func makeDeepLinkResult(deferred: Bool,
                                    file: StaticString = #filePath,
                                    line: UInt = #line) -> DeepLinkResult? {
        var parameters: [String: Any] = [
            "campaign": "spring_sale",
            "media_source": "test_source",
            "deep_link_value": "product_42",
            "af_sub1": "sub1_value"
        ]
        if deferred {
            parameters["found"] = true
        }
        let constructor = deferred ? "withParameters:" : "withOneLink:"
        guard let deepLink = (DeepLink.self as AnyObject)
            .perform(NSSelectorFromString(constructor), with: parameters)?
            .takeUnretainedValue() as? DeepLink else {
            XCTFail("Could not build a `DeepLink` through `\(constructor)`. "
                    + "AppsFlyer SDK internals changed.", file: file, line: line)
            return nil
        }
        guard deepLink.isDeferred == deferred else {
            XCTFail("`\(constructor)` no longer produces isDeferred == \(deferred). "
                    + "AppsFlyer SDK internals changed.", file: file, line: line)
            return nil
        }
        guard let allocated = (DeepLinkResult.self as AnyObject)
            .perform(NSSelectorFromString("alloc"))?
            .takeUnretainedValue(),
              let result = (allocated as AnyObject)
                .perform(NSSelectorFromString("initWithDeepLink:error:"), with: deepLink, with: nil)?
                .takeUnretainedValue() as? DeepLinkResult else {
            XCTFail("Could not build a `DeepLinkResult` through `initWithDeepLink:error:`. "
                    + "AppsFlyer SDK internals changed.", file: file, line: line)
            return nil
        }
        guard result.status == .found else {
            XCTFail("Expected a resolved deep link to carry `.found`, got \(result.status).",
                    file: file, line: line)
            return nil
        }
        return result
    }

    /// Same `initWithDeepLink:error:` internal constructor as `makeDeepLinkResult`, but with a
    /// `nil` deep link and a real `NSError` — the SDK derives `.failure` from that combination.
    private func makeDeepLinkFailureResult(file: StaticString = #filePath,
                                            line: UInt = #line) -> DeepLinkResult? {
        let error = NSError(domain: "test", code: 99, userInfo: [NSLocalizedDescriptionKey: "deep link resolution failed"])
        guard let allocated = (DeepLinkResult.self as AnyObject)
            .perform(NSSelectorFromString("alloc"))?
            .takeUnretainedValue(),
              let result = (allocated as AnyObject)
                .perform(NSSelectorFromString("initWithDeepLink:error:"), with: nil, with: error)?
                .takeUnretainedValue() as? DeepLinkResult else {
            XCTFail("Could not build a `DeepLinkResult` through `initWithDeepLink:error:`. "
                    + "AppsFlyer SDK internals changed.", file: file, line: line)
            return nil
        }
        guard result.status == .failure else {
            XCTFail("Expected an error deep link result to carry `.failure`, got \(result.status).",
                    file: file, line: line)
            return nil
        }
        return result
    }
}

// MARK: - Spy

/// Subclass that intercepts tealiumTrack calls to avoid requiring a real Tealium instance.
class SpyAppsFlyerInstance: AppsFlyerInstance {
    var trackedTitle: String?
    var trackedData: [String: Any]?

    override func tealiumTrack(title: String, data: [String: Any]? = nil) {
        trackedTitle = title
        trackedData = data
    }
}
