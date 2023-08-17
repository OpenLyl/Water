//
//  ReactiveValueSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

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
    }
}
