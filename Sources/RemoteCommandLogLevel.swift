//
//  RemoteCommandLogLevel.swift
//  TealiumAppsFlyer
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation

/// Controls verbosity of `RemoteCommandLogger` output.
public enum RemoteCommandLogLevel: Int, Comparable {
    /// Debug, info, warning, and error messages.
    case debug = 0

    /// Info, warning, and error messages.
    case info = 1

    /// Warning and error messages only.
    case warning = 2

    /// Error messages only.
    case error = 3

    /// No output. Default.
    case silent = 4

    public static func < (lhs: RemoteCommandLogLevel, rhs: RemoteCommandLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
