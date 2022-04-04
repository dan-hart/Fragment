//
//  SettingsView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var octoHandler: OctoHandler
    @EnvironmentObject var cacheHandler: CacheHandler

    @Binding var isLoading: Bool

    @State var name: String?

    var body: some View {
        TabView {
            Text("Appearance Settings")
                .font(.title)
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }

            if isAuthenticated {
                List {
                    Text("Profile Settings")
                        .font(.title)

                    Text(name ?? "Name")

                    Button {
                        tokenHandler.delete()
                        tokenHandler.taskCheckingAuthenticationStatus()
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

                    let authenticated = await tokenHandler.checkAuthenticationStatus()
                    if authenticated {
                        name = await octoHandler.me(using: tokenHandler.configuration)?.name
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
        SettingsView(isLoading: .constant(false), isAuthenticated: .constant(true))
    }
}
