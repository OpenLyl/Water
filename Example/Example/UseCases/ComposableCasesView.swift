//
//  ComposableCasesView.swift
//  Example
//

import SwiftUI
import Water

struct ComposableCasesView: View {
    var body: some View {
        ComposableDefUserView()
    }

    struct User {
        var name: String = "123"
        var age: Int = 22
    }

    func defUser() -> (ReactiveObject<User>, (String) -> Void, (Int) -> Void) {
        let user = defReactive(User())

        let setName = { name in
            user.name = name
        }

        let setAge = { age in
            user.age = age
        }

        return (user, setName, setAge)
    }

    func ComposableDefUserView() -> some View {
        typealias SetNameFunc = (String) -> Void
        typealias SetAgeFunc = (Int) -> Void

        let (user, setName, setAge) = defUser()

        return View {
            VStack {
                HStack {
                    Text("user.name = \(user.name)")
                    Text("user.age = \(user.age)")
                }
                VStack {
                    Button("change name") {
                        setName("456")
                    }
                    Button("change age") {
                        setAge(123)
                    }
                }
                TextField("input your name", text: user.bindable.name)
            }
        }
    }
}
