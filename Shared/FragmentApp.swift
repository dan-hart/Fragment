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
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject()
                .environmentObject(SnippetHandler())
        }
    }
}
