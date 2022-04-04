//
//  MainView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var octoHandler: OctoHandler
    @EnvironmentObject var cacheHandler: CacheHandler

    @State var isLoading = true

    var body: some View {
        NavigationView {
            if isLoading {
                #if os(macOS)
                    EmptyView()
                #endif
                Text("Loading...")
                    .font(.system(.largeTitle, design: .monospaced))
                    .frame(minWidth: 800)
            } else {
                if tokenHandler.isAuthenticated {
                    SnippetsListView()
                } else {
                    AuthenticationView()
                        .frame(minWidth: 800)
                        .padding()
                }
            }
        }
        .task {
            isLoading = true
            _ = await tokenHandler.checkAuthenticationStatus()
            isLoading = false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
