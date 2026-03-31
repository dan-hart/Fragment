//
//  FragmentError.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation

enum FragmentError: String, Error {
    case nilToken = "Empty Token"
    case nilConfiguration = "Invalid Configuration"
    case invalidToken = "Provided Token is invalid"
    case notAuthenticated = "Not Authenticated"
    case remoteContentChanged = "This gist changed on GitHub after you opened it. Review the latest copy before saving."

    // MARK: - Data

    case couldNotFetchData = "Could not get data. Check your network connection."
}
