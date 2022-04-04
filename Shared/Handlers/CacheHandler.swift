//
//  CacheHandler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation
import DHCacheKit
import OctoKit

class CacheHandler: ObservableObject {
    @Published let gistsCache = Cache<String, [Gist]>(useLocalDisk: true)
    
    init() {}
}
