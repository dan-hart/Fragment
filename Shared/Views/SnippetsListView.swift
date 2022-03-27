//
//  SnippetsListView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import DHCryptography
import OctoKit
import SwiftUI

struct SnippetsListView: View {
    @EnvironmentObject var tokenHandler: TokenHandler

    @State var gists: [Gist] = []

    var body: some View {
        List {
            ForEach(gists, id: \.id) { gist in
                NavigationLink {
                    CodeView(gist: .constant(gist))
                } label: {
                    GistRow(data: gist)
                        .padding()
                }
            }
        }
        .onAppear {
            let config = TokenConfiguration(tokenHandler.value ?? "")
            Octokit(config).me { response in
                switch response {
                case .success:
                    Octokit(config).myGists { response in
                        switch response {
                        case let .success(gists):
                            self.gists = gists
                        case let .failure(error):
                            print(error)
                        }
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
        .toolbar {
            ToolbarItem {
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
}

struct SnippetsListView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsListView()
    }
}
