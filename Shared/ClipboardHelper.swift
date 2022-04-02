//
//  ClipboardHelper.swift
//  Fragment
//
//  Created by Dan Hart on 4/2/22.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum ClipboardHelper {
    func getText() -> String {
#if canImport(UIKit)
    return UIPasteboard.general.string
#else
    return NSPasteboard.general
#endif
    }
}
