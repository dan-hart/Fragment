//
//  MainView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

    @Binding var isLoading: Bool

    var body: some View {
        if sessionHandler.isAuthenticated {
            ContainerView()
        } else {
            NavigationView {
                if Constants.isMacOrPad() {
                    EmptyView()
                }
                AuthenticationView(isLoading: $isLoading)
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
