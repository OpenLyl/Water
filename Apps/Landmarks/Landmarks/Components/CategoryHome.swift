//
//  CategoryHome.swift
//  Landmarks
//

import SwiftUI
import Water

func CategoryRow(categoryName: String, filterItems: (String) -> ComputedValue<[Landmark]>) -> some View {
    let filteredLandmarks = filterItems(categoryName)
    
    return View {
        VStack(alignment: .leading) {
            Text(categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(filteredLandmarks.bindable, id: \.id) { $landmark in
                        NavigationLink {
                            LandmarkDetailView($landmark: $landmark)
                        } label: {
                            CategoryItem(landmark: $landmark.wrappedValue)
                        }
                    }
                }
            }
            .frame(height: 185)
        }
    }
}

func CategoryItem(landmark: Landmark) -> some View {
    VStack(alignment: .leading) {
        Image(landmark.imageName)
            .renderingMode(.original)
            .resizable()
            .frame(width: 155, height: 155)
            .cornerRadius(5)
        Text(landmark.name)
            .foregroundColor(.primary)
            .font(.caption)
    }
    .padding(.leading, 15)
}
