//
//  ReactivityUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct ReactivityUseCasesView: View {
    var body: some View {
//        ReactiveObjectView()
//        ReactiveCollectionView()
//        ReactiveArrayForEachView()
//        ReactiveArraySelectionView()
        CustomSelectionView()
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

extension ReactivityUseCasesView {
//    struct ReactiveArrayForEachView: View {
//        @State private var items = ["1", "2", "3"]
//        
//        var body: some View {
//            VStack {
//                ForEach(items, id: \.self) { item in
//                    Text("item value = \(item)")
//                }
//                Button("replace") {
//                    items = ["4", "5", "6"]
//                }
//                Button("clear items") {
//                    items.removeAll()
//                }
//            }
//        }
//    }

    func ReactiveArrayForEachView() -> some View {
        let items = defReactive(["1", "2", "3"])
        
        return View {
            VStack {
                ForEach(items, id: \.self) { item in
                    Text("item value = \(item)")
                }
                Button("replace") {
                    items.replace(with: ["4", "5", "6"])
                }
                Button("clear items") {
                    items.removeAll()
                }
            }
        }
    }
}

// TODO: - reactive object array collection

struct Ocean: Identifiable, Hashable {
    let id: String
    let name: String
}

// has bug in iOS 15
extension ReactivityUseCasesView {
    struct ReactiveArraySelectionView: View {
        @State private var oceans = [
            Ocean(id: "1", name: "Pacific"),
            Ocean(id: "2", name: "Atlantic"),
            Ocean(id: "3", name: "Indian"),
            Ocean(id: "4", name: "Southern"),
            Ocean(id: "5", name: "Arctic")
        ]
        
//        @State private var singleSelection: String?
        @State private var selectedOcean: Ocean? = nil
        
        var body: some View {
            List(selection: $selectedOcean) {
                Button("abc") { }.background(Color.purple)
                ForEach(oceans) { ocean in
                    HStack {
                        Text(ocean.name)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 40)
                    .background((ocean.id == selectedOcean?.id) ? Color.red : Color.clear)
                    .padding(.horizontal, 15)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
        }
    }
    
//    func ReactiveArraySelectionView() -> some View {
//        let array =  [
//            Ocean(id: "1", name: "Pacific"),
//            Ocean(id: "2", name: "Atlantic"),
//            Ocean(id: "3", name: "Indian"),
//            Ocean(id: "4", name: "Southern"),
//            Ocean(id: "5", name: "Arctic")
//        ]
//        let oceans = defReactive(array)
//        
//        let singleSelection = defValue(nil as String?)
//        
//        return View {
//            List(selection: singleSelection.bindable) {
//                Button("abc") { }.background(Color.purple)
//                ForEach(oceans) { ocean in
//                    HStack {
//                        Text(ocean.name)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .frame(height: 40)
//                    .background(ocean.id == singleSelection.value ? Color.red : Color.clear)
//                    .padding(.horizontal, 15)
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(.init())
//                    .listRowBackground(Color.clear)
//                }
//            }
//            .listStyle(.plain)
//        }
//    }
}

extension ReactivityUseCasesView {
    struct CustomSelectionView: View {
        @State private var oceans = [
            Ocean(id: "1", name: "Pacific"),
            Ocean(id: "2", name: "Atlantic"),
            Ocean(id: "3", name: "Indian"),
            Ocean(id: "4", name: "Southern"),
            Ocean(id: "5", name: "Arctic")
        ]
        
        @State private var singleSelection: String?
        
        func changeSelection(id: String) {
            singleSelection = id
        }
        
        var body: some View {
//            List(selection: $singleSelection) {
//                Button("abc") { }.background(Color.purple)
                ForEach(oceans) { ocean in
                    Button {
                        changeSelection(id: ocean.id)
                    } label: {
                        HStack {
                            Text(ocean.name)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 40)
                    .background(ocean.id == singleSelection ? Color.red : Color.clear)
                    .padding(.horizontal, 15)
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(.init())
//                    .listRowBackground(Color.clear)
                }
//            }
//            .listStyle(.plain)
        }
    }
}

#Preview {
    ReactivityUseCasesView()
}
