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

    /// The extension with no leading `.` of the filename of the first gist
    var fileExtension: String? {
        let filename = "\(files.first?.key ?? "")"
        if filename.isEmpty { return nil }
        return filename.pathExtension
    }

    // MARK: - Functions

    /// Does this gist meet the search criteria based on the search text
    func meetsSearchCriteria(text: String) -> Bool {
        let lowercasedSearchText = text.lowercased()
        let descriptionContainsText = description?.lowercased().contains(lowercasedSearchText) ?? false
        let fileExtensionContainsText = fileExtension?.lowercased().contains(lowercasedSearchText) ?? false
        let filenameContainsText = files.first?.value.filename?.lowercased().contains(lowercasedSearchText) ?? false

        if descriptionContainsText ||
            filenameContainsText ||
            fileExtensionContainsText
        {
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
