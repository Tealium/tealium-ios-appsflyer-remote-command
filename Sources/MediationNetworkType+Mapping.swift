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

    /// Maps lowercase payload strings to SDK enum values.
    /// Source: https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib#logadrevenue
    static let stringMap: [String: MediationNetworkType] = [
        "googleadmob": .googleAdMob,
        "ironsource": .ironSource,
        "applovinmax": .applovinMax,
        "fyber": .fyber,
        "appodeal": .appodeal,
        "admost": .admost,
        "topon": .topon,
        "tradplus": .tradplus,
        "yandex": .yandex,
        "chartboost": .chartBoost,
        "unity": .unity,
        "toponpte": .toponPte,
        "custom": .custom,
        "direct": .directMonetization
    ]

    /// Valid string values accepted by the remote command payload for `mediation_network`.
    ///
    /// - SeeAlso: https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib#logadrevenue
    static var validValues: [String] {
        Array(stringMap.keys)
    }

    /// Initializes from a payload string value. Case-insensitive and trims whitespace.
    /// Returns nil if unrecognized.
    init?(_ string: String) {
        let normalized = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let type = MediationNetworkType.stringMap[normalized] else {
            return nil
        }
        self = type
    }
}
