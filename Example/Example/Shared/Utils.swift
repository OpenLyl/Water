//
//  Utils.swift
//  Example
//

import UIKit

// build your own focused state - https://github.com/shaps80/SwiftUIBackports/blob/bfaf193/Sources/SwiftUIBackports/iOS/FocusState/FocusState.swift
func dismissKeyboard() {
    UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.endEditing(true)
}
