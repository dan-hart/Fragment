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
    var cache = Cache<String, [CodableAttributedString]>()
    private var _attributedLines: [CodableAttributedString]?

    // swiftlint:disable identifier_name
    var id: String? {
        parent.id
    }

    var cacheKey: String {
        parent.files.first?.key ?? (id ?? UUID().uuidString)
    }

    // swiftlint:enable identifier_name

    init(parent: Gist) {
        self.parent = parent
        _attributedLines = cache.value(forKey: cacheKey)
    }

    // MARK: - Functions

    func clearCache() {
        cache.removeValue(forKey: id ?? UUID().uuidString)
        _ = try? cache.deleteFromDisk(with: cacheKey)
    }

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

    func loadAttributedLines(using theme: Theme) async -> [CodableAttributedString] {
        if let existingAttributedLines = _attributedLines {
            return existingAttributedLines
        }

        var linesGenerator = parent.getLinesGenerator(using: theme)
        let empty = NSAttributedString()
        let count = linesGenerator.lineCount()
        var formattedLines = [CodableAttributedString](repeating: CodableAttributedString(value: empty), count: count)

        for await(line, index) in linesGenerator {
            formattedLines[index] = line
        }

        cache.insert(formattedLines, forKey: cacheKey)
        _attributedLines = formattedLines

        return formattedLines
    }
}
