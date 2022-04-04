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

    @State var isLoading = false
    @State var isSettingsLoading = false

    var body: some Scene {
        WindowGroup {
            MainView(isLoading: $isLoading)
                .task {
                    isLoading = true
                    _ = await tokenHandler.checkAuthenticationStatus()
                    isLoading = false
                }
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
        }

        Settings {
            SettingsView(isLoading: $isSettingsLoading)
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
                .frame(width: 400, height: 400)
                .redacted(reason: isSettingsLoading ? .placeholder : [])
        }
    }
}
