//
//  LandmarkDetailView.swift
//  Landmarks
//

import SwiftUI
import Water

func LandmarkDetailView(@Binding landmark: Landmark) -> some View {
    ScrollView {
        VStack {
            MapView(coordinate: landmark.locationCoordinate)
                .ignoresSafeArea(edges: .top)
                .frame(height: 300)
            CircleImage(image: Image(landmark.imageName))
                .offset(y: -130)
                .padding(.bottom, -130)
            VStack(alignment: .leading) {
                HStack {
                    Text(landmark.name)
                        .font(.title)
                    FavoriteButton($isSet: $landmark.isFavorite)
                }
                HStack {
                    Text(landmark.park)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(landmark.state)
                        .font(.subheadline)
                }
                Divider()
                Text("About \(landmark.name)")
                    .font(.title2)
                Text(landmark.description)
            }
            .padding()
            Spacer()
        }
    }
    .navigationTitle(landmark.name)
    .navigationBarTitleDisplayMode(.inline)
}

struct LandmarkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkDetailView($landmark: Binding.constant(landmarks[0]))
    }
}
