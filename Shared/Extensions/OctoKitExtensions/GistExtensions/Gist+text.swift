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
        if let file = files.first, let url = file.value.rawURL, let text = try? String(contentsOf: url, encoding: .utf8) {
            text
        } else {
            ""
        }
    }

    var lines: [String] {
        text.components(separatedBy: "\n")
    }
}
