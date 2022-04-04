//
//  SettingsView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

    @Binding var isLoading: Bool

    @State var name: String?

    var body: some View {
        TabView {
            List {
                Text("General")
                    .font(.system(.title, design: .monospaced))
                
                Button {
                    sessionHandler.callTask {
                        try await sessionHandler.refreshGists()
                    }
                } label: {
                    HStack {
                        Image(systemSymbol: .arrowDownCircle)
                        Text("Refresh")
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
                .font(.title)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            Text("Appearance")
                .font(.title)
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }

            if sessionHandler.isAuthenticated {
                List {
                    Text("Profile")
                        .font(.title)

                    Text(name ?? "Loading...")

                    Button {
                        sessionHandler.invalidateSession()
                    } label: {
                        HStack {
                            Image(systemSymbol: .xmarkCircle)
                            Text("Clear Token")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                .task {
                    isLoading = true

                    sessionHandler.callTask {
                        let user = try await sessionHandler.me()
                        self.name = user.name
                    }

                    isLoading = false
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

                Text("Privacy Settings")
                    .font(.title)
                    .tabItem {
                        Label("Privacy", systemImage: "hand.raised")
                    }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isLoading: .constant(false))
    }
}
