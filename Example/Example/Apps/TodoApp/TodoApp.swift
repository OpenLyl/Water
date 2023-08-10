//
//  TodoApp.swift
//  Example
//

import SwiftUI
import Water

//@main
//struct TodoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                TodoMainPage()
////                UnderstandBindingView()
//                    .navigationTitle("Todo App")
//                    .navigationBarTitleDisplayMode(.inline)
//            }
//        }
//    }
//}

// binding 是一种双向赋值的行为
// binding 不会触发调用 body
struct UnderstandBindingView: View {
    @State private var count = 0
    @State private var isOn = false

    var body: some View {
        print("main update view")
        return
            VStack {
                Text("count = \(count)")
                Button("add count") {
//                    count += 1
                    print("add count comes in ...")
                    isOn.toggle()
                }
                BindingChildView(isOn: $isOn)
            }
    }
}

struct BindingChildView: View {
    @Binding var isOn: Bool

    var body: some View {
        print("child update view")
        return VStack {
            Toggle(isOn: $isOn) {
                Text("Toggle")
            }
            .padding()
            Button("change") {
                isOn.toggle()
            }
        }
    }
}
