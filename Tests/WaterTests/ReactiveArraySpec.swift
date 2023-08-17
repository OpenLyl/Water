//
//  ReactiveArraySpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class ReactiveArraySpec: QuickSpec {
    override class func spec() {
        it("array should be reactive") {
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
}