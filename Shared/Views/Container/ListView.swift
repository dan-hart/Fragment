//
//  ListView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import OctoKit
import SFSafeSymbols
import SwiftUI

struct ListView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

    @Binding var isLoading: Bool
    @Binding var searchText: String
    @Binding var isShowingAddModal: Bool

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

            .navigationTitle("Gists")

            if sessionHandler.gists.isEmpty {
                VStack {
                    Text("No Gists")
                        .font(.system(.body, design: .monospaced))

                    HStack {
                        if sessionHandler.isAuthenticated {
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

                    if Constants.Feature.ifNoGistsEnablePullButton, sessionHandler.isAuthenticated {
                        VStack {
                            Text("If this is unexpected, try pulling.")
                                .padding()
                            Button {
                                sessionHandler.callTask {
                                    try await sessionHandler.refreshGists()
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
                ForEach(sessionHandler.gists.filter { gist in
                    let audienceIsMatch = Visibility(isPublic: gist.publicGist) == visibility
                    let searchIsVisible = searchText.isEmpty ? true : gist.meetsSearchCriteria(text: searchText)
                    return audienceIsMatch && searchIsVisible
                }.indices, id: \.self) { index in
                    NavigationLink {
                        CodeView(gist: $sessionHandler.gists[index], isLoadingParent: $isLoading)
                    } label: {
                        GistRow(data: $sessionHandler.gists[index])
                            .padding()
                    }
                }
            }
        }
        .task {
            do {
                for gist in try await sessionHandler.myGists() {
                    let audienceIsMatch = Visibility(isPublic: gist.publicGist) == visibility
                    let searchIsVisible = searchText.isEmpty ? true : gist.meetsSearchCriteria(text: searchText)
                    print("--")
                    print("gist has \(Visibility(isPublic: gist.publicGist).rawValue) - view visibility: \(visibility.rawValue)")
                    print("search: \(searchText)")
                    print("return \(audienceIsMatch && searchIsVisible)")
                    print("--")
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
        .refreshable {
            sessionHandler.callTask {
                try await sessionHandler.refreshGists()
            }
        }
        .searchable(text: $searchText)
        .redacted(reason: isLoading ? .placeholder : [])
        .toolbar {
            let menu = Menu {
                // Menu Content
                if sessionHandler.isAuthenticated {
                    #if os(macOS)
                        Button {
                            sessionHandler.callTask {
                                try await sessionHandler.refreshGists()
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
                    sessionHandler.invalidateSession()
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
                    if sessionHandler.isAuthenticated {
                        Button {
                            isShowingAddModal.toggle()
                        } label: {
                            HStack {
                                Image(systemSymbol: .plusCircle)
                                Text("Create")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        .frame(minWidth: 100)

                        #if os(macOS)
                            menu
                        #endif
                    }
                }
            }
        }
    }
}
