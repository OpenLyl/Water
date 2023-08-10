//
//  ReactivityUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct ReactivityUseCasesView: View {
    var body: some View {
        ReactiveObjectView()
//        ReactiveCollectionView()
    }
}

extension ReactivityUseCasesView {
    struct User {
        var name: String = "123"
        var age: Int = 22
    }
}

extension ReactivityUseCasesView {
//    struct ReactiveObjectView: View {
//        @State private var user = User()
//
//        var body: some View {
//            VStack {
//                Text("user.name = \(user.name)")
//                Text("user.age = \(user.age)")
//                VStack {
//                    Button("change name") {
//                        user.name = "456"
//                    }
//                    Button("change age") {
//                        user.age = 34
//                    }
//                }
//                TextField("input your name", text: $user.name)
//            }
//        }
//    }
    
    func ReactiveObjectView() -> some View {
        let user = defReactive(User())
        
        return View {
            VStack {
                Text("user.name = \(user.name)")
                Text("user.age = \(user.age)")
                VStack {
                    Button("change name") {
                        user.name = "456"
                    }
                    Button("change age") {
                        user.age = 34
                    }
                }
                TextField("input your name", text: user.bindable.name)
            }
        }
    }
}

extension ReactivityUseCasesView {
//    struct ReactiveCollectionView: View {
//        @State private var index = 3
//        @State private var items = ["1", "2", "3"]
//
//        var body: some View {
//            VStack {
//                LazyVStack {
//                    ForEach(items, id: \.self) { item in
//                        Text("the item = \(item)")
//                    }
//                    Text("the joined value = \(items.joined(separator: "-|"))")
//                }
//                HStack(spacing: 16) {
//                    Button("add item") {
//                        index += 1
//                        items.append("\(index)")
//                    }
//                    Button("remove all") {
//                        index = 0
//                        items.removeAll()
//                    }
//                    Button("clean item") {
//                        index = 3
//                        items = ["1", "2", "3"]
//                    }
//                }
//            }
//        }
//    }
    
    func ReactiveCollectionView() -> some View {
        let array = ["1", "2", "3"]
        var nextIndex = array.count + 1
        let items = defReactive(array)

        return View {
            VStack {
                LazyVStack {
                    ForEach(items, id: \.self) { item in
                        Text("the item = \(item)")
                    }
                    Text("the joined value = \(items.joined(separator: "-|"))")
                }
                HStack(spacing: 16) {
                    Button("add item") {
                        nextIndex += 1
                        items.append("\(nextIndex)")
                    }
                    Button("remove all") {
                        nextIndex = 0
                        items.removeAll()
                    }
                    Button("clean item") {
                        nextIndex = 3
                        items.replace(with: ["1", "2", "3"])
                    }
                }
            }
        }
    }
}

// TODO: - reactive object collection
