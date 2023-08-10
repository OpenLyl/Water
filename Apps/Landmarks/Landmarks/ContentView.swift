//
//  ContentView.swift
//  Landmarks
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .featured

    enum Tab {
        case featured
        case list
    }
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                CategoryHomeView()
                    .navigationTitle("Featured")
            }
            .tabItem {
                Label("Featured", systemImage: "star")
            }
            .tag(Tab.featured)
            NavigationView {
                LandmarkListView()
                    .navigationTitle("Landmarks")
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(Tab.list)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()   
    }
}

