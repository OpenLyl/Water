//
//  MemoView.swift
//  Water
//

import SwiftUI

public typealias StateToPropsTansformer<S, P> = (S) -> P

public struct MemoPropsView<P, Content: View>: View, Equatable {
    let props: P
    let content: (P) -> Content
    
    public var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        content(props)
    }
    
    public static func == (lhs: MemoPropsView<P, Content>, rhs: MemoPropsView<P, Content>) -> Bool {
        return sameValue(lhs: lhs.props, rhs: rhs.props)
    }
}

public struct MemoEmptyPropsView<Content: View>: View {
    let content: () -> Content
    
    public var body: some View {
        content()
    }
}

func defaultTransformer<S>(state: S) -> S {
    return state
}

public func memo<S, Content: View>(_ state: S, content: @escaping (S) -> Content) -> MemoPropsView<S, Content> {
    return memo(state, content: content, transfomer: defaultTransformer)
}

public func memo<S, P, Content: View>(_ state: S, content: @escaping (P) -> Content, transfomer: (S) -> P) -> MemoPropsView<P, Content> {
    let props = transfomer(state)
    return MemoPropsView(props: props, content: content)
}

// dynamic call content with view compare, not use ViewModifier because it's already call content() get content View
public func memo<Content: View>(_ content: @escaping () -> Content) -> MemoEmptyPropsView<Content> {
    MemoEmptyPropsView(content: content)
}
