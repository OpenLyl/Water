//
//  WatchSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class WatchSpec: QuickSpec {
    override class func spec() {
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
}
