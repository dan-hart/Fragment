//
//  Gist+Custom.swift
//  Fragment
//
//  Created by Dan Hart on 4/2/22.
//

import Foundation
import OctoKit

extension Gist {
    public var identifier: String {
        id ?? UUID().uuidString
    }
    
    public var cacheKey: String {
        files.first?.key ?? identifier
    }

    public var fileExtension: String {
        let filename: NSString = (files.first?.key ?? "") as NSString
        return filename.pathExtension
    }

    // MARK: - Functions

    public func meetsSearchCriteria(text: String) -> Bool {
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
