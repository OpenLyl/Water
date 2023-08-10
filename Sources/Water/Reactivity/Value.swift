//
//  Value.swift
//  Water
//

import SwiftUI

public class ReactiveValue<T> {
    private var _value: T

    public init(value: T) {
        _value = value
    }

    public var value: T {
        get {
            trackValueEffects()
            return _value
        }
        set {
            if match(lhs: _value, rhs: newValue) {
                return
            }
            _value = newValue
            triggerValueEffects()
        }
    }
    
    public func unwrap() -> T {
        return _value
    }
}

// MARK: - effect

extension ReactiveValue: Reactor {
    func trackValueEffects() {
        track(reactor: self)
    }

    func triggerValueEffects() {
        trigger(reactor: self)
    }
}

// MARK: - watch

var watchedValues: [Any] = .init() // FIXME: - check need store values

extension ReactiveValue: Watchable {
    public func watch() -> T {
        let value = self.value
        watchedValues.append(value) // FIXME: - store watched value only once, why need to store it
        return value
    }
}

// MARK: - def

public func defValue<T>(_ value: T) -> ReactiveValue<T> {
    let value = ReactiveValue(value: value)
    return value
}

// TODO: - def value return getter setter function like react hooks
