//
//  CachedGist.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
import Highlightr
import OctoKit

class CachedGist {
    var parent: Gist

    // swiftlint:disable identifier_name
    var id: String? {
        parent.id
    }

    // swiftlint:enable identifier_name

    init(parent: Gist) {
        self.parent = parent
    }

    // MARK: - Functions

    func meetsSearchCriteria(text: String) -> Bool {
        let descriptionContainsText = parent.description?.lowercased().contains(text.lowercased()) ?? false
        let filenameContainsText = parent.files.first?.value.filename?.lowercased().contains(text.lowercased()) ?? false

        if descriptionContainsText || filenameContainsText {
            return true
        } else {
            return false
        }
    }

    // MARK: - Syntax highlighting

    func loadAttributedLines(using theme: Theme) async -> [NSAttributedString] {
        var linesGenerator = parent.getLinesGenerator(using: theme)
        var formattedLines = [NSAttributedString](repeating: NSAttributedString(), count: linesGenerator.lineCount())

        for await(line, index) in linesGenerator {
            formattedLines[index] = line
        }

        return formattedLines
    }
}
