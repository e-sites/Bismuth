//
//  Bismuth.Queue.Item.swift
//  Bismuth
//
//  Created by Bas van Kuijck on 09/10/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

struct BismuthQueueItem<T: BismuthQueueable>: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case item
        case retryTime
        case attempts
    }
    
    let item: T
    var attempts: Int = 0
    var retryTime: TimeInterval = 0
    
    init(item: T, attempts: Int = 0, retryTime: TimeInterval = 0) {
        self.item = item
        self.attempts = attempts
        self.retryTime = retryTime
    }
    
    static func == (lhs: BismuthQueueItem<T>, rhs: BismuthQueueItem<T>) -> Bool {
        return lhs.item == rhs.item
    }
}
