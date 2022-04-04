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

    init() {
        tokenHandler.taskCheckingAuthenticationStatus()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tokenHandler)
                .environmentObject(snippetHandler)
        }
        .onChange(of: tokenHandler.isAuthenticated) { _ in
            snippetHandler.gists(using: tokenHandler.configuration) { _ in
                // Code
            }
        }
    }
}
