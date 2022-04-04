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
    
    @State var is

    var body: some View {
        NavigationView {
            if tokenHandler.isAuthenticated {
                SnippetsListView()
            } else {
                AuthenticationView()
            }
        }
        .task {
            _ await tokenHandler.checkAuthenticationStatus()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
