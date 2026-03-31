//
//  ContainerView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

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
                        sessionHandler.noteCreated(newGist)
                    }
                }
            #endif
            #if os(macOS)
                AddGistView(filename: "", description: "", content: "") { newGist in
                    sessionHandler.noteCreated(newGist)
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
        .onReceive(NotificationCenter.default.publisher(for: .fragmentCreateGist)) { _ in
            if sessionHandler.isAuthenticated {
                isShowingAddModal = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .fragmentRefreshGists)) { _ in
            if sessionHandler.isAuthenticated {
                sessionHandler.callTask {
                    try await sessionHandler.refreshGists()
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
