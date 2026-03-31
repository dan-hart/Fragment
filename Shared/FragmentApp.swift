//
//  FragmentApp.swift
//  Shared
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

@main
struct FragmentApp: App {
    @StateObject var sessionHandler = SessionHandler()

    @State var isLoading = false
    @State var isSettingsLoading = false

    var body: some Scene {
        WindowGroup {
            MainView(isLoading: $isLoading)
                .environmentObject(sessionHandler)
                .alert(isPresented: $sessionHandler.isShowingAlert) {
                    sessionHandler.alert ?? Alert(title: Text(""))
                }
                .onAppear {
                    sessionHandler.callTask {
                        await MainActor.run {
                            isLoading = true
                        }

                        defer {
                            Task { @MainActor in
                                isLoading = false
                            }
                        }

                        try await sessionHandler.startSession(with: sessionHandler.token)
                    }
                }
        }
        #if os(macOS)
        .commands {
            CommandMenu("Fragment") {
                Button("New Gist") {
                    NotificationCenter.default.post(name: .fragmentCreateGist, object: nil)
                }
                .keyboardShortcut("n")

                Button("Refresh Gists") {
                    NotificationCenter.default.post(name: .fragmentRefreshGists, object: nil)
                }
                .keyboardShortcut("r")
            }
        }
        #endif

        #if os(macOS)
            Settings {
                if Constants.Feature.settingsEnabled {
                    SettingsView(isLoading: $isSettingsLoading)
                        .environmentObject(sessionHandler)
                        .frame(width: 400, height: 400)
                        .redacted(reason: isSettingsLoading ? .placeholder : [])
                }
            }
        #endif
    }
}
