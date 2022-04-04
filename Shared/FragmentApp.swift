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
    let snippetHandler = SnippetHandler()
    let cacheHandler = CacheHandler()

    init() {
        tokenHandler.taskCheckingAuthenticationStatus()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tokenHandler)
                .environmentObject(snippetHandler)
                .environmentObject(cacheHandler)
        }
        .onChange(of: tokenHandler.isAuthenticated) { _ in
            snippetHandler.gists(using: tokenHandler.configuration) { gists in
                cacheHandler.gistsCache.insert(gists ?? [], forKey: CacheHandler.Key.gists.rawValue)
            }
        }

        Settings {
            TabView {
                VStack {
                    Text("Privacy Settings")
                        .font(.title)
                    
                }
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }

                Text("Profile Settings")
                    .font(.title)
                    .tabItem {
                        Label("Appearance", systemImage: "paintpalette")
                    }

                Text("Privacy Settings")
                    .font(.title)
                    .tabItem {
                        Label("Privacy", systemImage: "hand.raised")
                    }
            }
            .frame(width: 800, height: 800)
        }
    }
}
