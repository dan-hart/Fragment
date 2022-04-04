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
                #if os(macOS)
                    EmptyView()
                #endif
                AuthenticationView(isLoading: $isLoading)
                    .padding()
                #if os(iOS)
                    .navigationViewStyle(StackNavigationViewStyle())
                
                Text("Enter Github personal access token on the lefthand sidebar")
                    .font(.system(.body, design: .monospaced))
                
                #endif
                
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isLoading: .constant(false))
    }
}
