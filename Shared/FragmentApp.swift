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
    let cacheHandler = CacheHandler()

    @State var isSettingsLoading = false

    init() {
        tokenHandler.taskCheckingAuthenticationStatus()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
                .environmentObject(cacheHandler)
                .onChange(of: tokenHandler.isAuthenticated) { _ in
                    octoHandler.gists(using: tokenHandler.configuration) { gists in
                        cacheHandler.gistsCache.insert(gists ?? [], forKey: tokenHandler.token ?? "")
                    }
                }
        }

        Settings {
            SettingsView(isLoading: $isSettingsLoading, isAuthenticated: $tokenHandler.isAuthenticated)
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
                .environmentObject(cacheHandler)
                .frame(width: 400, height: 400)
                .redacted(reason: isSettingsLoading ? .placeholder : [])
        }
    }
}
