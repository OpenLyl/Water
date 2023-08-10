//
//  WatchUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct WatchUseCasesView: View {
    var body: some View {
//        WatchCounterView()
//        WatchEffectView()
        WatchCleanupView()
    }
}

extension WatchUseCasesView {
    func WatchCounterView() -> some View {
        let count = defValue(0)
        
        defWatch(count) { oldCount, newCount, _ in
            print("the old count = \(oldCount)")
            print("the new count = \(newCount)")
        }
        
        return View {
            Text("count = \(count.value)")
            Button("increment") {
                count.value += 1
            }
            Button("decrement") {
                count.value -= 1
            }
        }
    }
}

extension WatchUseCasesView {
    func WatchEffectView() -> some View {
        let count = defValue(0)
        let name = defValue("hello world")
        
        defWatchEffect { _ in
            print("trigger watch effect")
        }
        
        defWatch(name) { value, oldValue, _ in
            print("name changed = \(value), old name = \(oldValue)")
        }
        
        return View {
            Text("the count = \(count.value)")
            Button("click me") {
                count.value += 1
            }
            Text("the name = \(name.value)")
            TextField("name", text: name.bindable)
        }
    }
}

extension WatchUseCasesView {
    func WatchCleanupView() -> some View {
        let count = defValue(0)
        let name = defValue("hello world")

        let stopWatch = defWatchEffect { onCleanup in
            print("effect comes in ..")
            let timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                print("timer comes in, change name before")
                name.value = "123"
                print("timer comes in, change name end")
            }
            
            let cleanup = {
                print("cleanup timer comes in ...")
                timer.invalidate()
            }
            onCleanup(cleanup)
        }
        
        return View {
            Text("the count = \(count.value)")
            Button("click me") {
                count.value += 1
            }
            Text("the name = \(name.value)")
            TextField("name", text: name.bindable)
            Button("stop watch") {
                stopWatch()
            }
        }
    }
}

// TODO: - add user validation use watch
