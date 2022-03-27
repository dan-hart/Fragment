//
//  MainView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var snippetHandler: SnippetHandler

    var body: some View {
        NavigationView {
            if tokenHandler.needsAuthentication {
                AuthenticationView()
            } else {
                SnippetsListView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
