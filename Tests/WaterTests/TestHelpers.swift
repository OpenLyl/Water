//
//  TestHelpers.swift
//  Water
//

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
