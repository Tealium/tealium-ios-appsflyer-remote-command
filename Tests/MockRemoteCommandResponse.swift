//
//  MockRemoteCommandResponse.swift
//  TealiumAppsFlyerTests
//
//  Created by Sebastian Krajna on 9/2/26.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
#if COCOAPODS
import TealiumSwift
#else
import TealiumRemoteCommands
#endif

/// Stands in for the response the RemoteCommands module passes to `AppsFlyerRemoteCommand`'s
/// completion closure, so tests can exercise that closure instead of bypassing it.
class MockRemoteCommandResponse: RemoteCommandResponseProtocol {
    var payload: [String: Any]?
    var error: Error?
    var status: Int?
    var data: Data?
    var hasCustomCompletionHandler = false

    init(payload: [String: Any]?) {
        self.payload = payload
    }
}
