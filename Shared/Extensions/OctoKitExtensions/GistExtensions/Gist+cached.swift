//
//  Gist+cached.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
import OctoKit

extension Gist {
    var cached: Gist {
        Gist(parent: self)
    }
}
