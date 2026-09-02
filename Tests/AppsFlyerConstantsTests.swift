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

    /// Dictionary key order is undefined, so unsorted `validValues` would make the values quoted
    /// in `invalidParameterValue` messages differ between runs.
    func testValidValuesAreSorted() {
        XCTAssertEqual(MediationNetworkType.validValues, MediationNetworkType.validValues.sorted())
        XCTAssertEqual(MediationNetworkType.validValues.count, MediationNetworkType.stringMap.count)
        XCTAssertEqual(EmailCryptType.validValues, [0, 3])
    }

    // MARK: - Payload parameter reading

    /// An unmapped key and a key mapped to the wrong type are different tag mistakes, so they
    /// must not report the same error.
    func testRequireParameterDistinguishesMissingFromWrongType() {
        let payload: [String: Any] = ["host": 42]

        XCTAssertThrowsError(try payload.requireParameter("host_prefix", as: String.self)) { error in
            XCTAssertEqual((error as? AppsFlyerCommandError)?.message,
                           "host_prefix is required but missing from payload.")
        }
        XCTAssertThrowsError(try payload.requireParameter("host", as: String.self)) { error in
            XCTAssertEqual((error as? AppsFlyerCommandError)?.message,
                           "Unsupported type for 'host'. Supported types: String.")
        }
    }

    func testRequireDoubleAcceptsIntAndDouble() throws {
        XCTAssertEqual(try ["af_lat": 33].requireDouble("af_lat"), 33.0)
        XCTAssertEqual(try ["af_lat": 33.5].requireDouble("af_lat"), 33.5)
        XCTAssertEqual(try ["af_lat": NSNumber(value: 33)].requireDouble("af_lat"), 33.0)

        XCTAssertThrowsError(try ["af_lat": "33"].requireDouble("af_lat")) { error in
            XCTAssertEqual((error as? AppsFlyerCommandError)?.message,
                           "Unsupported type for 'af_lat'. Supported types: Double or Int.")
        }
    }

    func testRequireStringArrayAllowingSingleValueAcceptsBothShapes() throws {
        XCTAssertEqual(try ["emails": ["a@b.com"]].requireStringArrayAllowingSingleValue("emails"), ["a@b.com"])
        XCTAssertEqual(try ["emails": "a@b.com"].requireStringArrayAllowingSingleValue("emails"), ["a@b.com"])

        XCTAssertThrowsError(try ["emails": 42].requireStringArrayAllowingSingleValue("emails")) { error in
            XCTAssertEqual((error as? AppsFlyerCommandError)?.message,
                           "Unsupported type for 'emails'. Supported types: [String] or String.")
        }
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
