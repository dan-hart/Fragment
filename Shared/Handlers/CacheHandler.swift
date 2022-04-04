//
//  CacheHandler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import DHCacheKit
import Foundation
import OctoKit

public class CacheHandler: ObservableObject {
    @Published public var gistsCache = Cache<String, [Gist]>(useLocalDisk: true)

    init() {}
}
