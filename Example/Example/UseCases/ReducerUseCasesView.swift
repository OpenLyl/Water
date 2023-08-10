//
//  ReducerUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct ReducerUseCasesView: View {
    var body: some View {
        ReducerCounterView()
    }
}

extension ReducerUseCasesView {
    struct CountState {
        var count: Int = 0
    }
    
    enum CountAction {
        case increase
        case decrease
    }
    
    func countReducer(state: inout CountState, action: CountAction) {
        switch action {
        case .increase:
            state.count += 1
        case .decrease:
            state.count -= 1
        }
    }

    func ReducerCounterView() -> some View {
        let (useCountState, dispatch) = useReducer(CountState(), countReducer)
//        var count = defComputed(useCountState()) //TODO: - use computed or selector or snapshot
        
        return View {
            Text("the count = \(useCountState().count)")
            HStack {
                Button("+1") {
                    dispatch(.increase)
                }
                Button("-1") {
                    dispatch(.decrease)
                }
            }
        }
    }
}

