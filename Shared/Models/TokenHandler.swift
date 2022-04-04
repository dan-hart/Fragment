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
    
    private var configuration: TokenConfiguration
    private var value: String?

    init() {
        configuration = authenticate(using: <#T##String#>, then: <#T##(Bool) -> Void#>)
    }

    // MARK: - Methods
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

    func checkNeedsAuthenticationStatus(attemptReauthentication: Bool = true) {
        if let token = keychain[TokenHandler.keyName] {
            value = token
            if attemptReauthentication {
                configuration = authenticate(using: token) { isAuthenticated in
                    DispatchQueue.main.async {
                        self.isAuthenticated = isAuthenticated
                    }
                }
            } else {
                self.isAuthenticated = false
            }
        }
    }

    func authenticate(using token: String?, then: @escaping (TokenConfiguration?) -> Void) {
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
