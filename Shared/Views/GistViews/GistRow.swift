//
//  GistRow.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import OctoKit
import SFSafeSymbols
import SwiftUI

struct GistRow: View {
    @State var data: Gist?

    var body: some View {
        VStack(alignment: .leading) {
            Text(data?.files.first?.key ?? "Unknown")
                .font(.system(.headline, design: .monospaced))
            Spacer()
            if let description = data?.description {
                Text("\(description)")
                    .font(.system(.caption, design: .monospaced))
            }
            Spacer()
            if let updated = data?.updatedAt {
                Text("Updated \(updated.formatted(date: .abbreviated, time: .standard))")
                    .font(.system(.caption2, design: .monospaced))
                    .multilineTextAlignment(.trailing)
            }
            Spacer()
            HStack {
                if data?.publicGist ?? false {
                    HStack {
                        Image(systemSymbol: SFSymbol.network)
                        Text("public")
                            .font(.system(.footnote, design: .monospaced))
                    }
                } else {
                    HStack {
                        Image(systemSymbol: SFSymbol.lock)
                        Text("private")
                            .font(.system(.footnote, design: .monospaced))
                    }
                }
            }
        }
    }
}
