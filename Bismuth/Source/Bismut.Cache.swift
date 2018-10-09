//
//  Bismut.Cache.swift
//  Bismuth
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

extension Bismuth {
    class Cache<T: Codable> {

        private let _dispatchQueue = DispatchQueue(label: "com.esites.library.bismuth.cache", qos: .utility)
        private let _jsonEncoder = JSONEncoder()
        private let _jsonDecoder = JSONDecoder()

        func write(_ items: [T], key: String) {
            _dispatchQueue.async {
                do {
                    let data = try self._jsonEncoder.encode(items)

                    self._makeCacheDirectory()
                    let cacheFile = "\(key).cache"
                    let url = URL(fileURLWithPath: self._path(for: cacheFile))
                    try? data.write(to: url)
                } catch let error {
                    print("Error writing: \(error)")
                }
            }
        }

        func get(key: String) -> [T]? {
            do {
                let cacheFile = "\(key).cache"
                let path = _path(for: cacheFile)
                if !FileManager.default.fileExists(atPath: path) {
                    return nil
                }
                guard let data = FileManager.default.contents(atPath: path) else {
                    return nil
                }

                return try self._jsonDecoder.decode([T].self, from: data)
            } catch let error {
                print("Error getting: \(error)")
                return nil
            }
        }

        private func _path(for path: String) -> String {
            let cacheFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            return "\(cacheFolder)/com.esites.ios-suite.bismuth/\(path)"
        }

        private func _makeCacheDirectory() {
            do {
                let directoryPath = _path(for: "")
                if !FileManager.default.fileExists(atPath: directoryPath) {
                    let url = URL(fileURLWithPath: directoryPath)
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                }
            } catch { }
        }
    }
}
