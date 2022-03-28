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

    func getLinesGenerator(using theme: Theme) -> LinesGenerator {
        LinesGenerator(from: text, theme, language: language)
    }
}
