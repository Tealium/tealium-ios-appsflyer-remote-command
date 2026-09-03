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
        instance = SpyAppsFlyerInstance(logger: RemoteCommandLogger())
    }

    override func tearDown() {
        AppsFlyerLib.shared().delegate = nil
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
        let instance = AppsFlyerInstance(tealium: tealium)

        XCTAssertTrue(AppsFlyerLib.shared().delegate === instance)
        XCTAssertNil(AppsFlyerInstance(logger: RemoteCommandLogger()).tealium)
    }

    /// Attribution tracking on the RemoteCommand path has no Tealium instance, so it must
    /// no-op rather than crash.
    func testTealiumTrackWithoutTealiumInstanceDoesNothing() {
        AppsFlyerInstance(logger: RemoteCommandLogger())
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

    // MARK: - onAppOpenAttribution

    func testAppOpenAttributionTracksWithData() {
        let data: [AnyHashable: Any] = ["deep_link_value": "product123", "campaign": "promo"]
        instance.onAppOpenAttribution(data)
        XCTAssertEqual(instance.trackedTitle, "app_open_attribution")
        XCTAssertEqual(instance.trackedData?["deep_link_value"] as? String, "product123")
    }

    func testAppOpenAttributionTracksWithoutDataWhenCastFails() {
        // Keys are NSNumber — cast to [String: Any] fails, fallback to nil data.
        let data: [AnyHashable: Any] = [NSNumber(value: 1): "val"]
        instance.onAppOpenAttribution(data)
        XCTAssertEqual(instance.trackedTitle, "app_open_attribution")
        XCTAssertNil(instance.trackedData)
    }

    // MARK: - onAppOpenAttributionFailure

    func testAppOpenAttributionFailureTracksErrorEvent() {
        let error = NSError(domain: "test", code: 99, userInfo: [NSLocalizedDescriptionKey: "deep link error"])
        instance.onAppOpenAttributionFailure(error)
        XCTAssertEqual(instance.trackedTitle, "appsflyer_error")
        XCTAssertEqual(instance.trackedData?["error_name"] as? String, "app_open_attribution_failure")
        XCTAssertEqual(instance.trackedData?["error_description"] as? String, error.localizedDescription)
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
