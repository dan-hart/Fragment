//
//  AuthenticationError.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation

enum AuthenticationError: String, Error {
    case nilToken = "Provided token is nil"
    case invalidToken = "Provided token is invalid"
}
