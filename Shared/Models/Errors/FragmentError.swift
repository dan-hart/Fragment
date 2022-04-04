//
//  FragmentError.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation

enum FragmentError: String, Error {
    case nilToken = "Provided token is nil"
    case nilConfiguratioin = "Configuration is nil"
    case invalidToken = "Provided token is invalid"

    // MARK: - Data

    case couldNotFetchData = "Could not fetch data"
}
