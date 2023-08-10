//
//  useStore.swift
//  Water
//

import Foundation

class Store<T> {
    private let setupFn: () ->T
    
    init(setupClosure: @escaping () -> T) {
        self.setupFn = setupClosure
    }
    
    func setup() -> T {
        return setupFn()
    }
}

public func useStore<T>(_ storeId: String, setupClosure: @escaping () -> T) -> (() -> T) {
    let store = Store(setupClosure: setupClosure)
    let fn: () -> T = {
        return store.setup()
    }
    return fn
}
