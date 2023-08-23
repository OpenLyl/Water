//
//  useStore.swift
//  Water
//
// 1. createStore
// 2. defStore
// 3. useStore
// 4. createSetupStore
// 5. unit test

import Foundation

public typealias UseStoreFn<Store> = () -> Store

// TODO: - view extension add global store manager to dispatcher
public func createStore() {
    
}

func setupStore<Store>(with closure: @escaping () -> Store) -> Store {
    // TODO: - call it with effect scope
    // FIXME: - keep store reactive ?
    let store = closure()
    return store
}

public func defStore<Store>(_ storeId: String, setupStoreClosure: @escaping () -> Store) -> UseStoreFn<Store> {
    func useStore() -> Store {
        // TODO: - follow the step
        // 1. get dispatcher
        // 2. check store exist
        // 3. generate store
        let store: Store = setupStore(with: setupStoreClosure)
        // 4. save store with id
        return store
    }
    return useStore
}
