//
//  TourMainView.swift
//  Example
//

import SwiftUI
import Water

struct CounterFeature { }

extension CounterFeature {
    static func useCounter() -> (count: ReactiveValue<Int>, increment: () -> Void, decrement: () -> Void) {
        let count = defValue(0)
        func increment() {
            count.value += 1
        }
        func decrement() {
            count.value -= 1
        }
        return (count, increment, decrement)
    }
}

extension CounterFeature {
    static func useFact(count: ReactiveValue<Int>) -> (isFetching: ReactiveValue<Bool>, fact: ReactiveValue<String?>, ReactiveValue<FetchError?>, fetchFactFn: () -> Void) {
        let (isFetching, result, error, execute) = useFetch({ "http://www.numbersapi.com/\(count.value)" }, immediate: false)
        
        let fact = defValue(nil as String?)
        
        func fetchFact() {
            Task  {
                fact.value = nil
                await execute()
                fact.value = result.value?.mapString() // FIXME: - fact connect to result
            }
        }
        
        defWatch(count) { _, _, _ in
            fact.value = nil
        }
        
        return (isFetching, fact, error, fetchFact)
    }
}

extension CounterFeature {
    static func useTimer(count: ReactiveValue<Int>) -> (isTimerOn: ReactiveValue<Bool>, toggleTimer: () -> Void) {
        let isTimerOn = defValue(false)
        var timer: Timer?
        func toggleTimer() {
            if isTimerOn.value {
                if let timer {
                    timer.invalidate()
                }
            } else {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    count.value += 1
                }
            }
            isTimerOn.value.toggle()
        }
        
        // FIXME: - fix multiple time lifecycle hook
        onUnmounted {
            timer?.invalidate()
        }
        return (isTimerOn, toggleTimer)
    }
}


// MARK: - Render

extension CounterFeature {
    static func render() -> some View {
        // MARK: - count
        let (count, increment, decrement) = useCounter()
        
        // MARK: - fact
        let (isFetching, fact, error, fetchFact) = useFact(count: count)
        var isLoadingFact: Bool {
            isFetching.value
        }
        
        // MARK: - timer
        let (isTimerOn, toggleTimer) = useTimer(count: count)
        
        return View {
            Form {
                Section {
                    Text("\(count.value)")
                    Button("increment") {
                        increment()
                    }
                    Button("decrement") {
                        decrement()
                    }
                }
                Section {
                    Button {
                        fetchFact()
                    } label: {
                        HStack {
                            Text("Get fact")
                            if isLoadingFact {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    if let fact = fact.value {
                        Text(fact)
                    }
                    if let error = error.value, let errorMsg = error.errorDescription {
                        Text(errorMsg)
                    }
                }
                Section {
                    Button(isTimerOn.value ? "Stop timer" : "Start timer") {
                        toggleTimer()
                    }
                }
            }
        }
    }
}
