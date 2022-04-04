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
        if tokenHandler.isAuthenticated {
            ContainerView()
        } else {
            NavigationView {
                if Constants.isMacOrPad() {
                    EmptyView()
                }
                AuthenticationView(isLoading: $isLoading)
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
