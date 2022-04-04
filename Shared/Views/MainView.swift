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
                
            }
            if tokenHandler.isAuthenticated {
                SnippetsListView()
            } else {
                AuthenticationView()
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
