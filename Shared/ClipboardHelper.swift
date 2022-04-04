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
    static func getText() -> String? {
        #if canImport(UIKit)
            return UIPasteboard.general.string
        #else
            var clipboardItems: [String] = []
            for element in NSPasteboard.general.pasteboardItems! {
                if let str = element.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
                    clipboardItems.append(str)
                }
            }

            // Access the item in the clipboard
            return clipboardItems[ifExistsAt: 0]
        #endif
    }

    static func set(text: String) {
        #if canImport(UIKit)
            UIPasteboard.general.string = text
        #else
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.writeObjects([text as NSString])
        #endif
    }
}
