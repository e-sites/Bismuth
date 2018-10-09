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
    }
    
    let item: T
    var retryTime: TimeInterval = 0
    
    init(item: T, retryTime: TimeInterval = 0) {
        self.item = item
        self.retryTime = retryTime
    }
    
    static func == (lhs: Item<T>, rhs: Item<T>) -> Bool {
        return lhs.item == rhs.item
    }
}
