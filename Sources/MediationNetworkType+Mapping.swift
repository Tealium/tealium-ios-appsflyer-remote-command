//
//  MediationNetworkType+Mapping.swift
//  TealiumAppsFlyer
//
//  Created by Tealium Inc. on 2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import AppsFlyerLib

// MARK: - MediationNetworkType String Mapping

extension MediationNetworkType {

    /// Valid string values accepted by the remote command payload for `mediation_network`.
    ///
    /// - SeeAlso: https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib#logadrevenue
    static var validValues: [String] {
        Array(AppsFlyerConstants.mediationNetworksMap.keys)
    }

    /// Initializes from a payload string value. Case-insensitive and trims whitespace.
    /// Returns nil if unrecognized.
    init?(_ string: String) {
        let normalized = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let type = AppsFlyerConstants.mediationNetworksMap[normalized] else {
            return nil
        }
        self = type
    }
}
