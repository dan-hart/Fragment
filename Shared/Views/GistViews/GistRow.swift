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
    @Binding var data: Gist

    var filenameNoExtension: String? {
        ((data.files.first?.key ?? "") as NSString).deletingPathExtension
    }

    var fileExtension: String? {
        ((data.files.first?.value.filename ?? "") as NSString).pathExtension
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(filenameNoExtension ?? (data.files.first?.key ?? "Unknown"))
                .font(.system(.headline, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            if let description = data.description, !description.isEmpty {
                Text("\(description)")
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
                Visibility(isPublic: data.publicGist).body
                Spacer()
                if let `extension` = fileExtension, !`extension`.isEmpty {
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
