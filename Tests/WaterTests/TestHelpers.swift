//
//  TestHelpers.swift
//  Water
//

@testable import Water

struct User {
    var age: Int
}

struct State {
    var count: Int
}

struct OptionalUser {
    let userID: Int? = 0
    var uname: String?
    var age: Int?
}

class ClassUser {
    let uname: String
    var age: Int
    
    init(uname: String, age: Int) {
        self.uname = uname
        self.age = age
    }
}

struct Foo {
    let bar: String
    var user: User
}

struct NestedReactiveFoo {
    let bar: String
    let user: ReactiveObject<User>
    let array: ReactiveArray<Int>
}
