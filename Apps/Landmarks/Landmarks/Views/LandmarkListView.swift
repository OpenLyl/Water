//
//  LandmarkListView.swift
//  Landmarks
//

import SwiftUI
import MapKit
import Water

// FIXME: - check the render effect log
func LandmarkListView() -> some View {
    let (showFavoritesOnly, filteredLandmarks) = useFavoriteLandmarks()
    
    return View {
        List {
            Toggle(isOn: showFavoritesOnly.bindable) {
                Text("Favorites only")
            }
            ForEach(filteredLandmarks.bindable, id: \.id) { $landmark in
                NavigationLink {
                    LandmarkDetailView($landmark: $landmark)
                } label: {
                    // FIXME: - EquatableView - react useMemo useCallback
                    LandmarkRow(landmark: landmark)
                }
            }
        }
    }
}

struct LandmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkListView()
            .previewDisplayName("landmarks list")
        LandmarkRow(landmark: landmarks[0])
            .previewLayout(.fixed(width: 300, height: 70))
            .previewDisplayName("landmark row")
    }
}
