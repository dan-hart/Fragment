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
    
    var configuration: TokenConfiguration {
        
    }

    private var configuration: TokenConfiguration
    private var value: String?

    init() {
        checkNeedsAuthenticationStatus()
    }

    // MARK: - Methods

    func save(token: String) {
        keychain[TokenHandler.keyName] = token
    }

    func delete(key: String = TokenHandler.keyName) {
        keychain[key] = nil
        isAuthenticated = false
    }

    // MARK: - Authentication

    func checkNeedsAuthenticationStatus(attemptReauthentication: Bool = true) {
        if let token = keychain[TokenHandler.keyName] {
            value = token
            if attemptReauthentication {
                authenticate(using: token) { isAuthenticated in
                    DispatchQueue.main.async {
                        self.isAuthenticated = isAuthenticated
                    }
                }
            }
        }
    }

    func authenticate(using token: String, then: @escaping (Bool) -> Void) -> TokenConfiguration {
        let configuration = TokenConfiguration(token)

        Octokit(configuration).me { response in
            switch response {
            case .success:
                then(true)
            case .failure:
                then(false)
            }
        }
        
        return configuration
    }
}
