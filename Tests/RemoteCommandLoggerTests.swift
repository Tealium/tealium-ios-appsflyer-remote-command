//
//  RemoteCommandLoggerTests.swift
//  TealiumAppsFlyerTests
//
//  Created by Sebastian Krajna on 9/2/26.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest
@testable import TealiumAppsFlyer

/// Covers the level filtering, which decides whether a message reaches the handler at all.
class RemoteCommandLoggerTests: XCTestCase {

    var logLevel: RemoteCommandLogLevel = .silent
    var mock = MockLogHandler()
    lazy var logger: RemoteCommandLogger = .init(logLevel: logLevel, handler: mock)

    func testDefaultLogLevelIsSilent() {
        XCTAssertEqual(RemoteCommandLogger().logLevel, .silent)
    }

    func testDebugLevelLogsEveryMessage() {
        logLevel = .debug

        logger.debug("d")
        logger.info("i")
        logger.warning("w")
        logger.error("e")

        XCTAssertEqual(mock.logged.count, 4)
    }

    func testInfoLevelSuppressesDebug() {
        logLevel = .info

        logger.debug("suppressed")
        logger.info("visible")

        XCTAssertEqual(mock.events(for: .debug).count, 0)
        XCTAssertEqual(mock.events(for: .info).count, 1)
    }

    func testWarningLevelSuppressesDebugAndInfo() {
        logLevel = .warning

        logger.debug("suppressed")
        logger.info("suppressed")
        logger.warning("visible")
        logger.error("visible")

        XCTAssertEqual(mock.events(for: .debug).count, 0)
        XCTAssertEqual(mock.events(for: .info).count, 0)
        XCTAssertEqual(mock.events(for: .warning).count, 1)
        XCTAssertEqual(mock.events(for: .error).count, 1)
    }

    func testErrorLevelOnlyLogsErrors() {
        logLevel = .error

        logger.debug("suppressed")
        logger.info("suppressed")
        logger.warning("suppressed")
        logger.error("visible")

        XCTAssertEqual(mock.logged.count, 1)
        XCTAssertEqual(mock.events(for: .error).count, 1)
    }

    func testSilentLevelSuppressesEverything() {
        logger.debug("suppressed")
        logger.info("suppressed")
        logger.warning("suppressed")
        logger.error("suppressed")

        XCTAssertEqual(mock.logged.count, 0)
    }

    func testMessageReachesHandlerUnchanged() {
        logLevel = .debug

        logger.warning("something went wrong")

        XCTAssertEqual(mock.messages(for: .warning), ["something went wrong"])
    }
}
