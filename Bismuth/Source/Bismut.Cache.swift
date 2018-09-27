//
//  Bismut.Cache.swift
//  Bismuth
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

extension Bismuth {
    class Cache<T: BismuthQueueable> {
        func write(_ items: [T], key: String) {
            do {
                let jsonEncoder = JSONEncoder()
                var jsonArray: [[String: Any]] = []

                for item in items {
                    let data = try jsonEncoder.encode(item)
                    guard var dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                        continue
                    }
                    dictionary["bismuthRetryTime"] = item.bismuthRetryTime
                    jsonArray.append(dictionary)
                }

                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)

                _makeCacheDirectory()
                let cacheFile = "\(key).cache"
                let url = URL(fileURLWithPath: _path(for: cacheFile))
                try? data.write(to: url)
            } catch let error {
                print("Error writing: \(error)")
            }
        }

        func get(key: String) -> [T]? {
            do {
                let jsonDecoder = JSONDecoder()
                let cacheFile = "\(key).cache"
                let path = _path(for: cacheFile)
                if !FileManager.default.fileExists(atPath: path) {
                    return nil
                }
                guard let data = FileManager.default.contents(atPath: path) else {
                    return nil
                }
                guard let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                    return nil
                }

                return try array.map {
                    var dictionary = $0
                    let retryTime = (dictionary["bismuthRetryTime"] as? TimeInterval) ?? 0
                    dictionary.removeValue(forKey: "bismuthRetryTime")
                    let itemData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                    var item = try jsonDecoder.decode(T.self, from: itemData)
                    item.bismuthRetryTime = retryTime
                    return item
                }
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
