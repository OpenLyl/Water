//
//  ViewsExt.swift
//  Water
//

import SwiftUI

// remove use .array for more easy to use, create ForEach List extension
extension ForEach where Content: View {
    public init<ReactiveData: ReactiveCollection>(_ data: ReactiveData, id: KeyPath<ReactiveData.Element, ID>, @ViewBuilder content: @escaping (ReactiveData.Element) -> Content)
    where Self.Data == [ReactiveData.Element] {
        self.init(data.array, id: id, content: content)
    }
}

extension ForEach where ID == Data.Element.ID, Content : View, Data.Element : Identifiable {
    public init<ReactiveData: ReactiveCollection>(_ data: ReactiveData, @ViewBuilder content: @escaping (Data.Element) -> Content) 
    where Self.Data == [ReactiveData.Element] {
        self.init(data.array, content: content)
    }
}

// TODO: - create List extension
