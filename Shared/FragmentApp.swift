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

    init() {
        tokenHandler.taskCheckingAuthenticationStatus()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tokenHandler)
                .environmentObject(octoHandler)
                .environmentObject(cacheHandler)
        }
        .onChange(of: tokenHandler.isAuthenticated) { _ in
            octoHandler.gists(using: tokenHandler.configuration) { gists in
                cacheHandler.gistsCache.insert(gists ?? [], forKey: CacheHandler.Key.gists.rawValue)
            }
        }

        Settings {
            SettingsView()
        }
    }
}
