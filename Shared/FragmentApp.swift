//
//  FragmentApp.swift
//  Shared
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

// 4th time is the charm

@main
struct FragmentApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(TokenHandler())
                .environmentObject(SnippetHandler())
        }
    }
}
