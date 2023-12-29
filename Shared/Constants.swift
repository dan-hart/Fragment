//
//  Constants.swift
//  Fragment
//
//  Created by Dan Hart on 3/26/22.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

// swiftlint:disable line_length
enum Constants {
    static let appName = "Fragment"
    static let buyMeACoffeeUsername = "codedbydan"

    enum URL: String {
        case repositoryOnGitHub = "https://github.com/dan-hart/Fragment"
        case buyMeACoffee = "https://www.buymeacoffee.com/codedbydan"
        case githubHowToPersonalAccessToken = "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"
    }

    enum Feature {
        static var localCache = false
        static var ifNoGistsEnableCreateButton = false
        static var ifNoGistsEnablePullButton = true
        static var settingsEnabled = true
    }

    /// Is the current device running macOS or is it an iPad
    static func isMacOrPad() -> Bool {
        #if os(macOS)
            return true
        #endif

        #if canImport(UIKit)
            if UIDevice.current.userInterfaceIdiom == .pad {
                return true
            } else {
                return false
            }
        #endif
    }
}

// swiftlint:enable line_length
