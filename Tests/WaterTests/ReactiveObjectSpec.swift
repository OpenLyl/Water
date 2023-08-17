//
//  ReactiveObjectSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class ReactiveObjectSpec: QuickSpec {
    override class func spec() {
        it("happy path struct") {
            let origin = User(age: 10)
            
            let user = defReactive(origin)
            
            expect(origin).notTo(beAKindOf(ReactiveObject<User>.self))
            expect(user).to(beAKindOf(ReactiveObject<User>.self))
            expect(user.age).to(equal(10))
        }
        
        it("optional property with keypath") {
            let optionalUser = OptionalUser(uname: "abc", age: 12)
            let user = defReactive(optionalUser)
            
            let userIDKeyPath = \OptionalUser.userID
            expect(userIDKeyPath).to(beAKindOf(KeyPath<OptionalUser, Int?>.self))
            let unameKeyPath = \OptionalUser.uname
            expect(unameKeyPath).to(beAKindOf(WritableKeyPath<OptionalUser, String?>.self))
            let ageKeyPath = \OptionalUser.age
            expect(ageKeyPath).to(beAKindOf(WritableKeyPath<OptionalUser, Int?>.self))
            
            expect(user.userID).to(equal(0))
            expect(user.uname).to(equal("abc"))
            expect(user.age).to(equal(12))
            
            user.age = 22
            expect(user.age).to(equal(22))
        }
        
        it("class property with keypath") {
            let clsUser = ClassUser(uname: "abc", age: 12)
            let user = defReactive(clsUser)
            
            let b = \ClassUser.age
            expect(b).to(beAKindOf(ReferenceWritableKeyPath<ClassUser, Int>.self))
            expect(user.uname).to(equal("abc"))
            expect(user.age).to(equal(12))
            
            user.age = 22
            expect(user.age).to(equal(22))
        }
    }
}
