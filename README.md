![Bismuth](Assets/logo.png)

Bismuth is part of the **[E-sites iOS Suite](https://github.com/e-sites/iOS-Suite)**.

---

A lightweight framework to handle queues

[![forthebadge](http://forthebadge.com/images/badges/made-with-swift.svg)](http://forthebadge.com) [![forthebadge](http://forthebadge.com/images/badges/built-with-swag.svg)](http://forthebadge.com)

[![Platform](https://img.shields.io/cocoapods/p/Bismuth.svg?style=flat)](http://cocoadocs.org/docsets/Palladium)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Bismuth.svg)](http://cocoadocs.org/docsets/Bismuth)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Travis-ci](https://travis-ci.org/e-sites/Bismuth.svg?branch=master&001)](https://travis-ci.org/e-sites/Bismuth)


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
import Palladium

func authorize() {
    Palladium.shared.requestAuthorization { error in
        print("Authorization result: \(String(describing: error))")
    }
}

func schedule() {
    let content = UNMutableNotificationContent()
    content.body = "This is a notification"
    content.title = Date().description
    var metaData = MetaData(id: "123")
    metaData.tags = [ "tag1", "tag2" ]
    let date = Date(timeIntervalSinceNow: 5)
    Palladium.shared.add(content: content, in: metaData, at: date) { request, error in
        print("Scheduled: \(String(describing: request)), error: \(String(describing: error))")
    }
}

func cancel() {
    Palladium.shared.cancelNotifications(tags: [ "tag2" ]) { identifiers, error in
        print("Cancelled: \(identifiers?.count ?? 0), error: \(String(describing: error))")
    }
}
```