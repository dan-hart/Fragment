//
//  Gist+language.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
import OctoKit

extension Gist {
    var language: Language? {
        if let fileURL = url {
            return Language(url: fileURL)
        } else {
            return nil
        }
    }
}
