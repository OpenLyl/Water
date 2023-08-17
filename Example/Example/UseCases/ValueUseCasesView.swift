//
//  ValueUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct ValueUseCasesView: View {
    var body: some View {
//        CounterView()
//        CounterNameView()
//        BooleanValueView()
//        ValueNotChangeView()
//        SimultaneousChangeValuesView()
        ShowPasswordView()
    }
}

extension ValueUseCasesView {
//    struct CounterView: View {
//        @State private var count = 0
//        
//        var body: some View {
//            Text("the count = \(count)")
//            HStack {
//                Button("increment") {
//                    count += 1
//                }
//                Button("decrement") {
//                    count -= 1
//                }
//            }
//        }
//    }
    
    func CounterView() -> some View {
        let count = defValue(0)
        
        return View {
            Text("the cont = \(count.value)")
            HStack {
                Button("increment") {
                    count.value += 1
                }
                Button("decrement") {
                    count.value -= 1
                }
            }
        }
    }
}

extension ValueUseCasesView {
//    struct CounterNameView: View {
//        @State private var count = 0
//        @State private var name = "hello world"
//        
//        var body: some View {
//            Text("the count = \(count)")
//            Button("click me") {
//                count += 1
//            }
//            Text("the name = \(name)")
//            TextField("name", text: $name)
//        }
//    }
    
    func CounterNameView() -> some View {
        let count = defValue(0)
        let name = defValue("hello world")
        
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

extension ValueUseCasesView {
//    struct BooleanValueView: View {
//        @State private var canShow = false
//        
//        var body: some View {
//            Text("is show value = \(String(canShow.value))")
//            Toggle("show", isOn: canShow.bindable)
//        }
//    }
    
    func BooleanValueView() -> some View {
        let canShow = defValue(false)
        
        return View {
            Text("is show value = \(String(canShow.value))")
            Toggle("show", isOn: canShow.bindable)
        }
    }
}

extension ValueUseCasesView {
//    struct ValueNotChangeView: View {
//        @State private var count = 0
//
//        func changeCountSameValue() {
//            count = 0
//        }
//
//        var body: some View {
//            let _ = Self._printChanges()
//            Text("the count = \(count)")
//            Button("change count") {
//                changeCountSameValue()
//            }
//        }
//    }
    
    func ValueNotChangeView() -> some View {
        let count = defValue(0)

        func changeCountSameValue() {
            count.value = 0
        }

        return View {
            Text("the count = \(count.value)")
            Button("change count") {
                changeCountSameValue()
            }
        }
    }
}

extension ValueUseCasesView {
//    struct SimultaneousChangeValuesView: View {
//        @State private var count = 0
//        @State private var name = ""
//
//        func batchUpdateValues() {
//            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//                print("batch update -> begin")
//                count += 1
//                name = "name-\(count)"
//                print("batch update -> end")
//            }
//        }
//
//        var body: some View {
//            let _ = Self._printChanges()
//            VStack {
//                Text("the count = \(count)")
//                Button("change count") {
//                    count += 1
//                }
//                Text("the name = \(name)")
//                TextField("name", text: $name)
//            }
//            .onAppear {
//                batchUpdateValues()
//            }
//        }
//    }
    
    func SimultaneousChangeValuesView() -> some View {
        let count = defValue(0)
        let name = defValue("")

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            print("batch update -> begin")
            count.value += 1
            name.value = "name-\(count.value)"
            print("batch update -> end")
        }

        return View {
            Text("the count = \(count.value)")
            Button("change count") {
                count.value += 1
            }
            Text("the name = \(name.value)")
            TextField("name", text: name.bindable)
        }
    }
}

extension ValueUseCasesView {
//    struct ShowPasswordView: View {
//        @State private var showPassword = false
//        let pwd = "123456"
//
//        var password: String {
//            if showPassword {
//                return pwd
//            } else {
//                return String(repeating: "*", count: pwd.count)
//            }
//        }
//
//        var body: some View {
//            VStack {
//                HStack {
//                    Text("password")
//                    Text(password)
//                }
//                Button("change show password") {
//                    showPassword.toggle()
//                }
//            }
//        }
//    }
    
    func ShowPasswordView() -> some View {
        let showPassword = defValue(false)
        let pwd = "123456"
        
        var password: String {
            if showPassword.value {
                return pwd
            } else {
                return String(repeating: "*", count: pwd.count)
            }
        }
        
        return View {
            VStack {
                HStack {
                    Text("password")
                    Text(password)
                }
                Button("change show password") {
                    showPassword.value.toggle()
                }
            }
        }
    }
}

struct ValueUseCasesView_Previews: PreviewProvider {
    static var previews: some View {
        ValueUseCasesView()
    }
}
