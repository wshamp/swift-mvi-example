//
//  PersonInfoViewModel.swift
//  swift-mvi-example
//
//  Created by Wyeth Shamp on 8/30/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result


enum PersonInfoAction {
    case setFirstName(value: String)
    case setLastName(value: String)
    case error(error: ClientError)
}

enum PersonInfoResult {
    case firstNameUpdated(firstName: String)
    case lastNameUpdated(lastName: String)
    case error(error: ClientError)
}

protocol PersonInfoViewModelProtocol {
    var personInfoViewState: Property<PersonInfoViewStateProtocol> { get }
}

class PersonInfoViewModel: PersonInfoViewModelProtocol {
    private let (lifetime, token) = Lifetime.make()
    private let personInfoEventSignal: Signal<PersonInfoEvent, NoError>
    private let mutablePersonInfoViewState: MutableProperty<PersonInfoViewStateProtocol>
    let personInfoViewState: Property<PersonInfoViewStateProtocol>
    
    init(personInfoEventSignal: Signal<PersonInfoEvent, NoError>,
         initialPersonInfoViewState: PersonInfoViewStateProtocol) {
        self.personInfoEventSignal = personInfoEventSignal
        self.mutablePersonInfoViewState = MutableProperty(initialPersonInfoViewState)
        self.personInfoViewState = Property(self.mutablePersonInfoViewState)
        setupBindings()
    }
    
    func setupBindings() {

        
        let eventSignalProducer = SignalProducer(personInfoEventSignal.take(during: lifetime)).withLatest(from: personInfoViewState.producer)
        

        eventSignalProducer.flatMap(.latest) { [weak self] arg -> SignalProducer<PersonInfoViewStateProtocol, NoError> in
            guard let strongSelf = self else {
                return SignalProducer(value: PersonInfoViewState(personInfoState: .error(error: ClientError.deallocationError(message: "Deallocated")), personInfo: arg.1.personInfo))
            }
            print("\(arg.1.personInfo.firstName)")
            print("\(arg.1.personInfo.lastName)")
            if case let PersonInfoEvent.error(error) = arg.0 {
                return SignalProducer(value:  PersonInfoViewState(personInfoState: .error(error: error), personInfo: arg.1.personInfo))
            }
            return strongSelf.reduceEvent(event: arg.0).flatMap(.latest) { action in
                return strongSelf.reduceAction(action: action).flatMap(.latest) { result in
                    return strongSelf.reduceResult(currentState: arg.1, result: result)
                }
            }
        }.startWithValues() { [weak self] value in
            self?.mutablePersonInfoViewState.value = value
        }
    }
    
    func reduceEvent(event: PersonInfoEvent) -> SignalProducer<PersonInfoAction, NoError> {
        switch event {
        case .firstNameChanged(let firstName):
            return SignalProducer(value: PersonInfoAction.setFirstName(value: firstName))
        case .lastNameChanged(let lastName):
            return SignalProducer(value: PersonInfoAction.setLastName(value: lastName))
        case .error(let error):
            return SignalProducer(value: .error(error: error))
        }
    }
    
    func reduceAction(action: PersonInfoAction) -> SignalProducer<PersonInfoResult, NoError> {
        switch action {
        case .setFirstName(let firstName):
            return SignalProducer(value: PersonInfoResult.firstNameUpdated(firstName: firstName))
        case .setLastName(let lastName):
            return SignalProducer(value: PersonInfoResult.lastNameUpdated(lastName: lastName))
        case .error(let error):
            return SignalProducer(value: .error(error: error))
        }
    }
    
    func reduceResult(currentState: PersonInfoViewStateProtocol, result: PersonInfoResult) -> SignalProducer<PersonInfoViewStateProtocol, NoError> {
        var state = currentState
        switch result {
        case .firstNameUpdated(let firstName):
            state.personInfoState = .idle
            state.personInfo.firstName += firstName
        case .lastNameUpdated(let lastName):
            state.personInfoState = .idle
            state.personInfo.lastName += lastName
        case .error(let error):
            state.personInfoState = .error(error: error)
        }
        return SignalProducer(value: state)
    }
}






public extension Signal {
    
    /**
     Transforms the signal into one that emits the most recent values of `self` and `other` only when `self`
     emits.
     - parameter other: A signal.
     - returns: A new signal.
     */
    public func withLatestFrom <U, OtherError> (_ other: Signal<U, OtherError>) ->
        Signal<(Value, U), OtherError> {
            
            return Signal<(Value, U), OtherError> { observer, _ in
                
                let lock = NSLock()
                lock.name = "org.reactivecocoa.ReactiveCocoa.withLatestFrom"
                
                let disposable = CompositeDisposable()
                var latestValue: U? = nil
                
                disposable += other.observe { event in
                    switch event {
                    case let .value(value):
                        lock.lock()
                        latestValue = value
                        lock.unlock()
                    case let .failed(error):
                        observer.send(error: error)
                    case .completed:
                        observer.sendCompleted()
                    case .interrupted:
                        observer.sendInterrupted()
                    }
                }
                
                disposable += self.signal.observe { event in
                    switch event {
                    case let .value(value):
                        lock.lock()
                        if let latestValue = latestValue {
                            observer.send(value: (value, latestValue))
                        }
                        lock.unlock()
                    case .failed, .completed, .interrupted:
                        // don't fail, complete or interrupt when the other does
                        break
                    }
                }
            }
    }
    
    /**
     Transforms the signal into one that emits the most recent values of `self` and `other` only when `self`
     emits.
     - parameter other: A producer.
     - returns: A new signal.
     */
    public func withLatestFrom <U, OtherError> (_ other: SignalProducer<U, OtherError>) ->
        Signal<(Value, U), OtherError> {
            
            return Signal<(Value, U), OtherError> { observer, _ in
                
                let lock = NSLock()
                lock.name = "org.reactivecocoa.ReactiveCocoa.withLatestFrom"
                
                let disposable = CompositeDisposable()
                var latestValue: U? = nil
                
                disposable += other.start { event in
                    switch event {
                    case let .value(value):
                        lock.lock()
                        latestValue = value
                        lock.unlock()
                    case let .failed(error):
                        observer.send(error: error)
                    case .completed:
                        observer.sendCompleted()
                    case .interrupted:
                        observer.sendInterrupted()
                    }
                }
                
                disposable += self.signal.observe { event in
                    switch event {
                    case let .value(value):
                        lock.lock()
                        if let latestValue = latestValue {
                            observer.send(value: (value, latestValue))
                        }
                        lock.unlock()
                    case .failed, .completed, .interrupted:
                        // don't fail, complete or interrupt when the other does
                        break
                    }
                }
            }
    }
}
