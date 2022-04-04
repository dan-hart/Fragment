//
//  SnippetsListView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import OctoKit
import SFSafeSymbols
import SwiftUI

struct SnippetsListView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var octoHandler: OctoHandler

    @State var isLoading = false
    @State var isShowingAddModal = false
    @State var searchText = ""

    @AppStorage("visibility") var visibility: Visibility = .public

    var body: some View {
        List {
            Picker("Visibility", selection: $visibility) {
                ForEach(Visibility.allCases, id: \.self) { access in
                    Text(access.rawValue)
                        .font(.system(.body, design: .monospaced))
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if octoHandler.gists.isEmpty {
                VStack {
                    Text("No Gists")
                        .font(.system(.body, design: .monospaced))

                    HStack {
                        if tokenHandler.isAuthenticated {
                            Button {
                                isShowingAddModal.toggle()
                            } label: {
                                HStack {
                                    #if !os(macOS)
                                        Image(systemSymbol: .plusCircle)
                                    #endif
                                    Text("Create Gist")
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                    }

                    if Constants.Feature.ifNoGistsEnablePullButton, tokenHandler.isAuthenticated {
                        VStack {
                            Text("If this is unexpected, try pulling.")
                                .padding()
                            Button {
                                Task {
                                    try? await octoHandler.fetchGists(tokenHandler, isLoading: $isLoading)
                                }
                            } label: {
                                HStack {
                                    #if os(iOS)
                                        Image(systemSymbol: .arrowDownCircle)
                                    #endif
                                    Text("Pull")
                                        .font(.system(.body, design: .monospaced))
                                    #if os(macOS)
                                        .padding()
                                    #endif
                                }
                            }
                            .padding()
                        }
                        .font(.system(.footnote, design: .monospaced))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder()
                                .foregroundColor(.gray)
                        )
                    }
                }
            } else {
                if !searchText.isEmpty {
                    Text("Results")
                        .font(.system(.body, design: .monospaced))
                }
                ForEach(octoHandler.gists.filter { gist in
                    let audienceIsMatch = Visibility(isPublic: gist.publicGist) == visibility
                    let searchIsVisible = searchText.isEmpty ? true : gist.meetsSearchCriteria(text: searchText)
                    return audienceIsMatch && searchIsVisible
                }.indices, id: \.self) { index in
                    NavigationLink {
                        CodeView(gist: $octoHandler.gists[index], isLoadingParent: $isLoading)
                        #if os(macOS)
                            .frame(minWidth: 1000)
                        #endif
                    } label: {
                        GistRow(data: $octoHandler.gists[index])
                            .padding()
                    }
                }
            }
        }
        .task {
            _ = try? await octoHandler.fetchGists(tokenHandler, cacheHandler, isLoading: $isLoading)
        }
        .refreshable {
            Task {
                try? await octoHandler.fetchGists(tokenHandler, cacheHandler, isLoading: $isLoading)
            }
        }
        .searchable(text: $searchText)
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
        .redacted(reason: isLoading ? .placeholder : [])
        .toolbar {
            let menu = Menu {
                // Menu Content
                if tokenHandler.isAuthenticated {
                    #if os(macOS)
                        Button {
                            Task {
                                try? await octoHandler.fetchGists(tokenHandler, cacheHandler, isLoading: $isLoading)
                            }
                        } label: {
                            HStack {
                                Image(systemSymbol: .arrowDownCircle)
                                Text("Pull")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }

                    #endif

                    Divider()
                }

                Button {
                    tokenHandler.delete()
                    tokenHandler.taskCheckingAuthenticationStatus()
                } label: {
                    HStack {
                        Image(systemSymbol: .xmarkCircle)
                        Text("Clear Token")
                            .font(.system(.body, design: .monospaced))
                    }
                }
                // End Menu Content
            } label: {
                Image(systemSymbol: .ellipsisCircle)
            }

            #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    menu
                }
            #endif

            ToolbarItem(placement: .primaryAction) {
                HStack {
                    if tokenHandler.isAuthenticated {
                        Button {
                            isShowingAddModal.toggle()
                        } label: {
                            HStack {
                                #if !os(macOS)
                                    Image(systemSymbol: .plusCircle)
                                #endif
                                Text("Create")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        #if os(macOS)
                        .buttonStyle(PlainButtonStyle())
                        #endif

                        #if os(macOS)
                            menu
                        #endif
                    }
                }
            }
        }

        .navigationTitle("Gists")
    }
}

struct SnippetsListView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsListView()
    }
}
