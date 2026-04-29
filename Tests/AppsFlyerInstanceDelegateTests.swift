//
//  AppsFlyerInstanceDelegateTests.swift
//  TealiumAppsFlyerTests
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest
@testable import TealiumAppsFlyer

/// Tests for AppsFlyerInstance delegate methods that relay attribution events
/// to Tealium. Uses a spy subclass to intercept tealiumTrack calls without
/// requiring a real Tealium instance.
class AppsFlyerInstanceDelegateTests: XCTestCase {

    var instance: SpyAppsFlyerInstance!

    override func setUp() {
        instance = SpyAppsFlyerInstance()
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
        XCTAssertNotNil(instance.trackedData)
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
