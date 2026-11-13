//
//  MockLogHandler.swift
//  TealiumAppsFlyerTests
//
//  Created by Sebastian Krajna on 9/2/26.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
@testable import TealiumAppsFlyer

class MockLogHandler: LogHandler {
    struct LogEvent {
        let level: RemoteCommandLogLevel
        let message: String
    }

    private(set) var logged: [LogEvent] = []

    func log(level: RemoteCommandLogLevel, message: String) {
        logged.append(LogEvent(level: level, message: message))
    }

    func events(for level: RemoteCommandLogLevel) -> [LogEvent] {
        logged.filter { $0.level == level }
    }

    func messages(for level: RemoteCommandLogLevel) -> [String] {
        events(for: level).map { $0.message }
    }
}
