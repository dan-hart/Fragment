//
//  ListView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

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

    var filteredGists: [GistDocument] {
        let withVisibility = sessionHandler.gists.filter { gist in
            gist.visibility == visibility
        }

        return GistQuery(rawValue: searchText).filter(withVisibility)
    }

    var filteredBindings: [Binding<GistDocument>] {
        filteredGists.compactMap(binding(for:))
    }

    private func binding(for gist: GistDocument) -> Binding<GistDocument>? {
        guard let index = sessionHandler.gists.firstIndex(where: { $0.id == gist.id }) else {
            return nil
        }

        return $sessionHandler.gists[index]
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(sessionHandler.gistCollectionStatus.title)
                        .font(.system(.headline, design: .monospaced))
                    Text(sessionHandler.gistCollectionStatus.detail)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

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
                VStack(alignment: .leading) {
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
                        VStack(alignment: .leading) {
                            Button {
                                sessionHandler.callTask {
                                    try await sessionHandler.refreshGists()
                                }
                            } label: {
                                HStack {
                                    Image(systemSymbol: .arrowTriangle2CirclepathCircleFill)
                                    Text("Refresh")
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                            .padding()
                        }
                        .font(.system(.footnote, design: .monospaced))
                    }
                }
            } else if filteredBindings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No matching gists")
                        .font(.system(.body, design: .monospaced))
                    Text("Search tips: use text, `ext:swift`, `visibility:public`, or `state:cached`.")
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            } else {
                if !searchText.isEmpty {
                    Text("Results")
                        .font(.system(.body, design: .monospaced))
                }
                ForEach(filteredBindings, id: \.wrappedValue.id) { gist in
                    NavigationLink {
                        CodeView(gist: gist, isLoadingParent: $isLoading)
                            .navigationTitle(gist.wrappedValue.title)
                    } label: {
                        GistRow(data: gist)
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSupportThisAppView) {
            NavigationView {
                SupportThisAppView(showCancelButton: true)
            }
        }
        .sheet(isPresented: $isShowingPreferencesView) {
            NavigationView {
                SettingsView(isLoading: $isLoading)

                    .navigationTitle("Settings")
            }
        }
        .onAppear {
            if sessionHandler.isAuthenticated, sessionHandler.gists.isEmpty, !isLoading {
                sessionHandler.callTask {
                    try await sessionHandler.refreshGists()
                }
            }
        }
        .refreshable {
            if sessionHandler.isAuthenticated {
                sessionHandler.callTask {
                    try await sessionHandler.refreshGists()
                }
            }
        }
        .searchable(text: $searchText, prompt: Text("Search, ext:swift, visibility:public"))
        .redacted(reason: isLoading ? .placeholder : [])
        .toolbar {
            #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            isShowingSupportThisAppView = true
                        } label: {
                            HStack {
                                Image(systemSymbol: SFSymbol.person2Circle)
                                Text("Project resources")
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

            ToolbarItemGroup(placement: .primaryAction) {
                if sessionHandler.isAuthenticated {
                    Button {
                        sessionHandler.callTask {
                            try await sessionHandler.refreshGists()
                        }
                    } label: {
                        HStack {
                            Image(systemSymbol: .arrowTriangle2CirclepathCircleFill)
                            Text("Refresh")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .keyboardShortcut("r")
                }

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
                    .keyboardShortcut("n")
                }
            }
        }
    }
}
