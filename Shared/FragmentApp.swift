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

    @State var isSettingsLoading = false

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
        }

        Settings {
            SettingsView(isLoading: $isSettingsLoading)
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
                .environmentObject(cacheHandler)
                .frame(width: 400, height: 400)
                .redacted(reason: isSettingsLoading ? .placeholder : [])
        }
    }
}
