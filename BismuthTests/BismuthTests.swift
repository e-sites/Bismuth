//
//  BismuthTests.swift
//  BismuthTests
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
@testable import Bismuth

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

extension HTTPMethod: Codable { }

struct QueueItem: BismuthQueueable {
    private enum CodingKeys: String, CodingKey {
        case url
        case httpMethod
        case parameters
    }

    private let uuid = UUID().uuidString

    let url: String
    let httpMethod: HTTPMethod
    let parameters: [String: String]?

    init(url: String, httpMethod: HTTPMethod = .get, parameters: [String: String]? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.parameters = parameters
    }

    static func == (lhs: QueueItem, rhs: QueueItem) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

class BismuthTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

    func testQueue() {
        let exp = expectation(description: "cache")
        let key = UUID().uuidString
        let config = Bismuth.Config(identifier: key)
        let queue = Bismuth.Queue<QueueItem>(config: config)
        XCTAssertTrue(queue.isEmpty)
        queue.add(QueueItem(url: "https://www.google.com"))
        queue.add(QueueItem(url: "https://www.google.com/new", httpMethod: .post, parameters: [ "name": "Bas" ]))
        queue.add(QueueItem(url: "https://www.e-sites.nl/api/item/1", httpMethod: .delete))
        XCTAssertEqual(queue.count, 3)
        let item = QueueItem(url: "https://www.e-sites.nl")
        queue.add(item)
        queue.remove(item)
        XCTAssertEqual(queue.count, 3)
        XCTAssertFalse(queue.isEmpty)
        XCTAssertEqual(queue.state, Bismuth.QueueState.running)
        queue.pause()
        XCTAssertEqual(queue.state, Bismuth.QueueState.paused)
        queue.resume()
        XCTAssertEqual(queue.state, Bismuth.QueueState.running)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            guard let items = queue.cache.get(key: key) else {
                preconditionFailure("No items")
            }
            XCTAssertEqual(items.count, queue.count)
            queue.clear()
            XCTAssertEqual(queue.count, 0)
            exp.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)
    }

}
