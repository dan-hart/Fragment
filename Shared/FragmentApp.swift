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
                        isLoading = true
                        try await sessionHandler.startSession(with: sessionHandler.token)
                        isLoading = false
                    }
                }
        }

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
