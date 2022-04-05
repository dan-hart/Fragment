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
    
    @State var isShowingSupportThisAppView = false
    @State var isShowingPreferencesView = false
    
    var filteredGists: [Gist] {
        let withVisibility = sessionHandler.gists.filter { gist in
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
            
            .navigationTitle("Gists")
            
            if sessionHandler.gists.isEmpty {
                VStack {
                    Text(isLoading ? "Loading..." : "No Gists")
                        .font(.system(.body, design: .monospaced))
                    
                    if Constants.Feature.ifNoGistsEnableCreateButton {
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
                ForEach(filteredGists, id: \.self) { gist in
                    NavigationLink {
                        CodeView(gist: .constant(gist), isLoadingParent: $isLoading)
                            .navigationTitle(gist.filename)
                    } label: {
                        GistRow(data: .constant(gist))
                            .padding()
                    }
                }
            }
                .sheet(isPresented: $isShowingSupportThisAppView) {
                    SupportThisAppView()
                }
        }
        .sheet(isPresented: $isShowingPreferencesView) {
            NavigationView {
                SettingsView(isLoading: $isLoading)
                
                    .navigationTitle("Settings")
            }
        }
        .onAppear {
            if !isLoading {
                sessionHandler.callTask {
                    try await sessionHandler.refreshGists()
                }
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
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button {
                        isShowingSupportThisAppView = true
                    } label: {
                        HStack {
                            Image(systemSymbol: SFSymbol.person3)
                            Text("Support this app")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    if Constants.Feature.settingsEnabled {
                        Button {
                            isShowingPreferencesView = true
                        } label: {
                            HStack {
                                Image(systemSymbol: .gearshape)
                                Text("Preferences")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                } label: {
                    Image(systemSymbol: .gearshape)
                }
            }
#endif
        }
        
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
#if os(macOS)
                    .frame(minWidth: 100)
#endif
                }
            }
        }
    }
}
