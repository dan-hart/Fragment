//
//  TokenHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import Foundation
import KeychainAccess
import OctoKit
import SwiftUI

class TokenHandler: ObservableObject {
    static var keyName = "FRAGMENT_GITHUB_API_TOKEN"

    @AppStorage("isAuthenticated") var isAuthenticated = false

    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    var keychain: Keychain {
        Keychain(service: bundleID)
    }

    var configuration: TokenConfiguration?

    init() {
        checkAuthenticationStatus()
    }

    // MARK: - Methods

    func checkAuthenticationStatus() async {
        let optionalToken = getToken()
        authenticate(using: optionalToken) { optionalConfiguration in
            DispatchQueue.main.async {
                if let configuration = optionalConfiguration {
                    self.configuration = configuration
                    self.isAuthenticated = true
                } else {
                    self.isAuthenticated = false
                }
            }
        }
    }

    func getToken() -> String? {
        keychain[TokenHandler.keyName]
    }

    func save(token: String) {
        keychain[TokenHandler.keyName] = token
    }

    func delete(key: String = TokenHandler.keyName) {
        keychain[key] = nil
        isAuthenticated = false
    }

    // MARK: - Authentication

    func authenticate(using token: String?, then: @escaping (TokenConfiguration?) -> Void) async {
        guard let token = token else {
            return then(nil)
        }

        let configuration = TokenConfiguration(token)

        Octokit(configuration).me { response in
            switch response {
            case .success:
                then(configuration)
            case .failure:
                then(nil)
            }
        }
    }
}
