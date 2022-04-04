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
        .sheet(isPresented: $isShowingAddModal) {
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
        }
        .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            toggleSidebar()
                        } label: {
                            Image(systemSymbol: .sidebarLeading)
                    }
                }
    }
}
    
    private func toggleSidebar() {
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}
