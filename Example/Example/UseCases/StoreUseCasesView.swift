//
//  StoreUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct StoreUseCasesView: View {
    var body: some View {
        CounterStoreView()
    }
}

typealias CounterStoreType = () -> (count: ReactiveValue<Int>, increment: () -> Void, decrement: () -> Void)

let useCounterStore: CounterStoreType = useStore("counter") {
    let count = defValue(0)

    func increment() {
        count.value += 1
    }

    func decrement() {
        count.value -= 1
    }

    return (
        count: count,
        increment: increment,
        decrement: decrement
    )
}

extension StoreUseCasesView {
    func CounterStoreView() -> some View {
        let counterStore = useCounterStore()
        
        return View {
            Text("the count = \(counterStore.count.value)")
            Button("increment") {
                counterStore.increment()
            }
            Button("decrement") {
                counterStore.decrement()
            }
        }
    }
}
