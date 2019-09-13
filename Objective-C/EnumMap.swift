//
//  EnumMap.swift
//  RemoteCommandModules
//
//  Created by Christina Sund on 5/31/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation

/// Used to convert command name to AppsFlyer Event Name
struct EnumMap<T: CaseIterable & Hashable, U> {
    private let values: [T: U]
    
    init(resolver: (T) -> U) {
        var values = [T: U]()
        
        for key in T.allCases {
            values[key] = resolver(key)
        }
        
        self.values = values
    }
    
    subscript(key: T) -> U {
        return values[key]!
    }
}
