//
//  AuthenticationView.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import SFSafeSymbols
import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

    @Binding var isLoading: Bool

    @State var token: String = ""
    @State var isShowingSupportThisAppView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Connect GitHub once")
                    .font(.system(.largeTitle, design: .monospaced, weight: .bold))

                Text("Fragment uses a GitHub personal access token so it can sync, edit, and create gists from a native app. Your token stays on this device in the system Keychain.")
                    .font(.system(.body, design: .monospaced))

                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Required scope: `gist`", systemImage: "checkmark.seal")
                        Label("Stored locally in Keychain", systemImage: "lock.shield")
                        Label("Cached gists stay readable when GitHub is offline", systemImage: "externaldrive")
                    }
                    .font(.system(.body, design: .monospaced))
                } label: {
                    Text("Before You Start")
                        .font(.system(.headline, design: .monospaced))
                }

                if let error = sessionHandler.lastRefreshError {
                    Text(error)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                SecureField(
                    text: $token,
                    prompt: Text("ghp_exampleTokenValue").font(.system(.body, design: .monospaced))
                ) {
                    Text("GitHub Personal Access Token")
                        .font(.system(.body, design: .monospaced))
                }
                .onSubmit {
                    go()
                }

                Button {
                    go()
                } label: {
                    HStack {
                        Image(systemSymbol: SFSymbol.lock)
                        Text("Validate and Continue")
                            .font(.system(.body, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if let url = URL(string: Constants.URL.githubHowToPersonalAccessToken.rawValue) {
                    Button {
                        WebLauncher.go(to: url)
                    } label: {
                        HStack {
                            Image(systemSymbol: SFSymbol.questionmarkCircle)
                            Text("Open Token Setup Guide")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }

                if !sessionHandler.gists.isEmpty {
                    Text("Cached gists are available right now, so you can keep reading while offline.")
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Divider()

                Button {
                    isShowingSupportThisAppView = true
                } label: {
                    HStack {
                        Image(systemSymbol: SFSymbol.person3)
                        Text("Project resources")
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSupportThisAppView) {
            NavigationView {
                SupportThisAppView(showCancelButton: true)
            }
        }
        .redacted(reason: isLoading ? .placeholder : [])
        .padding()
        .navigationTitle("Authentication")
    }

    func go() {
        isLoading = true
        sessionHandler.callTask {
            defer {
                Task { @MainActor in
                    isLoading = false
                }
            }

            try await sessionHandler.startSession(with: token)
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(isLoading: .constant(false))
    }
}
