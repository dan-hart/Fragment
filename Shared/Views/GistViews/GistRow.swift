//
//  GistRow.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import SFSafeSymbols
import SwiftUI

struct GistRow: View {
    @Binding var data: GistDocument

    var filenameNoExtension: String? {
        data.fileNameWithoutExtension
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(filenameNoExtension ?? data.title)
                .font(.system(.headline, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            if let description = data.gistDescription, !description.isEmpty {
                Text(description)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
            Spacer()
            if let updated = data.updatedAt {
                Text("Updated \(updated.formatted(date: .abbreviated, time: .standard))")
                    .font(.system(.caption2, design: .monospaced))
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
            Spacer()
            HStack {
                data.visibility.body
                Spacer()
                if data.source == .cached {
                    Text("cached")
                        .font(.system(.caption2, design: .monospaced))
                        .lineLimit(1)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder()
                                .foregroundColor(.orange)
                        )
                }
                if let `extension` = data.fileExtension, !`extension`.isEmpty {
                    Text(`extension`)
                        .font(.system(.footnote, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder()
                                .foregroundColor(.gray)
                        )
                }
            }
        }
    }
}
