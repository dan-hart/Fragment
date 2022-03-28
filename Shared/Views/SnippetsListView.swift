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
    @EnvironmentObject var snippetHandler: SnippetHandler

    @State var cachedGists: [CachedGist] = []
    @State var isLoading = false
    @State var isShowingAddEditModal = false
    @AppStorage("searchText") var searchText = ""
    @AppStorage("visibility") var visibility: Visibility = .public

    var filteredGists: [CachedGist] {
        let withVisibility = cachedGists.filter { gist in
            let gistVisibility = Visibility(isPublic: gist.parent.publicGist)
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
                ForEach(filteredGists, id: \.id) { cachedGist in
                    NavigationLink {
                        CodeView(cachedGist: .constant(cachedGist), isLoadingParent: $isLoading)
                    } label: {
                        GistRow(data: cachedGist.parent)
                            .padding()
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $isShowingAddEditModal, content: {
            NavigationView {
                #if os(macOS)
                    EmptyView()
                        .frame(width: 0, height: 0, alignment: .leading)
                #endif
                EditGistView(filename: "", description: "", visibility: .public, content: "")
                #if os(macOS)
                    .padding()
                #endif
            }
        })
        .redacted(reason: isLoading ? .placeholder : [])
        .onAppear {
            snippetHandler.authenticate(using: tokenHandler.value ?? "") { _ in
                Task {
                    await fetchGists()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    if snippetHandler.isAuthenticated {
                        Button {
                            isShowingAddEditModal.toggle()
                        } label: {
                            Label {
                                Text("Add")
                            } icon: {
                                Image(systemSymbol: SFSymbol.plusSquareFillOnSquareFill)
                            }
                        }
                        Button {
                            Task {
                                await fetchGists()
                            }
                        } label: {
                            Image(systemSymbol: SFSymbol.squareAndArrowDownFill)
                        }
                    }
                }
            }

            ToolbarItem(placement: .navigation) {
                Button {
                    tokenHandler.delete()
                    tokenHandler.checkNeedsAuthenticationStatus()
                } label: {
                    Text("Clear Token")
                        .font(.system(.body, design: .monospaced))
                }
            }
        }

        .navigationTitle("Snippets")
    }

    func fetchGists() async {
        isLoading = true
        snippetHandler.gists { optionalGists in
            if let gists = optionalGists {
                self.cachedGists = gists.map { gist in
                    gist.cached
                }
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
