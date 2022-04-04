//
//  ContainerView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import OctoKit
import SFSafeSymbols
import SwiftUI

struct ContainerView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var octoHandler: OctoHandler

    @State var isShowingAddModal = false
    @State var searchText = ""

    var body: some View {
        
        .navigationTitle("Gists")
    }
}

struct SnippetsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
}
