//
//  FragmentError.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation

enum FragmentError: String, Error {
    case nilToken = "Empty Token"
    case nilConfiguratioin = "Invalid Configuration"
    case invalidToken = "Provided Token is invalid"
    case notAuthenticated = "Not authenticated"

    // MARK: - Data

    case couldNotFetchData = "Could not fetch data"
}
