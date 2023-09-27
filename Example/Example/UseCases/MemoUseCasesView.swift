//
//  MemoCallbackView.swift
//  Example
//

import SwiftUI
import Water

struct MemoCallbackView: View {
    var body: some View {
        StatefulView()
    }
}

extension MemoCallbackView {
    func StatefulView() -> some View {
        let name = defValue("123")
        let age = defValue(0)
        
        // cache state and callback
        // compare props use EquatableView
        //    let data = useMemo(() -> age, [age])
        //    let changeAge = useCallback()
        
        return View {
            Text("the name = \(name.value)")
            TextField("name", text: name.bindable)
            StatelessView(age.value) {
                age.value += 1
            }
            // .memo()
        }
    }
    
    @ViewBuilder
    func StatelessView(_ age: Int, action: @escaping () -> Void) -> some View {
        Text("age = \(age)")
        Button("click") {
            action()
        }
    }
}

struct MemoUseCasesView: View {
    var body: some View {
//        RootView()
        ClosureDemo()
    }
}

struct Student {
    var name: String
    var age: Int
}

//struct RootView: View {
//    @State var student = Student(name: "water", age: 22)
//
//    var body: some View {
//        let _ = Self._printChanges()
//
//        VStack {
//            StudentNameView(name: student.name)
//            StudentAgeView(age: student.age)
//            Button("random age") {
//                student.age = Int.random(in: 0...99)
//            }
//        }
//    }
//}

//struct StudentNameView: View {
//    let name: String
//
//    var body: some View{
//        let _ = Self._printChanges()
//
//        Text(name)
//    }
//}

//struct StudentAgeView: View {
//    let age: Int
//
//    var body: some View {
//        let _ = Self._printChanges()
//
//        Text(age,format: .number)
//    }
//}

func RootView() -> some View {
    let student = defReactive(Student(name: "water", age: 22))
    
    return View {
        MemoStudentNameView(student: student.unwrap())
        TransformStudentNameView(student: student.unwrap())
        StudentNameView(name: student.name)
        StudentAgeView(age: student.age)
        Button("random age") {
            student.age = Int.random(in: 0...99)
        }
    }
}

func MemoStudentNameView(student: Student) -> some View {
    memo(student) { Text($0.name) }
}

func TransformStudentNameView(student: Student) -> some View {
    memo(student) { name in
        Text(name)
    } transfomer: { s in
        s.name
    }
}

func StudentNameView(name: String) -> some View {
    memo(name) { Text($0) }
}

func StudentAgeView(age: Int) -> some View {
    memo(age) { Text($0, format: .number) }
}

//class MyStore: ObservableObject {
//    @Published var selection: Int?
//
//    func sendID(_ id: Int) {
//        self.selection = id
//    }
//}
//
//struct ClosureDemo: View {
//    @StateObject var store = MyStore()
//
//    var body: some View {
//        let _ = Self._printChanges()
//        VStack {
//            if let currentID = store.selection {
//                Text("Current ID: \(currentID)")
//            }
//            List {
//                ForEach(0..<100) { index in
//                    CellView(id: index) {
//                        store.sendID(index)
//                    }
//                }
//            }
//            .listStyle(.plain)
//        }
//    }
//}
//
//struct CellView: View {
//    let id: Int
//    var action: () -> Void
//
//    init(id: Int, action: @escaping () -> Void) {
//        self.id = id
//        self.action = action
//    }
//
//    var body: some View {
//        VStack {
//            let _ = Self._printChanges()
//            Button("ID: \(id)") {
//                action()
//            }
//        }
//    }
//}

// 1. more use of binding
// 2. subview closure forbidden contains state change - change func ref only
// 3. pass func closure but compare not use it
func ClosureDemo() -> some View {
    let items = defReactive(Array(0..<100))
    let selection = defValue(-1)
    
    func changeSelection(i: Int) {
        selection.value = i
    }
    
    return View {
        VStack {
            Text("Current ID: \(selection.value)")
            List {
//                ForEach(items, id: \.self) { index in
//                    CellView(id: index, action: changeSelection)
//                }
                ForEach(items, id: \.self) { index in
                    CellView(id: index) {
                        selection.value = index
                    }
                }
//                ForEach(items, id:\.self) { index in
//                    BindingCellView(id: index, $selection: selection.bindable)
//                }
            }
            .listStyle(.plain)
        }
    }
}

// FIXME: - change binding no effect problem
func BindingCellView(id: Int, @Binding selection: Int) -> some View {
    memo(id) { id in
        VStack {
            Button("ID: \(id)") {
                selection = id
            }
        }
    }
}

func CellView(id: Int, action: @escaping () -> Void) -> some View {
    memo(id) { id in
        VStack {
            let _ = print("update \(id)")
            Button("ID: \(id)") {
                action()
            }
        }
    }
}

func CellView(id: Int, action: @escaping (Int) -> Void) -> some View {
    memo(id) { id in
        VStack {
            let _ = print("update \(id)")
            Button("ID: \(id)") {
                action(id)
            }
        }
    }
}
