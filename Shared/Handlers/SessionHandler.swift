//
//  SessionHandler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation
import KeychainAccess
import OctoKit
import SwiftUI

class SessionHandler: ObservableObject {
    static var keychainKeyIdentifier = "FRAGMENT_GITHUB_API_TOKEN"

    @Published var isAuthenticated = false
}
