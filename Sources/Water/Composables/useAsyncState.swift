//
//  useAsyncState.swift
//  Water
//

import Foundation

public func useAsyncState<T>(_ asyncFn: @escaping () async -> T, _ initialState: T) -> (ReactiveValue<T>, ReactiveValue<Bool>) {
    let isLoading = defValue(false)
    let state = defValue(initialState)
    
    @Sendable func execute() async {
        isLoading.value = true
        let data = await asyncFn()
        state.value = data
        isLoading.value = false
    }
    
    // execute immediately
    Task {
        await execute()
    }
    
    return (state, isLoading)
}
