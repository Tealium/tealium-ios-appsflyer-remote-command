//
//  RemoteCommandLogger.swift
//  TealiumAppsFlyer
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import os.log

/// Centralized logging utility for Remote Command.
/// Log verbosity is controlled via the `logLevel` parameter passed to `AppsFlyerRemoteCommand`.
struct RemoteCommandLogger {
    private static let tag = "TealiumAppsFlyer"
    private static let logger = OSLog(subsystem: "com.tealium.appsflyer", category: "RemoteCommand")
    static var logLevel: RemoteCommandLogLevel = .silent

    static func debug(_ message: String) {
        guard logLevel <= .debug else { return }
        os_log(.debug, log: logger, "[%{public}@] %{public}@", tag, message)
    }

    static func info(_ message: String) {
        guard logLevel <= .info else { return }
        os_log(.info, log: logger, "[%{public}@] %{public}@", tag, message)
    }

    static func warning(_ message: String) {
        guard logLevel <= .warning else { return }
        os_log(.default, log: logger, "[%{public}@] WARNING: %{public}@", tag, message)
    }

    static func error(_ message: String) {
        guard logLevel <= .error else { return }
        os_log(.error, log: logger, "[%{public}@] ERROR: %{public}@", tag, message)
    }
}
