//
//  Bismuth.Config.swift
//  Bismuth
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

extension Bismuth {
    public struct Config {
        public let identifier: String
        public var reryTimeInterval: TimeInterval = 15
        public var autoStart: Bool = true
        public var canRunInBackground: Bool = true
        public var logProxy: ((String) -> Void)?

        public init(identifier: String) {
            self.identifier = identifier
        }
    }
}
