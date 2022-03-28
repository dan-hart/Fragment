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
        if parent.description?.contains(text) ?? false
            || parent.text.contains(text)
            || parent.files.first?.value.filename?.contains(text) ?? false
        {
            return true
        } else {
            return false
        }
    }

    // MARK: - Syntax highlighting

    func loadAttributedLines() async -> [NSAttributedString] {
        var linesGenerator = parent.getLinesGenerator()
        var formattedLines = [NSAttributedString](repeating: NSAttributedString(), count: linesGenerator.lineCount())

        for await(line, index) in linesGenerator {
            formattedLines[index] = line
        }

        return formattedLines
    }
}
