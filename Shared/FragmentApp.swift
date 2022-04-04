//
//  FragmentApp.swift
//  Shared
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

@main
struct FragmentApp: App {
    let sessionHandler = SessionHandler()

    @State var isLoading = false
    @State var isSettingsLoading = false

    init() {
        do {
            try await sessionHandler.startSession()
        } catch {
            print("Unable to start session")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(isLoading: $isLoading)
                .environmentObject(sessionHandler)
        }

        #if os(macOS)
            Settings {
                SettingsView(isLoading: $isSettingsLoading)
                    .environmentObject(sessionHandler)
                    .frame(width: 400, height: 400)
                    .redacted(reason: isSettingsLoading ? .placeholder : [])
            }
        #endif
    }
}
