//
//  Bismuth.Queue.swift
//  Bismuth
//
//  Created by Bas van Kuijck on 26/09/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

public protocol BismuthQueueDelegate: class {
    func queue<T>(_ queue: Bismuth.Queue<T>, handle item: T, completion: @escaping (Bismuth.HandleResult) -> Void)  where T : BismuthQueueable
    func queueFinished<T>(_ queue: Bismuth.Queue<T>) where T : BismuthQueueable
}

extension Bismuth {
    public enum HandleResult: Int {
        case retry
        case handled
    }
}

extension Bismuth {
    public class Queue<T: BismuthQueueable> {
        private let _config: Bismuth.Config
        private var _storeInCache = false

        let cache: Cache<T>

        private var _items: [T] = [] {
            didSet {
                self._storeTimer?.invalidate()
                self._storeTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(_storeItemsInCache), userInfo: nil, repeats: false)
                RunLoop.main.add(self._storeTimer!, forMode: .common)
            }
        }

        public var count: Int {
            return synchronized(self) { return _items.count }
        }

        public var isEmpty: Bool {
            return synchronized(self) { return _items.isEmpty }
        }

        public weak var delegate: BismuthQueueDelegate?
        private var _backgroundTask: UIBackgroundTaskIdentifier = .invalid
        private var _backgroundTimer: Timer?
        private var _storeTimer: Timer?
        private(set) public var isBusy: Bool = false
        private var _timer: Timer?

        // MARK: - Initialization
        // --------------------------------------------------------

        public required init(config: Bismuth.Config) {
            _config = config
            cache = Cache<T>()
            _items = cache.get(key: _config.identifier) ?? []
            _storeInCache = true

            if config.canRunInBackground {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(_didEnterBackground),
                                                       name: UIApplication.didEnterBackgroundNotification,
                                                       object: nil)
            }
            if config.autoStart {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(_didBecomeActive),
                                                       name: UIApplication.didBecomeActiveNotification,
                                                       object: nil)

            }
        }

        // MARK: - Lifecycle
        // --------------------------------------------------------

        @objc
        private func _didBecomeActive() {
            if !isBusy {
                start()
            }
        }

        @objc
        private func _didEnterBackground() {
            if !isBusy || _backgroundTask != .invalid {
                return
            }
            _backgroundTimer?.invalidate()
            _config.logProxy?("Started background task, timeout after: \(ceil(UIApplication.shared.backgroundTimeRemaining))s")
            let time = UIApplication.shared.backgroundTimeRemaining - 5
            _backgroundTimer = Timer(timeInterval: time,
                                     target: self,
                                     selector: #selector(_endBackgroundTask),
                                     userInfo: nil,
                                     repeats: false)
            RunLoop.main.add(_backgroundTimer!, forMode: .common)

            _backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?._config.logProxy?("Background task not finished in \(time)s.")
                self?._endBackgroundTask()
            }
        }

        @objc
        private func _endBackgroundTask() {
            if !_config.canRunInBackground {
                return
            }
            _backgroundTimer?.invalidate()
            _backgroundTimer = nil
            if _backgroundTask == .invalid {
                return
            }
            UIApplication.shared.endBackgroundTask(_backgroundTask)
            _backgroundTask = .invalid
        }

        // MARK: - Cache
        // --------------------------------------------------------

        @objc
        private func _storeItemsInCache() {
            synchronized(self) {
                if !self._storeInCache {
                    return
                }
                self._storeTimer = nil
                self.cache.write(_items, key: _config.identifier)
            }
        }

        public func add(_ items: [T]) {
            items.forEach { add($0) }
        }

        public func add(_ item: T) {
            synchronized(self) {
                // Prevent duplicate queue items
                var newQueue = self._items.filter { $0 != item }

                // Reset all the `retryTime` values to 0, so we immediatelly can start the queue
                newQueue = newQueue.map { item in
                    var item = item
                    item.bismuthRetryTime = 0
                    return item
                }
                self._config.logProxy?("Added item to queue (position: \(newQueue.count)): \(item)")
                newQueue.append(item)
                self._items = newQueue

                if !self._config.autoStart {
                    return
                }
                // If the queue is not busy, start it!
                if !self.isBusy {
                    self._next()

                    // Else if the queue is in a cool-down state -> retrying failed items, then interrupt that and immediatelly try again.
                    // We want to do this so any failed items would not block new queue items
                } else if self._timer != nil {
                    self._timer?.invalidate()
                    self._timer = nil
                    self._next()
                }
            }
        }

        public func clear() {
            synchronized(self) {
                self._items.removeAll()
            }
        }

        // MARK: - Handling
        // --------------------------------------------------------

        public func start() {
            if isBusy {
                return
            }
            _config.logProxy?("Start queue (size \(count))")
            _next()
        }

        private func _next() {
            synchronized(self) {
                guard let item = self._items.first else {
                    self._config.logProxy?("Queue empty")
                    self.isBusy = false
                    self.delegate?.queueFinished(self)
                    self._endBackgroundTask()
                    return
                }
                let extra: String

                if UIApplication.shared.applicationState == .background && self._backgroundTask != .invalid {
                    extra = "in background, timeout in \(round(UIApplication.shared.backgroundTimeRemaining))s"
                } else {
                    extra = "in foreground"
                }

                self._config.logProxy?("Queue items left: \(self.count) (\(extra))")
                self._config.logProxy?("-=> \(item)")
                self._timer?.invalidate()
                self._timer = nil
                self.isBusy = true
                let diff = item.bismuthRetryTime - Date().timeIntervalSince1970
                if diff <= 0 {
                    self._submit(item: item)
                    return
                }
                self._config.logProxy?("Continuing queue after \(ceil(diff))s...")
                self._timer = Timer(timeInterval: diff, target: self, selector: #selector(_fireTimer(_:)), userInfo: [ "item": item ], repeats: false)
                RunLoop.main.add(self._timer!, forMode: .common)
            }
        }

        private func _submit(item: T) {
            delegate?.queue(self, handle: item) { [weak self] result in
                guard let self = self else {
                    return
                }

                if self.isEmpty {
                    self.isBusy = false
                    return
                }

                var item = self._items.removeFirst()
                defer {
                    self._next()
                }

                // Connection or SNS throttle problems will requeue the item, to try again.
                // Other errors probably won't be able to finish successfully.
                if result == .handled {
                    return
                }

                // If a potential solvable error occurs, retry the queue item after 15s
                // This way we can avoid infinite loops and hope the error solves itself
                item.bismuthRetryTime = Date(timeIntervalSinceNow: self._config.reryTimeInterval).timeIntervalSince1970

                // Are any other topic related items in the queue?
                // We need to know this, because if we place the failed item at the end of the queue
                //  it can cause a problem when for instance a subscribe item is actually the last action from the user
                //  and we retry the (failed) unsubscribe item in behind it (aka will be called last)
                if (self._items.filter { $0 == item }).isEmpty {

                    // We'll put the failed item in the back of the queue,
                    // so we can try to submit the other items first
                    self._items.append(item)
                } else {
                    // Keep the original position in the queue
                    self._items.insert(item, at: 0)
                }
            }
        }

        @objc
        private func _fireTimer(_ timer: Timer) {
            _timer = nil
            guard let userInfo = timer.userInfo as? [String: T], let item = userInfo["item"] else {
                _next()
                return
            }

            if !_items.contains(item) {
                _next()
                return
            }
            _submit(item: item)
        }

        deinit {
            _storeTimer?.invalidate()
            _storeTimer = nil
            NotificationCenter.default.removeObserver(self,
                                                      name: UIApplication.didEnterBackgroundNotification,
                                                      object: nil)
            NotificationCenter.default.removeObserver(self,
                                                      name: UIApplication.didBecomeActiveNotification,
                                                      object: nil)
        }
    }
}
