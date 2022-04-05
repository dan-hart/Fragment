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

enum WebLauncher {
    static func go(to url: URL?) {
        guard let url = url else {
            return
        }

        #if canImport(UIKit)
            Task {
                if await UIApplication.shared.open(url) {
                    print("default browser was successfully opened")
                }
            }
        #else
            if NSWorkspace.shared.open(url) {
                print("default browser was successfully opened")
            }
        #endif
    }
}
