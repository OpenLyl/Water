//
//  ComputedUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct ComputedUseCasesView: View {
    var body: some View {
        FilterNumbersView()
    }
}

extension ComputedUseCasesView {
    struct NormalCounterView: View {
        @State private var count = 0
        @State private var name = ""

        var nameBinding: Binding<String> {
            Binding {
                name
            } set: { newValue in
                name = newValue
            }
        }

        var body: some View {
            print("body comes in ...")
            return VStack {
                Text("the count = \(count)")
                Button("click me") {
                    count += 1
                }
                Text("the name = \(name)")
                TextField("name", text: nameBinding)
            }
            .onAppear {
                countChange()
//                countNotChange()
            }
        }

        func countChange() {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                print("support batch update state - 1")
                count += 1
                name = "new name \(count)"
                print("support batch update state - 2")
            }
        }

        func countNotChange() {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                print("support batch update state - 1")
                count = 0
                print("support batch update state - 2")
            }
        }
    }
}

extension ComputedUseCasesView {
    func FilterNumbersView() -> some View {
        let showEven = defValue(false)
        let items = defReactive([1, 2, 3, 4, 5, 6])
        
        let evenNumbers = defComputed {
            items.filter { !showEven.value || $0 % 2 == 0}
        }
        
        return View {
            VStack {
                Toggle(isOn: showEven.bindable) {
                    Text("Only show even numbers")
                }
                Button("dynamic insert num") {
                    let newNumbers = [7, 8, 9, 10]
                    items.append(contentsOf: newNumbers)
                }
            }
            .padding(.horizontal, 15)
            List(evenNumbers.value, id: \.self) { num in
                Text("the num = \(num)")
            }
        }
    }
}
