//
//  LinesGenerator.swift
//  Fragment
//
//  Created by Dan Hart on 3/28/22.
//

import Foundation
import Highlightr

public struct LinesGenerator: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = (CodableAttributedString, Int)
    var text: String
    var theme: Theme
    var language: Language?

    public lazy var lines: [String] = text.components(separatedBy: "\n")

    var highlighter: Highlightr? {
        let highlightr = Highlightr()
        highlightr?.setTheme(to: theme.rawValue)
        return highlightr
    }

    public var index = 0

    init(from text: String, _ theme: Theme, language: Language?) {
        self.text = text
        self.theme = theme
        self.language = language
    }

    public mutating func next() async -> Element? {
        guard let line = lines[ifExistsAt: index] else {
            return nil
        }
        var attributedString = CodableAttributedString(value: NSAttributedString())
        if let language = language {
            attributedString = CodableAttributedString(value: highlighter?.highlight(line, as: language.rawValue)
                ?? NSAttributedString())
        } else {
            attributedString = CodableAttributedString(value: highlighter?.highlight(line) ?? NSAttributedString())
        }

        let element = (attributedString, index)
        index += 1
        return element
    }

    public func makeAsyncIterator() -> LinesGenerator {
        self
    }

    public mutating func lineCount() -> Int {
        return lines.count
    }
}
