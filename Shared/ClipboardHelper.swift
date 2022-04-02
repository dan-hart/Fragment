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
#if canImport(AppKit)
import AppKit
#endif

enum ClipboardHelper {
    static func getText() -> String {
#if canImport(UIKit)
    return UIPasteboard.general.string ?? ""
#else
    return NSPasteboard.general
#endif
    }
    
    static func set(text: String) {
#if canImport(UIKit)
    UIPasteboard.general.string = text
#else
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.writeObjects([(text) as NSString])
#endif
    }
}
