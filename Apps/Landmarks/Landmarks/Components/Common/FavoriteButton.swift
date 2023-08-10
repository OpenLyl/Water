//
//  FavoriteButton.swift
//  Landmarks
//

import SwiftUI

func FavoriteButton(@Binding isSet: Bool) -> some View {
    Button {
        isSet.toggle()
    } label: {
        Label("Toggle Favorite", systemImage: isSet ? "star.fill" : "star")
            .labelStyle(.iconOnly)
            .foregroundColor(isSet ? .yellow : .gray)
    }
}
