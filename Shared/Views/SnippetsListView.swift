//
//  SnippetsListView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI

struct SnippetsListView: View {
    var body: some View {
        List {
            EmptyView()
        }
        
        .navigationTitle("Snippets")
    }
}

struct SnippetsListView_Previews: PreviewProvider {
    static var previews: some View {
        SnippetsListView()
    }
}
