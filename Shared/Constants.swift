//
//  Constants.swift
//  Fragment
//
//  Created by Dan Hart on 3/26/22.
//

import Foundation
#if canImport(UIKit)

// swiftlint:disable line_length
enum Constants {
    enum URL: String {
        case githubHowToPersonalAccessToken = "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"
    }

    enum Feature {
        static var ifNoGistsEnablePullButton = true
    }
    
    /// Is the current device running macOS or is it an iPad
    public var isMacOrPad: Bool {
        #if os(macOS)
        return true
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
        #endif
    }
}

// swiftlint:enable line_length
