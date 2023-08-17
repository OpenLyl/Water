//
//  ComputedSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class ComputedSpec: QuickSpec {
    override class func spec() {
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
