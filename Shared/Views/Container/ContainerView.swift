//
//  ContainerView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import OctoKit
import SFSafeSymbols
import SwiftUI

struct ContainerView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var octoHandler: OctoHandler

    @State var selectedGist: Gist?
    @State var isLoading = false
    @State var isShowingAddModal = false
    @State var searchText = ""

    var body: some View {
        NavigationView {
            ListView(isLoading: $isLoading, searchText: $searchText)
            CodeView(gist: $octoHandler.gists[index], isLoadingParent: $isLoading)
            
                .navigationTitle("Gists")
        }
        .sheet(isPresented: $isShowingAddModal, content: {
            #if os(iOS)
                NavigationView {
                    AddGistView(filename: "", description: "", visibility: .public, content: "") { newGist in
                        gists.insert(newGist, at: 0)
                    }
                }
            #endif
            #if os(macOS)
                AddGistView(filename: "", description: "", content: "") { newGist in
                    octoHandler.gists.insert(newGist, at: 0)
                }
                .frame(minWidth: 800, minHeight: 800)
                .padding()
            #endif
        })
    }
}

struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
}
