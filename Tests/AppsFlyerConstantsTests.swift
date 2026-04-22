//
//  AppsFlyerConstantsTests.swift
//  TealiumAppsFlyerTests
//
//  Created by Tealium Inc. on 2026.
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

    // MARK: - CommandNames invariants

    func testCommandNamesRawValuesAreUnique() {
        let rawValues = AppsFlyerConstants.CommandNames.allCases.map { $0.rawValue }
        XCTAssertEqual(rawValues.count, Set(rawValues).count)
    }

    func testCommandNamesRawValuesAreLowercase() {
        for command in AppsFlyerConstants.CommandNames.allCases {
            XCTAssertEqual(command.rawValue, command.rawValue.lowercased(),
                           "Command raw value must be lowercase for fromString to resolve it: \(command.rawValue)")
        }
    }

    // MARK: - MediationNetworkType mapping

    func testMediationNetworkResolvesKnownValue() {
        XCTAssertNotNil(MediationNetworkType("googleadmob"))
        XCTAssertNotNil(MediationNetworkType("GoogleAdMob"))
        XCTAssertNotNil(MediationNetworkType("  ironsource  "))
    }

    func testMediationNetworkReturnsNilForUnknown() {
        XCTAssertNil(MediationNetworkType("not_a_network"))
        XCTAssertNil(MediationNetworkType(""))
    }

    func testMediationNetworkValidValuesMatchesMap() {
        XCTAssertEqual(Set(MediationNetworkType.validValues),
                       Set(AppsFlyerConstants.mediationNetworksMap.keys))
    }

    // MARK: - AppsFlyerCommandError messages

    func testMissingParameterMessage() {
        let error = AppsFlyerCommandError.missingParameter("foo")
        XCTAssertTrue(error.message.contains("foo"))
        XCTAssertTrue(error.message.contains("required"))
    }

    func testInvalidParameterValueMessage() {
        let error = AppsFlyerCommandError.invalidParameterValue(
            parameter: "mediation_network",
            value: "unknown",
            allowedValues: ["googleadmob", "ironsource"]
        )
        XCTAssertTrue(error.message.contains("mediation_network"))
        XCTAssertTrue(error.message.contains("unknown"))
        XCTAssertTrue(error.message.contains("googleadmob"))
    }

    func testInvalidParameterTypeMessage() {
        let error = AppsFlyerCommandError.invalidParameterType(
            parameter: "af_lat",
            expectedTypes: "Double or Int"
        )
        XCTAssertTrue(error.message.contains("af_lat"))
        XCTAssertTrue(error.message.contains("Double or Int"))
    }
}
