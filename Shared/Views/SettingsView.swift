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
            if sessionHandler.isAuthenticated {
                VStack {
                    Form {
                        Section("General") {
                            EmptyView()
                        }

                        Section {
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
                        } footer: {
                            Text("Get new Gists from Github or use pull-to-refresh on the list")
                        }
                    }
                }
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            }

            VStack {
                Form {
                    Section {
                        Stepper("Code Font Size: \(sessionHandler.fontSize)", value: $sessionHandler.fontSize, in: 8 ... 72)
                    } footer: {
                        Text("Affects areas where code is being used. Go to Settings to adjust other text size.")
                    }
                }
            }
            .tabItem {
                Label("Appearance", systemImage: "paintpalette")
            }

            if sessionHandler.isAuthenticated {
                VStack {
                    Form {
                        Section("You") {
                            Text(name ?? "Loading...")
                        }

                        Section {
                            Button {
                                sessionHandler.invalidateSession()
                            } label: {
                                HStack {
                                    Image(systemSymbol: .xmarkCircle)
                                    Text("Clear Token")
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        } footer: {
                            Text("Clears all gists and discards your personal access token")
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

                VStack {
                    Form {
                        Section {
                            Toggle("Disable Local Caching", isOn: .constant(false))
                                .disabled(true)
                        } footer: {
                            Text("Not implemented yet")
                        }
                    }
                }
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
