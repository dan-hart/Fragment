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
    @EnvironmentObject var sessionHandler: SessionHandler

    @Binding var isLoading: Bool

    @State var isShowingAddModal = false
    @State var searchText = ""

    var body: some View {
        NavigationView {
            ListView(isLoading: $isLoading, searchText: $searchText, isShowingAddModal: $isShowingAddModal)
            SupportThisAppView(showCancelButton: false)
        }
        .sheet(isPresented: $isShowingAddModal) {
            #if os(iOS)
                NavigationView {
                    AddGistView(filename: "", description: "", visibility: .public, content: "") { newGist in
                        sessionHandler.gists.insert(newGist, at: 0)
                    }
                }
            #endif
            #if os(macOS)
                AddGistView(filename: "", description: "", content: "") { newGist in
                    sessionHandler.gists.insert(newGist, at: 0)
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
