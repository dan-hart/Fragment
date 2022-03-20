//
//  SnippetsListView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI
import DHSourcelessKeyValueStore
import OctoKit

struct SnippetsListView: View {
    @State var isShowingKeyEntryView = false
    @State var token: String? = DHSourcelessKeyValueStore.shared.getValue(fromKey: "GITHUB_TOKEN")
    @State var connectedUsername: String?
    @State var gists: [Gist] = []
    
    var body: some View {
        List {
            if connectedUsername == nil {
                if token == nil || token?.isEmpty ?? true {
                    Text("⚠️ Missing Token")
                } else {
                    Text("Loading...")
                }
            } else {
                ForEach(gists, id: \.id) { gist in
                    NavigationLink {
                        CodeView(url: gist.files.first?.value.rawURL)
                    } label: {
                        GistRow(data: gist)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            if token == nil {
                isShowingKeyEntryView = true
                token = DHSourcelessKeyValueStore.shared.getValue(fromKey: "GITHUB_TOKEN")
            } else {
                let config = TokenConfiguration(token)
                Octokit(config).me() { response in
                    switch response {
                    case .success(let user):
                        connectedUsername = user.login
                        
                        Octokit(config).myGists { response in
                            switch response {
                            case let .success(gists):
                                self.gists = gists.filter({ gist in
                                    gist.files.first?.value.filename?.contains(".swift") ?? false
                                })
                            case let .failure(error):
                                print(error)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingKeyEntryView) {
            SourcelessEntryView()
        }
        
        .navigationTitle("Snippets")
    }
}

struct SnippetsListView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsListView()
    }
}
