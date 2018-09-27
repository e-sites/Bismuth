![Bismuth](Assets/logo.png)

Bismuth is part of the **[E-sites iOS Suite](https://github.com/e-sites/iOS-Suite)**.

---

A lightweight framework to handle queues

[![forthebadge](http://forthebadge.com/images/badges/made-with-swift.svg)](http://forthebadge.com) [![forthebadge](http://forthebadge.com/images/badges/built-with-swag.svg)](http://forthebadge.com)

[![Platform](https://img.shields.io/cocoapods/p/Bismuth.svg?style=flat)](http://cocoadocs.org/docsets/Palladium)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Bismuth.svg)](https://cocoapods.org/pods/Bismuth)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Travis-ci](https://travis-ci.com/e-sites/Bismuth.svg?branch=master)](https://travis-ci.com/e-sites/Bismuth)


# Installation

Podfile:

```ruby
pod 'Bismuth'
```

And then

```
pod install
```

# Implementation

```swift
import Bismuth

struct AmazonSNSQueueItem: BismuthQueueable {
    enum CodingKeys: String, CodingKey {
        case type
        case topic
        case uuid
    }
    
    enum QueueType: String, Codable {
        case subscribe
        case unsubscribe
    }

    private var uuid = UUID().uuidString

    let type: QueueType
    let topic: String

    init(topic: String, type: QueueType) {
        self.topic = topic
        self.type = type
     }

    static func == (lhs: AmazonSNS.Queue.Item, rhs: AmazonSNS.Queue.Item) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
```

```swift
func configure() {
	var config = Bismuth.Config(identifier: "amazon-sns")
	config.logProxy = { line in
	    print("[SNS] \(line)")
	}
	config.autoStart = false // Default: true
	config.canRunInBackground = false // Default: true
	config.retryTime = 30 // Default: 15
	
	queue = Bismuth.Queue<AmazonSNSQueueItem>(config: config)
	queue.delegate = self
	queue.add(AmazonSNSQueueItem(topic: "topic-1", type: .subscribe))
	queue.add(AmazonSNSQueueItem(topic: "topic-2", type: .subscribe))
	queue.add(AmazonSNSQueueItem(topic: "topic-3", type: .subscribe))
	queue.add(AmazonSNSQueueItem(topic: "topic-4", type: .subscribe))
}

// BismuthQueueDelegate functions

func queue<T>(_ queue: Bismuth.Queue<T>, handle item: T, completion: @escaping (Bismuth.HandleResult) -> Void) where T : BismuthQueueable {
	guard let item = item as? AmazonSNSQueueItem else {
        completion(.handled)
        return
    }
    
    // Do stuff with the queue item
    doStuff { error in 
    	if error == nil {
    	    completion(.handled)
    	} else {
    	    completion(.retry)
       }    	
    }
}

func queueFinished<T>(_ queue: Bismuth.Queue<T>) where T : BismuthQueueable {

}
```

# Configuration

|Key|Type|Description|Default|
|---|---|---|---|
|`autoStart`|`Bool`|Do you want the queue to auto start upon app activation?|`true`|
|`reryTimeInterval`|`TimeInterval`|Failed queue items will retry after x seconds|`15`|
|`canRunInBackground`|`Bool`|Can the queue operate in the background|`true`|
|`logProxy`|`(String) -> Void`|A closure to call for debug logging|`nil`|