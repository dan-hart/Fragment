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
        if sessionHandler.canBrowseGists {
            ContainerView(isLoading: $isLoading)
        } else {
            if isLoading {
                ContainerView(isLoading: $isLoading) // Permanent loading
                    .redacted(reason: .placeholder) //
            } else {
                NavigationStack {
                    AuthenticationView(isLoading: $isLoading)
                        .padding()
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
