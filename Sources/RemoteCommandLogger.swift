//
//  RemoteCommandLogger.swift
//  TealiumAppsFlyer
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation

/// Centralized logging utility for Remote Command.
/// Log verbosity is controlled via the `logLevel` parameter passed to `AppsFlyerRemoteCommand`.
struct RemoteCommandLogger {
    let logLevel: RemoteCommandLogLevel
    private let handler: LogHandler

    init(logLevel: RemoteCommandLogLevel = .silent, handler: LogHandler = OSLogHandler()) {
        self.logLevel = logLevel
        self.handler = handler
    }

    func debug(_ message: String) {
        guard logLevel <= .debug else { return }
        handler.log(level: .debug, message: message)
    }

    func info(_ message: String) {
        guard logLevel <= .info else { return }
        handler.log(level: .info, message: message)
    }

    func warning(_ message: String) {
        guard logLevel <= .warning else { return }
        handler.log(level: .warning, message: message)
    }

    func error(_ message: String) {
        guard logLevel <= .error else { return }
        handler.log(level: .error, message: message)
    }
}
