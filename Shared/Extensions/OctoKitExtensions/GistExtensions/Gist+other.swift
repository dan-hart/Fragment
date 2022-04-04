//
//  Gist+other.swift
//  Fragment
//
//  Created by Dan Hart on 4/2/22.
//

import Foundation
import OctoKit

extension Gist {
    var id: String {
        id
    }
    
    var cacheKey: String {
        files.first?.key ?? (id ?? UUID().uuidString)
    }

    var ext: String {
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
