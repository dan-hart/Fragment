//
//  AuthenticationError.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation

enum AuthenticationError: Error, String {
    case nilToken = "Provided token was nil"
}
