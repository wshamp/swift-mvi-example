//
//  LifeTimeManager.swift
//  cryptominingtracker
//
//  Created by Wyeth Shamp on 2/14/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

final public class LifetimeManager {
    
    public typealias LifetimeUpdater = (Lifetime) -> Void
    
    public var updater: LifetimeUpdater {
        didSet {
            if let lifetime = lifetime {
                updater(lifetime)
            }
        }
    }
    
    public var lifetime: Lifetime? {
        return lifetimeTuple?.lifetime
    }
    
    private var lifetimeTuple: (lifetime: Lifetime, token: Lifetime.Token)?
    
    public init(updater: @escaping LifetimeUpdater) {
        self.updater = updater
    }
    
    public func invalidateLifetime() {
        lifetimeTuple = nil
    }
    
    public func updateLifetime() {
        invalidateLifetime()
        let lifetime = Lifetime.make()
        self.lifetimeTuple = lifetime
        updater(lifetime.lifetime)
    }
    
}

public extension SignalProducer {
    func observeOnMainQueue(during lifetime: Lifetime) -> SignalProducer {
        return lift { $0.observe(on: QueueScheduler.main).take(during: lifetime) }
    }
    
    @discardableResult
    func startWithValuesOnMainQueue(during lifetime: Lifetime, _ value: @escaping (Value) -> Void) -> Disposable {
        return observeOnMainQueue(during: lifetime).start(Signal.Observer(value: value))
    }
    
    @discardableResult
    func startWithValues(during lifetime: Lifetime, _ value: @escaping (Value) -> Void) -> Disposable {
        let signalProducer = lift { $0.take(during: lifetime) }
        return signalProducer.start(Signal.Observer(value: value))
    }
}

public extension Signal where Error == NoError {
    @discardableResult
    func observeValues(during lifetime: Lifetime, _ value: @escaping (Value) -> Void) -> Disposable? {
        let signal = Signal { observer, lifetime in
            lifetime += self.observe { event in
                observer.send(event)
            }
        }
        return signal.take(during: lifetime).observe(Observer(value: value))
    }
    
    @discardableResult
    func observeValuesOnMainQueue(during lifetime: Lifetime, _ value: @escaping (Value) -> Void) -> Disposable? {
        let signal = Signal { observer, lifetime in
            lifetime += self.observe { event in
                QueueScheduler.main.schedule {
                    observer.send(event)
                }
            }
        }
        return signal.take(during: lifetime).observe(Observer(value: value))
    }
}

public extension MutablePropertyProtocol {
    func refresh() {
        let currentValue = self.value
        self.value = currentValue
    }
}

