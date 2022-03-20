//
//  SnippetsListView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI
import DHSourcelessKeyValueStore

struct SnippetsListView: View {
    @State var isShowingKeyEntryView = false
    @State var token = DHSourcelessKeyValueStore.shared.getValue(fromKey: "GITHUB_TOKEN")
    
    var body: some View {
        List {
            Text(token ?? "No Value")
                .onAppear {
                    if token == nil {
                        isShowingKeyEntryView = true
                        token = DHSourcelessKeyValueStore.shared.getValue(fromKey: "GITHUB_TOKEN")
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
