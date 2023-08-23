//
//  EffectSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class EffectSpec: QuickSpec {
    override class func spec() {
        it("happy path") {
            let user = defReactive(User(age: 10))
            var nextAge: Int = 0
            
            defEffect {
                nextAge = user.age + 1
            }
            
            expect(nextAge).to(equal(11))
            
            user.age += 1
            expect(nextAge).to(equal(12))
        }
        
        it("change struct object target") {
            let origin = User(age: 10)
            let user = defReactive(origin)
            var age = 0
            var age1 = 1
            var callNum = 0
            
            defEffect {
                callNum += 1
                age = user.target.age + 1
                age1 = user.age + 1
            }
            
            expect(callNum).to(equal(1))
            expect(age).to(equal(11))
            expect(age1).to(equal(11))
            
            user.target = User(age: 11)
            expect(callNum).to(equal(2))
            expect(age).to(equal(12))
            expect(age1).to(equal(12))
        }
        
        it("effect with change nested object property") {
            let foo = Foo(bar: "bar", user: User(age: 10))
            let observed = defReactive(foo)
            
            var age = 0
            var callNum = 0
            defEffect {
                callNum += 1
                age = observed.user.age
            }
            
            expect(callNum).to(equal(1))
            expect(age).to(equal(10))
            
            observed.user.age = 11
            expect(callNum).to(equal(2))
            expect(age).to(equal(11))
        }
        
        it("effect return runner") {
            var foo = 10
            
            let runner = defEffect {
                foo += 1
                return "foo"
            }
            
            expect(foo).to(equal(11))
            
            let res = runner.run();
            expect(foo).to(equal(12))
            expect(res).to(equal("foo"))
        }
        
        it("run effect use scheduler") {
            var dummy: Int = 0
            var scheduleCallNum = 0
            
            var effectRunner: ReactiveEffectRunner<()>!
            var scheduleRunner: ReactiveEffectRunner<()>!
            
            let user = defReactive(User(age: 10))
            
            effectRunner = defEffect {
                dummy = user.age
            } scheduler: {
                scheduleCallNum += 1
                doCustomJob()
            }
            
            func doCustomJob() {
                scheduleRunner = effectRunner
            }
            
            expect(dummy).to(equal(10))
            expect(scheduleCallNum).to(equal(0))
            
            user.age += 1
            expect(dummy).to(equal(10))
            expect(scheduleCallNum).to(equal(1))
            
            scheduleRunner.run()
            expect(dummy).to(equal(11))
        }
        
        it("can stop") {
            var dummy = 0
            let state = defReactive(State(count: 1))
            let runner = defEffect {
                dummy = state.count
            }
            
            state.count = 2
            expect(dummy).to(equal(2))
            
            runner.stop()
            state.count = 3
            expect(dummy).to(equal(2))
            
            state.count += 1
            expect(dummy).to(equal(2))
            
            runner.run()
            expect(dummy).to(equal(4))
        }
        
        it ("on stop") {
            var dummy = 0
            var stopCalled = false
            
            let state = defReactive(State(count: 1))
            let runner = defEffect {
                dummy = state.count
            } onStop: {
                stopCalled = true
            }
            
            expect(dummy).to(equal(1))
            
            stop(runner)
            expect(stopCalled).to(equal(true))
            expect(dummy).to(equal(1))
        }
        
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
