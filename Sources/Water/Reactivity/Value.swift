//
//  Value.swift
//  Water
//

import SwiftUI

public class ReactiveValue<T>: Reactor {
    var _value: T
    
    private var _reactiveHandler: ReactiveHandler

    init(value: T, handler: ReactiveHandler) {
        _value = value
        _reactiveHandler = handler
        if isClass(value) {
            assertionFailure("reference class type not supported") // FIXME: need more check
        }
    }

    public var value: T {
        get {
            _reactiveHandler.handleGetValue(self)
        }
        set {
            _reactiveHandler.handleSetValue(self, newValue)
        }
    }

    public func unwrap() -> T {
        _value
    }
}

// MARK: - watch

var watchedValues: [Any] = .init() // FIXME: - check need store values

extension ReactiveValue: Watchable {
    public func watch() -> T {
        let value = value
        watchedValues.append(value) // FIXME: - store watched value only once, why need to store it
        return value
    }
}

// MARK: - def

public func defValue<T>(_ value: T) -> ReactiveValue<T> {
    ReactiveValue(value: value, handler: mutableHandler)
}

// TODO: - def value return getter setter function like react hooks
