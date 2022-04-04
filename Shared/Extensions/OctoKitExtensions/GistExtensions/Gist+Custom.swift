//
//  Gist+Custom.swift
//  Fragment
//
//  Created by Dan Hart on 4/2/22.
//

import Foundation
import OctoKit

public extension Gist {
    /// Non-optional identifier for a gist, uses a UUID as fallback
    var identifier: String {
        id ?? UUID().uuidString
    }

    // The key used to identify an entry in the cache, fallback is identifier
    var cacheKey: String {
        files.first?.key ?? identifier
    }

    var fileExtension: String {
        let filename: NSString = (files.first?.key ?? "") as NSString
        return filename.pathExtension
    }

    // MARK: - Functions

    func meetsSearchCriteria(text: String) -> Bool {
        let descriptionContainsText = description?.lowercased().contains(text.lowercased()) ?? false
        let filenameContainsText = files.first?.value.filename?.lowercased().contains(text.lowercased()) ?? false

        if descriptionContainsText || filenameContainsText {
            return true
        } else {
            return false
        }
    }
}

extension Gist: Equatable {
    public static func == (lhs: Gist, rhs: Gist) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension Gist: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
