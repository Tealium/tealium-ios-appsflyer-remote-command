//
//  LogHandler.swift
//  TealiumAppsFlyer
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import os.log

/// Destination for log output. Inject a custom implementation in tests.
protocol LogHandler {
    func log(level: RemoteCommandLogLevel, message: String)
}

struct OSLogHandler: LogHandler {
    private static let tag = "TealiumAppsFlyer"
    private static let osLogger = OSLog(subsystem: "com.tealium.appsflyer", category: "RemoteCommand")

    func log(level: RemoteCommandLogLevel, message: String) {
        switch level {
        case .debug:
            os_log(.debug, log: Self.osLogger, "[%{public}@] %{public}@", Self.tag, message)
        case .info:
            os_log(.info, log: Self.osLogger, "[%{public}@] %{public}@", Self.tag, message)
        case .warning:
            os_log(.default, log: Self.osLogger, "[%{public}@] WARNING: %{public}@", Self.tag, message)
        case .error:
            os_log(.error, log: Self.osLogger, "[%{public}@] ERROR: %{public}@", Self.tag, message)
        case .silent:
            break
        }
    }
}
