//
//  Landmark.swift
//  Landmarks
//

import SwiftUI
import MapKit
import Water

//struct LandmarkRowProps: Equatable {
//    let name: String
//    let image: Image
//    let isFavorite: Bool
//}

//func LandmarkRow(landmark: Landmark) -> some View {
//    Memo(landmark) { props in
//        HStack {
//            props.image
//                .resizable()
//                .frame(width: 50, height: 50)
//            Text(props.name)
//            Spacer()
//            if landmark.isFavorite {
//                Image(systemName: "star.fill").foregroundColor(.yellow)
//            }
//        }
//    } transfomer: { state in
//        LandmarkRowProps(name: state.name, image: state.image, isFavorite: state.isFavorite)
//    }
//}

// TODO: - test this in home computer
// Landmark is Hashable
func LandmarkRow(landmark: Landmark) -> some View {
    Memo(landmark) { landmark in
        HStack {
            Image(landmark.imageName)
                .resizable()
                .frame(width: 50, height: 50)
            Text(landmark.name)
            Spacer()
            if landmark.isFavorite {
                Image(systemName: "star.fill").foregroundColor(.yellow)
            }
        }
    }
}

func MapView(coordinate: CLLocationCoordinate2D) -> some View {
    let region = defReactive(
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )
    
    // FIXME: - when use def the view must wrap with Water View (give it a warning ?)
    return View {
        Map(coordinateRegion: region.bindable)
    }
}
