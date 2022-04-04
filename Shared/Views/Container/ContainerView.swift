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

    @State var isLoading = false
    @State var isShowingAddModal = false
    @State var searchText = ""

    var body: some View {
        NavigationView {
            ListView(isLoading: $isLoading, searchText: $searchText)
        }
        
        .navigationTitle("Gists")
    }
}

struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
}
