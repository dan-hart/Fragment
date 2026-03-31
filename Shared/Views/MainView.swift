//
//  MainView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

enum MainViewContentState: Equatable {
    case loading
    case browsing(showAuthenticationPrompt: Bool)
    case authentication
}

struct MainView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

    @Binding var isLoading: Bool
    @State private var isShowingAuthenticationSheet = false

    static func contentState(
        isLoading: Bool,
        isAuthenticated: Bool,
        canBrowseGists: Bool
    ) -> MainViewContentState {
        if canBrowseGists {
            return .browsing(showAuthenticationPrompt: !isAuthenticated)
        }

        if isLoading {
            return .loading
        }

        return .authentication
    }

    private var currentContentState: MainViewContentState {
        Self.contentState(
            isLoading: isLoading,
            isAuthenticated: sessionHandler.isAuthenticated,
            canBrowseGists: sessionHandler.canBrowseGists
        )
    }

    var body: some View {
        switch currentContentState {
        case let .browsing(showAuthenticationPrompt):
            ContainerView(isLoading: $isLoading)
                .safeAreaInset(edge: .top) {
                    if showAuthenticationPrompt {
                        reauthenticationPrompt
                    }
                }
                .sheet(isPresented: $isShowingAuthenticationSheet) {
                    NavigationStack {
                        AuthenticationView(isLoading: $isLoading)
                            .padding()
                    }
                }
                .onChange(of: sessionHandler.isAuthenticated) { isAuthenticated in
                    if isAuthenticated {
                        isShowingAuthenticationSheet = false
                    }
                }
        case .loading:
            ContainerView(isLoading: $isLoading)
                .redacted(reason: .placeholder)
        case .authentication:
            NavigationStack {
                AuthenticationView(isLoading: $isLoading)
                    .padding()
            }
        }
    }

    private var reauthenticationPrompt: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reconnect GitHub")
                    .font(.system(.headline, design: .monospaced))

                Text("Cached gists are still available, but you need to sign in again before syncing or editing.")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Button("Sign In Again") {
                isShowingAuthenticationSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isLoading: .constant(false))
    }
}
