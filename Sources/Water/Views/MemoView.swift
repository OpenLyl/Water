//
//  MemoView.swift
//  Water
//

import SwiftUI

public typealias StateToPropsTansformer<S, P> = (S) -> P

func defaultTransformer<S>(state: S) -> S {
    return state
}

public func Memo<S, Content: View>(_ state: S, content: @escaping (S) -> Content) -> MemoView<S, Content> {
    return Memo(state, content: content, transfomer: defaultTransformer)
}

public func Memo<S, P, Content: View>(_ state: S, content: @escaping (P) -> Content, transfomer: (S) -> P) -> MemoView<P, Content> {
    let props = transfomer(state)
    return MemoView(props: props, content: content)
}

public struct MemoView<P, Content: View>: View, Equatable {
    let props: P
    let content: (P) -> Content
    
    public var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        content(props)
    }
    
    public static func == (lhs: MemoView<P, Content>, rhs: MemoView<P, Content>) -> Bool {
        return sameValue(lhs: lhs.props, rhs: rhs.props)
    }
}
