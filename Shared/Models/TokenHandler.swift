//
//  TokenHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import Foundation
import KeychainAccess

class TokenHandler: ObservableObject {
    static var keyName = "GITHUB_API_TOKEN"

    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    var keychain: Keychain {
        Keychain(service: bundleID)
    }

    @Published var value: String?
    @Published var needsAuthentication: Bool = true

    init() {
        checkNeedsAuthenticationStatus()
    }

    // MARK: - Methods

    func save(token: String) {
        keychain[TokenHandler.keyName] = token
    }

    func delete(key: String = TokenHandler.keyName) {
        keychain[key] = nil
    }

    func checkNeedsAuthenticationStatus() {
        if let token = keychain[TokenHandler.keyName] {
            value = token
            needsAuthentication = false
        } else {
            needsAuthentication = true
        }
    }
}
