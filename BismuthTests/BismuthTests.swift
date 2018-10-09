//
//  BismuthTests.swift
//  BismuthTests
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
@testable import Bismuth

class QueueItem: BismuthQueueable {
    enum CodingKeys: String, CodingKey {
        case name
        case id
    }
    private let id = UUID().uuidString
    var name = "Bas"

    static func == (lhs: QueueItem, rhs: QueueItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class BismuthTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

    func testQueue() {
        let exp = expectation(description: "cache")
        let config = Bismuth.Config(identifier: "unit-test")
        let queue = Bismuth.Queue<QueueItem>(config: config)
        XCTAssertTrue(queue.isEmpty)
        queue.add(QueueItem())
        queue.add(QueueItem())
        queue.add(QueueItem())
        XCTAssertEqual(queue.count, 3)
        XCTAssertFalse(queue.isEmpty)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            guard let items = queue.cache.get(key: "unit-test") else {
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
