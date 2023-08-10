//
//  NavigationUseCasesView.swift
//  Example
//

import SwiftUI
import Water

func NavigationUseCasesView() -> some View {
    NavigationView {
        VStack {
            NavigationFirstPage()
        }
    }
}

func NavigationFirstPage() -> some View {
    let count = defValue(0)
    
    return View {
        Text("the count value = \(count.value)")
        Button("increment") {
            count.value += 1
        }
        NavigationLink("go second page") {
            NavigationSecondPage()
        }
    }
    .navigationTitle("first page")
    .navigationBarTitleDisplayMode(.inline)
}

func NavigationSecondPage() -> some View {
    let dismiss = useEnvironment(\.dismiss)
    
    return View {
        Text("second page")
    }
    .useEnvironment(\.dismiss)
    .navigationTitle("second page")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss.value?()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
        }
    }
}
