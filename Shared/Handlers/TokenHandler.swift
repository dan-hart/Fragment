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

    @Published var isAuthenticated = false

    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    var keychain: Keychain {
        Keychain(service: bundleID)
    }

    var token: String? {
        keychain[TokenHandler.keyName]
    }

    var isElidgibleForCaching: Bool {
        return isAuthenticated
    }

    var configuration: TokenConfiguration?

    init() {}

    // MARK: - Methods

    func clear() {
        delete(key: TokenHandler.keyName)
        isAuthenticated = false
    }

    func taskCheckingAuthenticationStatus(isLoading: Binding<Bool> = .constant(false)) {
        Task {
            await checkAuthenticationStatus(isLoading: isLoading)
        }
    }

    /// returns true if authentication succeeded
    func checkAuthenticationStatus(isLoading: Binding<Bool> = .constant(false)) async -> Bool {
        let optionalToken = token
        isLoading.wrappedValue = true
        do {
            if let configuration = try await authenticate(using: optionalToken) {
                isLoading.wrappedValue = false
                self.configuration = configuration
                await MainActor.run {
                    isAuthenticated = true
                }
                return true
            } else {
                return false
            }
        } catch {
            isLoading.wrappedValue = false
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
