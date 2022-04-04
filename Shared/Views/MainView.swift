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
            ContainerView(isLoading: $isLoading)
        } else {
            if isLoading {
                ContainerView(isLoading: $isLoading) // Permanet loading
                    .redacted(reason: .placeholder)  //
            } else {
            NavigationView {
                #if os(macOS)
                    EmptyView()
                    AuthenticationView(isLoading: $isLoading)
                        .padding()
                #endif
                #if os(iOS)
                    AuthenticationView(isLoading: $isLoading)
                        .padding()
                    Text("Enter Github personal access token on the lefthand sidebar")
                        .font(.system(.body, design: .monospaced))
                #endif
            }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isLoading: .constant(false))
    }
}
