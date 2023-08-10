//
//  SearchIdentifierCasesView.swift
//  Example
//

import SwiftUI
import Water

struct SearchIdentifierCasesView: View {
    var body: some View {
//        NestedSearchIdentifierCasesView()
        NestedHooksSearchIdentifierCaseView()
    }
}

struct NestedSearchIdentifierCasesView: View {
    var body: some View {
        Level1View()
    }
    
    func Level1View() -> some View {
        Level2View()
    }
    
    func Level2View() -> some View {
        Level3View()
    }
    
    func Level3View() -> some View {
        let count = defValue(0)
        return View {
            Text("the count = \(count.value)")
            Button("change count") {
                count.value += 1
            }
        }
    }
}

struct NestedHooksSearchIdentifierCaseView: View {
    var body: some View {
        Level1View()
    }
    
    func Level1View() -> some View {
        Level2View()
    }
    
    func Level2View() -> some View {
        let name = defValue("123")
        return View {
            Level3View()
            Text("name = \(name.value)")
        }
    }
    
    func Level3View() -> some View {
        let count = defValue(0)
        return View {
            Text("the count = \(count.value)")
            Button("change count") {
                count.value += 1
            }
        }
    }
}
