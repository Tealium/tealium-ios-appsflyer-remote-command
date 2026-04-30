//
//  AppsFlyerCommandError.swift
//  TealiumAppsFlyer
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation

/// Errors thrown by `AppsFlyerRemoteCommand` when processing a command fails.
enum AppsFlyerCommandError: Error {
    case missingParameter(String)
    case invalidParameterValue(parameter: String, value: String, allowedValues: [String])
    case invalidParameterType(parameter: String, expectedTypes: String)

    var message: String {
        switch self {
        case .missingParameter(let param):
            return "\(param) is required but missing from payload."
        case .invalidParameterValue(let param, let value, let allowed):
            return "Invalid value '\(value)' for '\(param)'. Supported values: \(allowed.joined(separator: ", "))."
        case .invalidParameterType(let param, let types):
            return "Unsupported type for '\(param)'. Supported types: \(types)."
        }
    }
}
