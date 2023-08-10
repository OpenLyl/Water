//
//  ReactivitySpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

struct User {
    var age: Int
}

struct State {
    var count: Int
}

class ReactivitySpec: QuickSpec {
    override class func spec() {
        describe("define value") {
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
            
            it("new") {
                let age = 123
                expect(age).to(equal(123))
            }
        }
        
        describe("define reactive") {
            it("happy path") {
                let origin = User(age: 10)
                
                let user = defReactive(origin)
                
                expect(user).to(beAKindOf(ReactiveObject<User>.self))
                expect(origin).notTo(beAKindOf(ReactiveObject<User>.self))
                expect(user.age).to(equal(10))
            }
        }
        
        describe("define effect") {
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
                
//                stop(state, runner)
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
                
//                stop(state, runner)
                stop(runner)
                expect(stopCalled).to(equal(true))
                expect(dummy).to(equal(1))
            }
        }
        
        describe("define reactive array") {
            it("happy path") {
                let list = defReactive(["hello"])
                var dummy = ""
                
                defEffect {
                    dummy = list.joined(separator: " ")
                }
                expect(dummy).to(equal("hello"))
                
                list.append("world")
                expect(dummy).to(equal("hello world"))
                
                list.append("hello!")
                expect(dummy).to(equal("hello world hello!"))
                
                list.removeAll()
                expect(dummy).to(equal(""))
            }
        }
        
        describe("define watch") {
            it("watch effect") {
                var dummy: Int? = nil
                let state = defReactive(State(count: 0))
                
                defWatchEffect { _ in
                    dummy = state.count
                }
                expect(dummy).to(equal(0))
                
                state.count += 1
                expect(dummy).to(equal(1))
            }
            
            it("clean up registration (effect)") {
                var dummy = 0
                var cleanupCallNum = 0
                func cleanup() {
                    cleanupCallNum += 1
                }
                let state = defReactive(State(count: 0))
                let stopWatch = defWatchEffect { onCleanup in
                    onCleanup(cleanup)
                    dummy = state.count
                }
                expect(dummy).to(equal(0))
                
                state.count += 1
                expect(cleanupCallNum).to(equal(1))
                expect(dummy).to(equal(1))
                
                stopWatch()
                expect(cleanupCallNum).to(equal(2))
            }
            
            it("watch single value") {
                var dummy: (Int, Int)? = nil
                let count = defValue(0)
                
                defWatch(count) { count, prevCount, _ in
                    dummy = (count, prevCount)
                }
                
                count.value += 1
                expect(dummy).to(equal((1, 0)))
            }
            
            it("cleanup registration (with value source)") {
                var dummy = 0
                let count = defValue(0)
                
                var cleanupCallNum = 0
                func cleanup() {
                    cleanupCallNum += 1
                }
            
                let stopWatch = defWatch(count) { count, prevCount, onCleanup in
                    onCleanup(cleanup)
                    dummy = count
                }
                
                count.value += 1
                expect(cleanupCallNum).to(equal(0))
                expect(dummy).to(equal(1))
                
                count.value += 1
                expect(cleanupCallNum).to(equal(1))
                expect(dummy).to(equal(2))
                
                stopWatch()
                expect(cleanupCallNum).to(equal(2))
            }
            
            it("watch object property") {
                var dummy: (Int, Int)? = nil
                let state = defReactive(State(count: 0))
                
                defWatch(state, at: \.count) { count, prevCount, _ in
                    dummy = (count, prevCount)
                }
                
                state.count += 1
                expect(dummy).to(equal((1, 0)))
            }
            
            it("watch obj property using closure") {
                var dummy = 0
                let state = defReactive(State(count: 10))
                
                defWatch {
                    state.count
                } onChange: { value, oldValue, _ in
                    dummy = value
                }
                expect(dummy).to(equal(0))
                
                state.count = 1
                expect(dummy).to(equal(1))
            }
            
            it("watch reactive object deeply") {
                var dummy: Int? = nil
                let state = defReactive(State(count: 0))
                defWatch(state) { state, _, _ in
                    dummy = state.count
                }
                state.count += 1
                expect(dummy).to(equal(1))
            }
            
            it("watch array") {
                var dummy = 0
                let array = defReactive([] as [Int])
                defWatch(array) { value, oldValue, _ in
                    dummy += 1
                    expect(oldValue).to(equal([]))
                    expect(value).to(equal([1]))
                }
                array.append(1)
                expect(dummy).to(equal(1))
            }
        
            it("watch multiple sources") {
                var dummyA = ""
                var dummyB = 0

                let name = defValue("hello")
                let state = defReactive(State(count: 0))
//                let countWatchable = defWatchable(state, at: \.count)
                let countWatchable = defWatchable {
                    state.count
                }
                
                // FIXME: - can support defWatchTwo((name, countWatchable)) { (name, count), (oldName, oldCount) in } ?
                
                defWatch((name, countWatchable)) { values, oldValues in
                    let (name, count) = values
                    let (oldName, oldCount) = oldValues
                    
                    expect(oldName).to(equal("hello"))
                    expect(oldCount).to(equal(0))

                    dummyA = name
                    dummyB = count
                }
                
                expect(dummyA).to(equal(""))
                expect(dummyB).to(equal(0))

                name.value = "world"
                state.count = 10

                expect(dummyA).to(equal("world"))
                expect(dummyB).to(equal(10))
            }
        }
        
        describe("define computed") {
            it("happy path") {
                let state = defReactive(State(count: 1))
                
                let computedValue = defComputed {
                    state.count
                }
                
                state.count = 2
                expect(computedValue.value).to(equal(2))
            }
            
            it("should computed lazy") {
                var callNum = 0
                
                let state = defReactive(State(count: 1))
                
                func valueGetter() -> Int {
                    callNum += 1
                    return state.count
                }
                
                let computedValue = defComputed(valueGetter)
                
                expect(callNum).to(equal(0))

                expect(computedValue.value).to(equal(1))
                expect(callNum).to(equal(1))

                let _ = computedValue.value;
                expect(callNum).to(equal(1))

                state.count = 2
                expect(callNum).to(equal(1))

                expect(computedValue.value).to(equal(2))
                expect(callNum).to(equal(2))

                let _ = computedValue.value;
                expect(callNum).to(equal(2))
            }
            
            it("should trigger effect") {
                let state = defReactive(State(count: 1))
                let computedValue = defComputed {
                    state.count
                }
                
                var dummy = 0
                defEffect {
                    dummy = computedValue.value
                }
                expect(dummy).to(equal(1))
                
                state.count = 2 // -> trigger computed inner effect -> trigger computed track effect
                expect(dummy).to(equal(2))
            }
        }
    }
}
