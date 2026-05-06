//
//  RemoteCommandLogger.swift
//  TealiumAppsFlyer
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import os.log

/// Centralized logging utility; verbosity is controlled by `AppsFlyerRemoteCommand.logLevel`.
struct RemoteCommandLogger {
    private let tag = "TealiumAppsFlyer"
    private let osLog = OSLog(subsystem: "com.tealium.appsflyer", category: "RemoteCommand")
    let logLevel: RemoteCommandLogLevel

    init(logLevel: RemoteCommandLogLevel = .silent) {
        self.logLevel = logLevel
    }

    func debug(_ message: String) {
        guard logLevel <= .debug else { return }
        os_log(.debug, log: osLog, "[%{public}@] %{public}@", tag, message)
    }

    func info(_ message: String) {
        guard logLevel <= .info else { return }
        os_log(.info, log: osLog, "[%{public}@] %{public}@", tag, message)
    }

    func warning(_ message: String) {
        guard logLevel <= .warning else { return }
        os_log(.default, log: osLog, "[%{public}@] WARNING: %{public}@", tag, message)
    }

    func error(_ message: String) {
        guard logLevel <= .error else { return }
        os_log(.error, log: osLog, "[%{public}@] ERROR: %{public}@", tag, message)
    }
}
