//
//  CachedGist.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import DHCacheKit
import Foundation
import Highlightr
import OctoKit

class CachedGist {
    var parent: Gist

    var id: String? {
        parent.id
    }

    var cacheKey: String {
        parent.files.first?.key ?? (id ?? UUID().uuidString)
    }
    
    var ext: String {
        let filename: NSString = parent.files.first?.key ?? ""
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
