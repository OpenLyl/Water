//
//  useReducer.swift
//  Water
//

import Foundation

public func useReducer<State, Action>(_ initialState: State, _ reducer: @escaping (inout State, Action) -> Void) -> (() -> State, (Action) -> Void) {
    let reactiveState = defValue(initialState)
    
    func dispatch(action: Action) -> Void {
        var state = reactiveState.value
        reducer(&state, action)
        reactiveState.value = state
    }
    
    func stateGetter() -> State {
        return reactiveState.value
    }
    
    return (stateGetter, dispatch)
}
