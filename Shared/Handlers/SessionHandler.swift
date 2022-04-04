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
    
    var configuration: TokenConfiguration?

    init() {}

    // MARK: - Methods

    func invalidateSession() {
        delete(key: TokenHandler.keyName)
        isAuthenticated = false
    }

    func taskCheckingAuthenticationStatus() {
        Task {
            await checkAuthenticationStatus()
        }
    }

    /// returns true if authentication succeeded
    func checkAuthenticationStatus() async -> Bool {
        let optionalToken = token

        do {
            if let configuration = try await authenticate(using: optionalToken) {
                self.configuration = configuration
                await MainActor.run {
                    isAuthenticated = true
                }
                return true
            } else {
                return false
            }
        } catch {
            await MainActor.run {
                isAuthenticated = false
            }
            print(error.localizedDescription)
            return false
        }
    }

    func save(token: String) {
        keychain[TokenHandler.keyName] = token
    }

    func delete(key: String = TokenHandler.keyName) {
        keychain[key] = nil
        isAuthenticated = false
    }

    // MARK: - Authentication

    func authenticate(using token: String?) async throws -> TokenConfiguration? {
        guard let token = token else {
            return nil
        }

        let configuration = TokenConfiguration(token)
        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).me { response in
                continuation.resume(returning: response)
            }
        }

        switch response {
        case .success:
            return configuration
        case let .failure(error):
            throw error
        }
    }
}
