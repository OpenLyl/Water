//
//  DemoContentView.swift
//  Example
//

import SwiftUI

struct DemoContentView: View {
    var body: some View {
        demo1
        // demo2
    }

    var demo1: some View {
        VStack {
            Text("hello world")
                .font(.largeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.red
        )
    }

    var demo2: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            VStack {
                Text("hello world")
                    .font(.largeTitle)
                Spacer()
            }
        }
    }
}
