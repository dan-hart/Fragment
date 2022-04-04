//
//  TokenHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import Foundation
import KeychainAccess
import OctoKit

class TokenHandler: ObservableObject {
    static var keyName = "GITHUB_API_TOKEN"
    
    @Published var configuration: TokenConfiguration?

    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    var keychain: Keychain {
        Keychain(service: bundleID)
    }

    @Published var value: String?
    @Published var needsAuthentication = true

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

    // MARK: - Authentication
    func checkNeedsAuthenticationStatus() {
        if let token = keychain[TokenHandler.keyName] {
            value = token
            
            needsAuthentication = false
        } else {
            needsAuthentication = true
        }
    }
    
    func authenticate(using token: String, then: @escaping (Bool) -> Void) {
        configuration = TokenConfiguration(token)
        guard let configuration = configuration else {
            return then(false)
        }

        Octokit(configuration).me { [self] response in
            DispatchQueue.main.async { [self] in
                switch response {
                case .success:
                    self.isAuthenticated = true
                case .failure:
                    self.isAuthenticated = false
                }
                then(self.isAuthenticated)
            }
        }
    }
}
