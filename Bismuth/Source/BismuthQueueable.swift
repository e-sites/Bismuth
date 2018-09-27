//
//  BismuthQueueable.swift
//  Bismuth
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

public protocol BismuthQueueable: Equatable, Codable {
    
}

fileprivate var retryTimeKey: UInt8 = 0

extension BismuthQueueable {
    var bismuthRetryTime: TimeInterval {
        get {
            return (objc_getAssociatedObject(self, &retryTimeKey) as? TimeInterval) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &retryTimeKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
