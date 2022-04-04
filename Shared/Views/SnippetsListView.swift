//
//  SnippetsListView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import DHCacheKit
import OctoKit
import SFSafeSymbols
import SwiftUI

struct SnippetsListView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var snippetHandler: SnippetHandler

    @State var gists: [Gist] = []
    @State var isLoading = false
    @State var isShowingAddModal = false
    @State var searchText = ""
    @AppStorage("visibility") var visibility: Visibility = .public

    var filteredGists: [Gist] {
        let withVisibility = gists.filter { gist in
            let gistVisibility = Visibility(isPublic: gist.publicGist)
            return gistVisibility == visibility
        }

        if searchText.isEmpty {
            return withVisibility
        } else {
            return withVisibility.filter { gist in
                gist.meetsSearchCriteria(text: searchText)
            }
        }
    }

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

            if filteredGists.isEmpty {
                Text("No Gists")
                    .font(.system(.body, design: .monospaced))
            } else {
                if !searchText.isEmpty {
                    Text("Results")
                        .font(.system(.body, design: .monospaced))
                }
                ForEach(filteredGists, id: \.id) { gist in
                    NavigationLink {
                        CodeView(gist: .constant(gist), isLoadingParent: $isLoading)
                        #if os(macOS)
                            .frame(minWidth: 1000, alignment: .center)
                        #endif
                    } label: {
                        GistRow(data: gist)
                            .padding()
                    }
                }
            }
        }
        .refreshable {
            Task {
                await fetchGists()
            }
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $isShowingAddModal, content: {
            NavigationView {
                #if os(macOS)
                    EmptyView()
                        .frame(width: 0, height: 0, alignment: .leading)
                #endif
                AddGistView(filename: "", description: "", visibility: .public, content: "") { newGist in
                    gists.insert(newGist, at: 0)
                }
                #if os(macOS)
                .padding()
                #endif
            }
        })
        .redacted(reason: isLoading ? .placeholder : [])
        .onAppear {
            Task {
                await fetchGists()
            }
        }
        .toolbar {
            let menu = Menu {
                // Menu Content
                if tokenHandler.isAuthenticated {
                    #if os(macOS)
                        Button {
                            Task {
                                await fetchGists()
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
                    tokenHandler.checkAuthorizationStatus()
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
            #if os(macOS)
            .frame(maxWidth: 50)
            #endif

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
                                Image(systemSymbol: .plusCircle)
                                Text("Create")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        #if os(macOS)
                        .frame(maxWidth: 200)
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

    func fetchGists() async {
        if !tokenHandler.isAuthenticated {
            return
        }

        isLoading = true
        gists = []
        snippetHandler.gists(using: tokenHandler.configuration) { optionalGists in
            if let gists = optionalGists {
                self.gists = gists
            }
            isLoading = false
        }
    }
}

struct SnippetsListView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsListView()
    }
}
