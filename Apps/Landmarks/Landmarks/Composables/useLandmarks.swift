//
//  useLandmarks.swift
//  Landmarks
//

import Foundation
import Water

let landmarks: [Landmark] = load("landmarkData.json")
var hikes: [Hike] = load("hikeData.json")

let reactiveLandmarks = defReactive(landmarks)

func useLandmarks() -> ReactiveArray<Landmark> {
    return reactiveLandmarks
}

func useFavoriteLandmarks() -> (ReactiveValue<Bool>, ComputedValue<[Landmark]>) {
    let landmarks = useLandmarks()
    
    let showFavoritesOnly = defValue(false)
    let filteredLandmarks = useArrayFilter(landmarks) { !showFavoritesOnly.value || $0.isFavorite }
                                                         
    return (showFavoritesOnly, filteredLandmarks)
}

func useCategoryLandmarks() -> (String, [String], (String) -> ComputedValue<[Landmark]>) {
    let landmarks = useLandmarks()
    
    let firstFeatureImageName: String = landmarks.filter { $0.isFeatured }[0].imageName
    
    let categoryNames = Dictionary(grouping: landmarks) { $0.category.rawValue }.keys.sorted()
    
    func filterLandmarks(categoryName: String) -> ComputedValue<[Landmark]> {
        return useArrayFilter(landmarks) { $0.category.rawValue == categoryName }
    }
        
    return (firstFeatureImageName, categoryNames, filterLandmarks)
}

func useArrayFilter<T: Identifiable>(_ items: ReactiveArray<T>, isIncluded: @escaping (T) -> Bool) -> ComputedValue<[T]> {
    let filteredItems = defComputed {
        return items.filter { isIncluded($0) }
    } setter: { newItems in
        newItems.forEach { newValue in
            if let index = items.firstIndex(where: {$0.id == newValue.id}) {
                items[index] = newValue
            }
        }
    }
    return filteredItems
}

// MARK: - Utils

func load<T: Decodable>(_ filename: String) -> T {
    print("--> load data")
    
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
