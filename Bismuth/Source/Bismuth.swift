//
//  Bismuth.swift
//  Bismuth
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

public class Bismuth {
}


@discardableResult
func synchronized<T>(_ lock: Any, block: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }

    return try block()
}
