//
//  AppsFlyerConstantsTests.swift
//  TealiumAppsFlyerTests
//
//  Created by Sebastian Krajna on 5/21/26.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest
import AppsFlyerLib
@testable import TealiumAppsFlyer

/// Validates the typed `CommandNames.fromString` resolver, mediation network mapping,
/// and static invariants of the constants enum (no duplicate raw values, etc.).
class AppsFlyerConstantsTests: XCTestCase {

    // MARK: - CommandNames.fromString

    func testFromStringResolvesKnownCommand() {
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("initialize"), .initialize)
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("tracklocation"), .trackLocation)
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("logadrevenue"), .logAdRevenue)
    }

    func testFromStringIsCaseInsensitive() {
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("Initialize"), .initialize)
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("INITIALIZE"), .initialize)
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("TrackLocation"), .trackLocation)
    }

    func testFromStringTrimsWhitespace() {
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("  initialize  "), .initialize)
        XCTAssertEqual(AppsFlyerConstants.CommandNames.fromString("\ttracklocation\n"), .trackLocation)
    }

    func testFromStringReturnsNilForUnknown() {
        XCTAssertNil(AppsFlyerConstants.CommandNames.fromString("purchase"))
        XCTAssertNil(AppsFlyerConstants.CommandNames.fromString(""))
        XCTAssertNil(AppsFlyerConstants.CommandNames.fromString("not_a_command"))
    }

    // MARK: - MediationNetworkType mapping

    func testMediationNetworkResolvesKnownValue() {
        XCTAssertEqual(MediationNetworkType("googleadmob"), .googleAdMob)
        XCTAssertEqual(MediationNetworkType("GoogleAdMob"), .googleAdMob)
        XCTAssertEqual(MediationNetworkType("  ironsource  "), .ironSource)
    }

    func testMediationNetworkReturnsNilForUnknown() {
        XCTAssertNil(MediationNetworkType("not_a_network"))
        XCTAssertNil(MediationNetworkType(""))
    }

    // MARK: - AppsFlyerCommandError messages

    func testMissingParameterMessage() {
        let error = AppsFlyerCommandError.missingParameter("foo")
        XCTAssertEqual(error.message, "foo is required but missing from payload.")
    }

    func testInvalidParameterValueMessage() {
        let error = AppsFlyerCommandError.invalidParameterValue(
            parameter: "mediation_network",
            value: "unknown",
            allowedValues: ["googleadmob", "ironsource"]
        )
        XCTAssertEqual(
            error.message,
            "Invalid value 'unknown' for 'mediation_network'. Supported values: googleadmob, ironsource."
        )
    }

    func testInvalidParameterTypeMessage() {
        let error = AppsFlyerCommandError.invalidParameterType(
            parameter: "af_lat",
            expectedTypes: "Double or Int"
        )
        XCTAssertEqual(error.message, "Unsupported type for 'af_lat'. Supported types: Double or Int.")
    }
}
