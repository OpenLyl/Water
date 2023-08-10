//
//  ProfileHost.swift
//  Landmarks
//

import SwiftUI

func ProfileSummary(profile: Profile) -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 10) {
            Text(profile.username)
                .bold()
                .font(.title)

            Text("Notifications: \(profile.prefersNotifications ? "On": "Off" )")
            Text("Seasonal Photos: \(profile.seasonalPhoto.rawValue)")
            Text("Goal Date: ") + Text(profile.goalDate, style: .date)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Completed Badges")
                    .font(.headline)
                ScrollView(.horizontal) {
                    HStack {
                        // FIXME: - the hike badge size is not normal
                        HikeBadge(name: "First Hike")
                        HikeBadge(name: "Earth Day")
                            .hueRotation(Angle(degrees: 90))
                        HikeBadge(name: "Tenth Hike")
                            .grayscale(0.5)
                            .hueRotation(Angle(degrees: 45))
                    }
                    .padding(.bottom)
                }
            }
            
            Divider()
        
            VStack(alignment: .leading) {
                Text("Recent Hikes")
                    .font(.headline)
                HikeView(hike: hikes[0])
            }
        }
    }
}

func ProfileEditor(@Binding profile: Profile) -> some View {
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -1, to: profile.goalDate)!
        let max = Calendar.current.date(byAdding: .year, value: 1, to: profile.goalDate)!
        return min...max
    }
    
    return List {
        HStack {
            Text("Username").bold()
            Divider()
            TextField("Username", text: $profile.username)
        }
        
        Toggle(isOn: $profile.prefersNotifications) {
            Text("Enable Notifications").bold()
        }
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Seasonal Photo").bold()
            
            Picker("Seasonal Photo", selection: $profile.seasonalPhoto) {
                ForEach(Profile.Season.allCases) { season in
                    Text(season.rawValue).tag(season)
                }
            }
            .pickerStyle(.segmented)
        }


        DatePicker(selection: $profile.goalDate, in: dateRange, displayedComponents: .date) {
            Text("Goal Date").bold()
        }
    }
}

func HikeBadge(name: String) -> some View {
    VStack(alignment: .center) {
        Badge()
            .frame(width: 300, height: 300)
            .scaleEffect(1.0 / 3.0)
            .frame(width: 100, height: 100)
        Text(name)
            .font(.caption)
            .accessibilityLabel("Badge for \(name).")
    }
}
