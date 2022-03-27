//
//  WebLauncher.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

class WebLauncher {
    static func go(to url: URL?) {
        guard let url = url else {
            return
        }

        #if canImport(UIKit)
            UIApplication.shared.open(url)
        #else
            NSWorkspace.shared.open(url)
        #endif
    }
}
