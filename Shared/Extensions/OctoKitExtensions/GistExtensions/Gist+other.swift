//
//  Gist+other.swift
//  Fragment
//
//  Created by Dan Hart on 4/2/22.
//

import Foundation
import OctoKit

extension Gist {
    var id: String? {
        parent.id
    }

    var cacheKey: String {
        parent.files.first?.key ?? (id ?? UUID().uuidString)
    }

    var ext: String {
        let filename: NSString = (parent.files.first?.key ?? "") as NSString
        return filename.pathExtension
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
}
