//
//  ReactiveValueSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.age == rhs.age
    }
}

class ReactiveValueSpec: QuickSpec {
    override class func spec() {
        it("should hold a value") {
            let a = defValue(1)
            expect(a.value).to(equal(1))
            a.value = 2
            expect(a.value).to(equal(2))
        }
        
        it("should be reactive") {
            let a = defValue(1)
            var b = 0
            var callNum = 0
            
            defEffect { // 1. store current effect
                callNum += 1
                b = a.value // 2. when get value save current effect to ref value
            }
            
            expect(callNum).to(equal(1))
            expect(b).to(equal(1))
            
            a.value = 2
            expect(callNum).to(equal(2))
            expect(b).to(equal(2))
        }
        
        it("nested struct object should reactive") {
            let user = defValue(User(age: 10))
            var dummy = 0
            var callNum = 0
            
            defEffect {
                callNum += 1
                dummy = user.value.age
            }
            
            expect(callNum).to(equal(1))
            expect(dummy).to(equal(10))
            
            user.value.age = 11
            expect(callNum).to(equal(2))
            expect(dummy).to(equal(11))
            
            user.value.age = 11
            expect(callNum).to(equal(2))
            expect(dummy).to(equal(11))
        }
        
        it("nested class object should not support") {
            expect { defValue(ClassUser(uname: "haha", age: 10)) }.to(throwAssertion())
        }
        
        it("object contains value property") {
//            struct Foo {
//                let name = defValue("hello")
//            }
//
//            let foo = defReactive(Foo())
//
//            expect(foo.name).to(equal("hello"))
            
//            foo.name = "123"
//            expect(foo.name).to(equal("123"))
        }
        
        it("value nested value") {
            let count = defValue(10)
            expect { defValue(count) }.to(throwAssertion())
        }
    }
}
