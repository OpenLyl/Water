//
//  CategoryHomeView.swift
//  Landmarks
//

import SwiftUI
import Water

func CategoryHomeView() -> some View {
    let (firstFeatureImageName, categoryNames, filterLandmarks) = useCategoryLandmarks()
    
    let showingProfile = defValue(false)
    
    return View {
        List {
            Image(firstFeatureImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .listRowInsets(EdgeInsets())
            ForEach(categoryNames.sorted(), id: \.self) { key in
                CategoryRow(categoryName: key, filterItems: filterLandmarks)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .toolbar {
            Button {
                showingProfile.value.toggle()
            } label: {
                Label("User Profile", systemImage: "person.crop.circle")
            }
        }
        .sheet(isPresented: showingProfile.bindable) {
            ProfileHostView()
        }
    }
}

struct CategoryHome_Previews: PreviewProvider {
    static var previews: some View {
        CategoryHomeView()
    }
}
