//
//  Gist+text.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
import Highlightr
import OctoKit

extension Gist {
    var text: String {
        if let file = files.first, let url = file.value.rawURL, let text = try? String(contentsOf: url) {
            return text
        } else {
            return ""
        }
    }

    var lines: [String] {
        text.components(separatedBy: "\n")
    }

    func getLinesGenerator() -> LinesGenerator {
        LinesGenerator(from: text, language: language)
    }

    public struct LinesGenerator: AsyncSequence, AsyncIteratorProtocol {
        public typealias Element = (NSAttributedString, Int)
        var text: String
        var language: Language?

        public lazy var lines: [String] = text.components(separatedBy: "\n")

        var highlighter: Highlightr? {
            let highlightr = Highlightr()
            // TODO: Get global theme
            highlightr?.setTheme(to: Theme.atelierSavannaDark.rawValue)
            return highlightr
        }

        public var index = 0

        init(from text: String, language: Language?) {
            self.text = text
            self.language = language
        }

        public mutating func next() async -> Element? {
            guard let line = lines[ifExistsAt: index] else {
                return nil
            }
            var attributedString = NSAttributedString()
            if let language = language {
                attributedString = highlighter?.highlight(line, as: language.rawValue)
                    ?? NSAttributedString()
            } else {
                attributedString = highlighter?.highlight(line)
                    ?? NSAttributedString()
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
}
