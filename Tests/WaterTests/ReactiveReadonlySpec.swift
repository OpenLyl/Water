//
//  ReactiveReadonlySpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class ReactiveReadonlySpec: QuickSpec {
    override class func spec() {
        describe("readonly / object") {
            it("happy path") {
                let origin = User(age: 10)
                
                let user = defReadonly(origin)
                
                expect(origin).notTo(beAKindOf(ReactiveObject<User>.self))
                expect(user).to(beAKindOf(ReactiveObject<User>.self))
                expect(user.age).to(equal(10))
            }
            
            it("when set property has assert") {
                let user = defReadonly(User(age: 10))
                expect(user.age).to(equal(10))
                expect { user.age = 11 }.to(throwAssertion())
            }
            
            it("check reactive object readonly") {
                let user = defReadonly(User(age: 10))
                expect(user.isReadonly).to(equal(true))
            }
            
            it("check reactive object reactive, not readonly") {
                let user = defReactive(User(age: 10))
                expect(user.isReadonly).to(equal(false))
                expect(user.isReactive).to(equal(true))
            }
        }
        
        describe("readonly / array") {
            it("when change array has assert") {
                let array = defReadonly([1, 2, 3])
                expect(array).to(beAKindOf(ReactiveArray<Int>.self))
                expect(array[0]).to(equal(1))
                expect(array[1]).to(equal(2))
                expect(array[2]).to(equal(3))
                expect { array.append(4) }.to(throwAssertion())
            }
            
            it("check reactive array readonly") {
                let array = defReadonly([1, 2, 3])
                expect(array.isReadonly).to(equal(true))
            }
        }
    }
}
