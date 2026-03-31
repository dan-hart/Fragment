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

    enum URL: String {
        case repositoryOnGitHub = "https://github.com/dan-hart/Fragment"
        case repositoryIssues = "https://github.com/dan-hart/Fragment/issues"
        case contributorGuide = "https://github.com/dan-hart/Fragment/blob/main/CONTRIBUTING.md"
        case roadmap = "https://github.com/dan-hart/Fragment/blob/main/docs/roadmap.md"
        case githubHowToPersonalAccessToken = "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"
    }

    enum Feature {
        static let localCache = true
        static let ifNoGistsEnableCreateButton = false
        static let ifNoGistsEnablePullButton = true
        static let settingsEnabled = true
    }

    /// Is the current device running macOS or is it an iPad
    @MainActor static func isMacOrPad() -> Bool {
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

extension Notification.Name {
    static let fragmentCreateGist = Notification.Name("fragment.createGist")
    static let fragmentRefreshGists = Notification.Name("fragment.refreshGists")
}
