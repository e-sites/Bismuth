![Bismuth](Assets/logo.png)

Bismuth is part of the **[E-sites iOS Suite](https://github.com/e-sites/iOS-Suite)**.

---

A lightweight framework to handle queues

[![forthebadge](http://forthebadge.com/images/badges/made-with-swift.svg)](http://forthebadge.com) [![forthebadge](http://forthebadge.com/images/badges/built-with-swag.svg)](http://forthebadge.com)

[![Platform](https://img.shields.io/cocoapods/p/Bismuth.svg?style=flat)](http://cocoadocs.org/docsets/Bismuth)
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
import Alamofire

extension Alamofire.HTTPMethod: Codable { }

struct RequestQueueItem: BismuthQueueable {
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

    static func == (lhs: RequestQueueItem, rhs: RequestQueueItem) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
```

```swift
func configure() {
	var config = Bismuth.Config(identifier: "api-requests")
	config.logProxy = { line in
	    print("[REQ] \(line)")
	}
	config.autoStart = false // Default: true
	config.canRunInBackground = false // Default: true
	config.retryTime = 30 // Default: 15
	
	queue = Bismuth.Queue<RequestQueueItem>(config: config)
	queue.delegate = self
	queue.add(RequestQueueItem(url: "https://domain.com/api/get"))
	queue.add(RequestQueueItem(url: "https://domain.com/api/post", httpMethod: .post, parameters: [ "name": "Bas" ]))
	queue.add(RequestQueueItem(url: "https://domain.com/api/items/3", httpMethod: .delete))
}

// BismuthQueueDelegate functions

func queue<T>(_ queue: Bismuth.Queue<T>, handle item: T, completion: @escaping (Bismuth.HandleResult) -> Void) where T : BismuthQueueable {
	guard let item = item as? RequestQueueItem else {
        completion(.handled)
        return
    }
    
    // Do stuff with the queue item
    Alamofire.request(item.url, method: item.httpMethod, parameters: item.parameters)
    .validate()
    .responseJSON { response in
         switch response.result {
         case .success:
             completion(.handled)
         case .failure(let error):
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

# Control

> Pause a queue until `resume()` is called
 
```swift
func pause()
```

> Resumes a queue that was paused using `pause()`
 
```swift
func resume()
```

> Starts a queue, that is idle
 
```swift
func start()
```

> The current state of the queue (`idle`, `paused` or `running`)
 
```swift
var state: Bismuth.QueueState
```
