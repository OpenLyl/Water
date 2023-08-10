//
//  UseCasesView.swift
//  Example
//

import SwiftUI

struct UseCasesView: View {
    var body: some View {
        //        TryTwoStateChangeView()
        NewView()
    }
}

struct TryTwoStateChangeView: View {
    @State private var count = 10
    @State private var name = "hello"

    var body: some View {
        print("body render comes in ...")
        return VStack {
            Text("the count = \(count)")
            Text("name = \(name)")
        }.onAppear {
            //            beginChangeState()
            newChangeState()
        }
    }

    func beginChangeState() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            print("begin change state")
            self.count += 1
            print("begin change state - 1")
            self.name = "\(name) - \(count)"
            print("begin change state - 2")
        }
    }

    func newChangeState() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            print("count will change")
            self.count += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                print("name will change")
                self.name = "the name count = \(count)"
            }
        }
    }
}

class NewViewModel: ObservableObject {
    @Published var count = 10
    @Published var name = "hello"

    func changeSameTime() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            print("begin change state")
            self.count += 1
            print("begin change state - 1")
            self.name = "\(self.name) - \(self.count)"
            print("begin change state - 2")
        }
    }

    func changeStepByStep() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            print("count will change")
            self.count += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                print("name will change")
                self.name = "the name count = \(self.count)"
            }
        }
    }
}

struct NewView: View {
    @StateObject var vm = NewViewModel()

    var body: some View {
        print("body render comes in ...")
        return VStack {
            Text("the count = \(vm.count)")
            Text("name = \(vm.name)")
        }.onAppear {
//            vm.changeSameTime()
//            vm.changeStepByStep()
            testContact()
        }
    }

    func testContact() {
        let john = Contact(name: "John Appleseed", age: 24)
        let _ = john.objectWillChange
            .sink { _ in
                print("\(john.age) will change")
            }
        print(john.haveBirthday())
        print(john.haveBirthday())
        // Prints "24 will change"
        // Prints "25"
    }
}

class Contact: ObservableObject {
    @Published var name: String
    @Published var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    func haveBirthday() -> Int {
        age += 1
        return age
    }
}

// struct User {
//    let name: String
//    let age: Int
// }
//
// func com(u1: User, u2: User) -> Bool {
//    return u1 == u2
// }

struct UseCasesView_Previews: PreviewProvider {
    static var previews: some View {
        UseCasesView()
    }
}
