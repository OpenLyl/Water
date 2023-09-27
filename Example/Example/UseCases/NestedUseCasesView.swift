//
//  NestedUseCasesView.swift
//  Example
//

import SwiftUI
import Water

struct NestedUseCasesView: View {
    var body: some View {
//        ParentView()
        MyListView()
//        CheckKeepStateParentView()
//        NestedLazyVGridView()
    }
}

extension NestedUseCasesView {
    func ParentView() -> some View {
        let name = defValue("hello world")
        let nums = defReactive([] as [Int])
        
        return View {
            VStack {
                Text("the name = \(name.value)")
                ChildView(nums: nums.array)
                MyListView()
                Button("change array") {
                    nums.replace(with: [1, 2, 3, 4, 5])
                }
            }
        }
    }

    func ChildView(nums: [Int]) -> some View {
        ScrollView {
            ForEach(nums, id: \.self) { number in
                Text("the number = \(number)")
            }
        }
    }
    
    
//    struct MyListView: View {
//        @State private var items: [String] = []
//        @State private var singleSelection: String? = nil
//    
//        @Sendable func loadData() async {
//            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
//            items = ["1", "2", "3"]
//        }
//    
//        func handleSelectionChange(item: String) {
//            singleSelection = item
//        }
//    
//        var body: some View {
//            let _ = print("my list view before")
//            VStack {
//                ForEach(items, id: \.self) { item in
//                    MyListItemView(item: item, isSelected: singleSelection == item) {
//                        handleSelectionChange(item: item)
//                    }
//                }
//            }
//            .onAppear {
//                Task {
//                    await loadData()
//                }
//            }
//            let _ = print("my list view after")
//        }
//    }

    struct MyListItemView: View {
        let item: String
        let isSelected: Bool
        let onSelectChange: () -> Void
        
        var body: some View {
            let _ = print("my list item view before")
            Button(action: onSelectChange) {
                Text(item)
                    .foregroundStyle(.green)
                    .font(.largeTitle)
                    .frame(width: 300, height: 100)
            }
            .background(isSelected ? Color.blue : Color.red)
            let _ = print("my list item view after")
        }
    }

    // FIXME: - try use observation how to handle the problem
    func MyListView() -> some View {
        let items = defReactive([] as [String])
        let singleSelection = defValue(nil as String?)
        
        func changeItems() {
            items.replace(with: ["1", "2", "3"])
        }
        
        @Sendable func loadData() async {
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            items.replace(with: ["1", "2", "3"])
        }
        
        func handleSelectionChange(item: String) {
            singleSelection.value = item
        }
        
        onMounted {
            Task {
                await loadData()
            }
        }
        
        return View {
            VStack {
                let _ = singleSelection.value // force track FIXME: - 1. wrap a view for force track effect 2. add force track ForEach implements
//                List(selection: singleSelection.bindable) {
                    ForEach(items.array, id: \.self) { item in
                        MyListItemView(item: item, isSelected: singleSelection.value == item) {
                            handleSelectionChange(item: item)
                        }
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(.init())
//                        .listRowBackground(Color.clear)
                    }
//                }
//                .listStyle(.plain)
                Button("change") {
                    changeItems()
                }
            }
        }
    }
    
//    func MyListItemView(item: String, @Binding selection: String?) -> some View {
//        let isSelected = defValue(item == selection)
//        
//        func handleSelectionChange() {
//            selection = item
//        }
//        
//        return View {
//            Button(action: handleSelectionChange) {
//                Text(item)
//                    .foregroundStyle(.green)
//                    .font(.largeTitle)
//                    .frame(width: 300, height: 100)
//            }
//            .background(isSelected ? Color.blue : Color.red)
//        }
//        let item: String
//        let isSelected: Bool
//        let onSelectChange: () -> Void
//        
//        var body: some View {
//            let _ = print("my list item view before")
//            
//            let _ = print("my list item view after")
//        }
//    }
   
}

extension NestedUseCasesView {
//    struct CheckKeepStateParentView: View {
//        @State private var parentName = "456"
//        
//        var body: some View {
//            let _ = print("new demo view before render")
//            VStack {
//                Text("demo name = \(parentName)")
//                CheckKeepStateChildView()
//                Button("change demo") {
//                    parentName = "789"
//                }
//            }
//            let _ = print("new demo view after render")
//        }
//    }
//
//    struct CheckKeepStateChildView: View {
//        @State private var childName = "123"
//        
//        var body: some View {
//            let _ = print("a test view before render")
//            VStack {
//                Text("name = \(childName)")
//                Button("change a test") {
//                    childName = "- 123 -"
//                }
//            }
//            let _ = print("a test view after render")
//        }
//    }
    
    func CheckKeepStateParentView() -> some View {
        let parentName = defValue("456")
        
        return View {
            VStack {
                Text("demo name = \(parentName.value)")
                memo { CheckKeepStateChildView() }
                Button("change demo") {
                    parentName.value = "789"
                }
            }
        }
    }
    
    func CheckKeepStateChildView() -> some View {
        let childName = defValue("123")
        
        return View {
            VStack {
                Text("name = \(childName.value)")
                Button("change a test") {
                    childName.value = "- 123 -"
                }
            }
        }
    }
}

extension NestedUseCasesView {
    struct DeviceInfo: Identifiable {
        let id = UUID()
        let name: String
    }
    
    func NestedLazyVGridView() -> some View {
        let name = defValue("")
        
        return View {
            Text("user name = \(name.value)")
            Button("change name") {
                name.value = "hello nested lazy VGrid"
            }
            memo { DeviceInfoGridView() }
        }
    }
    
    func DeviceInfoGridView() -> some View {
        let devices = defReactive([] as [DeviceInfo])
        
        func handleChangeDevices() {
            let newDevices: [DeviceInfo] = [
                .init(name: "device 1"),
                .init(name: "device 2"),
                .init(name: "device 3")
            ]
            devices.replace(with: newDevices)
        }
        
        return View {
            Button("change devices", action: handleChangeDevices)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 50) {
                ForEach(devices) { device in
                    Text(device.name)
                        .background(Color.purple)
                        .frame(width: 100, height: 100)
                        .background(Color.red)
                }
            }
        }
    }
}
