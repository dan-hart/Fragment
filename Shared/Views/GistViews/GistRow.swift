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
                .font(.system(size: 18, design: .monospaced))
            Spacer()
            HStack {
                if let created = data?.createdAt {
                    Text("Created \(created.formatted(date: .abbreviated, time: .standard))")
                        .font(.system(size: 10, design: .monospaced))
                    Spacer()
                }
                if let updated = data?.updatedAt {
                    Text("Updated \(updated.formatted(date: .abbreviated, time: .standard))")
                        .font(.system(size: 10, design: .monospaced))
                    Spacer()
                }
            }
            Spacer()
            HStack {
                if data?.publicGist ?? false {
                    Text("🌎 public")
                        .font(.system(size: 16, design: .monospaced))
                } else {
                    Text("🔒 private")
                        .font(.system(size: 16, design: .monospaced))
                }
                Spacer()
                Text(data?.owner?.login ?? "")
                    .font(.system(size: 16, design: .monospaced))
            }
        }
    }
}
