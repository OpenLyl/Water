//
//  EffectSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class EffectSpec: QuickSpec {
    override class func spec() {
        describe("effect / effect scope") {
            it("should allow nested effects") {
                struct State {
                    var num1: Int
                    var num2: Int
                    var num3: Int
                }
                
                let nums = defReactive(State(num1: 0, num2: 1, num3: 2))
                var dummy = State(num1: -1, num2: -1, num3: -1)
                var parentCallNum = 0
                var childCallNum = 0
                
                let childRunner = defEffect {
                    childCallNum += 1
                    dummy.num1 = nums.num1
                }
                
                defEffect {
                    parentCallNum += 1
                    dummy.num2 = nums.num2
                    childRunner.run()
                    dummy.num3 = nums.num3
                }
                
                expect(dummy.num1).to(equal(0))
                expect(dummy.num2).to(equal(1))
                expect(dummy.num3).to(equal(2))
                expect(parentCallNum).to(equal(1))
                expect(childCallNum).to(equal(2))

                // this should only call the childeffect
                nums.num1 = 4
                expect(dummy.num1).to(equal(4))
                expect(dummy.num2).to(equal(1))
                expect(dummy.num3).to(equal(2))
                expect(parentCallNum).to(equal(1))
                expect(childCallNum).to(equal(3))
                
                // this calls the parenteffect, which calls the childeffect once
                nums.num2 = 10
                expect(dummy.num1).to(equal(4))
                expect(dummy.num2).to(equal(10))
                expect(dummy.num3).to(equal(2))
                expect(parentCallNum).to(equal(2))
                expect(childCallNum).to(equal(4))
                
                // this calls the parenteffect, which calls the childeffect once
                nums.num3 = 7
                expect(dummy.num1).to(equal(4))
                expect(dummy.num2).to(equal(10))
                expect(dummy.num3).to(equal(7))
                expect(parentCallNum).to(equal(3))
                expect(childCallNum).to(equal(5))
            }
        }
    }
}
