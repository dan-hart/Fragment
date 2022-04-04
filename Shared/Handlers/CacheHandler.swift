//
//  CacheHandler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation
import DHCacheKit
import OctoKit

public class CacheHandler: ObservableObject {
    @Published public var gistsCache = Cache<String, [Gist]>(useLocalDisk: true)
    
    init() {}
}
