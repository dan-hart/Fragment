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
            ListView(selectedGist: $selectedGist, isLoading: $isLoading, searchText: $searchText)
            CodeView(gist: $selectedGist, isLoadingParent: $isLoading)

                .navigationTitle("Gists")
        }
        .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar, label: { // 1
                            Image(systemName: "sidebar.leading")
                        })
                    }
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
