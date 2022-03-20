//
//  GistRow.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SwiftUI
import OctoKit

struct GistRow: View {
    @State var data: Gist?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(data?.files.first?.key ?? "Unknown")
                .font(.system(.title3, design: .monospaced))
            Spacer()
            HStack {
                if let created = data?.createdAt {
                    Text("Created \(created.formatted(date: .abbreviated, time: .standard))")
                        .font(.system(.caption, design: .monospaced))
                }
                Spacer()
                if let updated = data?.updatedAt {
                    Text("Updated \(updated.formatted(date: .abbreviated, time: .standard))")
                        .font(.system(.caption, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                }
            }
            Spacer()
            HStack {
                if data?.publicGist ?? false {
                    HStack {
                        Image(systemName: "network")
                        Text("public")
                            .font(.system(.subheadline, design: .monospaced))
                    }
                } else {
                    HStack {
                        Image(systemName: "lock")
                        Text("private")
                            .font(.system(.subheadline, design: .monospaced))
                    }
                }
                Spacer()
                Text(data?.owner?.login ?? "")
                    .font(.system(size: 16, design: .monospaced))
            }
        }
    }
}
