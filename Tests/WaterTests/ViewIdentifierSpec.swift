//
//  ViewIdentifierSpec.swift
//  Water
//

import Quick
import Nimble
@testable import Water

class ViewIdentifierSpec: QuickSpec {
    override class func spec() {
        it("check simple view") {
            let viewId = "CounterView()"
            let ok = checkIdentifier(identifier: viewId)
            expect(ok).to(equal(true))
        }
        
        it("check view has parameter") {
            let viewId = "LoginPage(mode:)"
            let ok = checkIdentifier(identifier: viewId)
            expect(ok).to(equal(true))
        }
    }
}
