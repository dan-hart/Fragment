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

    @Binding var isLoading: Bool

    var body: some View {
        if isLoading {
            Text("Loading...")
                .font(.system(.largeTitle, design: .monospaced))
                .frame(minWidth: 800)
        } else {
            if tokenHandler.isAuthenticated {
                ContainerView(selectedGist: <#T##Gist#>)
            } else {
                AuthenticationView()
                    .frame(minWidth: 800)
                    .padding()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isLoading: .constant(false))
    }
}
