//
//  CircleImage.swift
//  Landmarks
//

import SwiftUI

func CircleImage(image: Image) -> some View {
    image
        .clipShape(Circle())
        .overlay {
            Circle().stroke(.white, lineWidth: 4)
        }
        .shadow(radius: 7)
}
