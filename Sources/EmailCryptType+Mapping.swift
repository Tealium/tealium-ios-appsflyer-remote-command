//
//  EmailCryptType+Mapping.swift
//  TealiumAppsFlyer
//
//  Created by Sebastian Krajna on 4/29/26.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import AppsFlyerLib

// MARK: - EmailCryptType Int Mapping

extension EmailCryptType {

    /// Accepted payload integers for `email_hash_type`: 0 = none, 3 = SHA256.
    static let intMap: [Int: EmailCryptType] = [
        0: EmailCryptTypeNone,
        3: EmailCryptTypeSHA256
    ]

    /// Valid integer values accepted by the remote command payload for `email_hash_type`.
    static let validValues: [Int] = Array(intMap.keys).sorted()

    /// Initializes from a payload integer value. Returns nil if unrecognized.
    init?(rawInt: Int) {
        guard let type = EmailCryptType.intMap[rawInt] else {
            return nil
        }
        self = type
    }
}
