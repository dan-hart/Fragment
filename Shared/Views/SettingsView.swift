//
//  SettingsView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var sessionHandler: SessionHandler
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @Binding var isLoading: Bool

    @State var name: String?

    var body: some View {
        TabView {
            if sessionHandler.isAuthenticated {
                VStack {
                    Form {
                        Section("General") {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(sessionHandler.gistCollectionStatus.title)
                                Text(sessionHandler.gistCollectionStatus.detail)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.system(.footnote, design: .monospaced))
                        }

                        Section {
                            Button {
                                sessionHandler.callTask {
                                    try await sessionHandler.refreshGists()
                                }
                            } label: {
                                HStack {
                                    Image(systemSymbol: .arrowTriangle2CirclepathCircleFill)
                                    Text("Refresh")
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                            .disabled(!sessionHandler.isAuthenticated)
                        } footer: {
                            Text("Get new Gists from Github or use pull-to-refresh on the list")
                        }
                        .padding(.bottom)
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
                            .padding()
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
                    var fetchedName: String?
                    await sessionHandler.call {
                        fetchedName = try await sessionHandler.me().name
                    }
                    name = fetchedName
                    isLoading = false
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

                VStack {
                    Form {
                        Section {
                            Text("Cached gist browsing is enabled automatically so Fragment can keep working when GitHub is unavailable.")
                                .font(.system(.footnote, design: .monospaced))
                        }

                        Section {
                            Button("Clear Cached Gists") {
                                sessionHandler.clearCachedGists()
                            }
                        } footer: {
                            Text("This removes the last saved offline gist snapshot from this device.")
                        }
                    }
                }
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised")
                }
            }

            SupportThisAppView(showCancelButton: false)
                .tabItem {
                    Label("Support", systemImage: "person.3")
                }
        }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isLoading: .constant(false))
    }
}
