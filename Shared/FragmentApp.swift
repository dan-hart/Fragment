//
//  FragmentApp.swift
//  Shared
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

@main
struct FragmentApp: App {
    let tokenHandler = TokenHandler()
    let octoHandler = OctoHandler()

    @State var isLoading = true
    @State var isSettingsLoading = false

    var body: some Scene {
        WindowGroup {
            MainView(isLoading: $isLoading)
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
        }

        #if os(macOS)
            Settings {
                SettingsView(isLoading: $isSettingsLoading)
                    .environmentObject(tokenHandler)
                    .environmentObject(octoHandler)
                    .frame(width: 400, height: 400)
                    .redacted(reason: isSettingsLoading ? .placeholder : [])
            }
        #endif
    }
}
