//
//  ProfileHost.swift
//  Landmarks
//

import SwiftUI
import Water

func ProfileHostView() -> some View {
    let draftProfile = defReactive(Profile.default)
    let editMode = defValue(EditMode.inactive)

    return View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                if editMode.value == .active {
                    Button("Cancel", role: .cancel) {
                        draftProfile.target = Profile.default
                        editMode.value = .inactive // TOOD: - with animation
                    }
                }
                Spacer()
                EditButton()
            }
            if editMode.value == .inactive {
                ProfileSummary(profile: draftProfile.target)
            } else {
                ProfileEditor($profile: draftProfile.bindable)
            }
        }
        .padding()
        .environment(\.editMode, editMode.bindable)
    }
}

struct ProfileHostView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHostView()
    }
}
