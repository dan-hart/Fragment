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
    @EnvironmentObject var snippetHandler: SnippetHandler

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
            snippetHandler.authenticate(using: tokenHandler.value ?? "") { _ in
                snippetHandler.gists { optionalGists in
                    if let gists = optionalGists {
                        self.gists = gists
                    }
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
