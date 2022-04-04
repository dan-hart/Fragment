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
    var keychainKeyIdentifier = "FRAGMENT_GITHUB_API_TOKEN"

    // MARK: - Publishable data
    @Published var isAuthenticated = false
    @Published var gists: [Gist] = []
    
    var configuration: TokenConfiguration?
    
    // MARK: - Computed
    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    var keychain: Keychain {
        Keychain(service: bundleID)
    }

    var token: String? {
        keychain[keychainKeyIdentifier]
    }

    // MARK: - Initialization
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
            throw FragmentError.nilToken
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
    
    // MARK: - Gist CRU
    func update(using configuration: TokenConfiguration?,
                _ id: String,
                _ description: String,
                _ filename: String,
                _ content: String,
                then: @escaping (Gist?, Error?) -> Void)
    {
        guard let configuration = configuration else {
            return then(nil, nil)
        }

        Octokit(configuration).patchGistFile(id: id,
                                             description: description,
                                             filename: filename,
                                             fileContent: content)
        { response in
            switch response {
            case let .success(gist):
                then(gist, nil)
            case let .failure(error):
                print(error)
                then(nil, error)
            }
        }
    }

    func create(
        using configuration: TokenConfiguration?,
        gist filename: String,
        _ description: String,
        _ content: String,
        _ visibility: Visibility,
        then: @escaping (Gist?, Error?) -> Void
    ) {
        guard let configuration = configuration else {
            return then(nil, nil)
        }

        Octokit(configuration).postGistFile(
            description: description,
            filename: filename,
            fileContent: content,
            publicAccess: visibility == .public ? true : false
        ) { response in
            switch response {
            case let .success(gist):
                then(gist, nil)
            case let .failure(error):
                print(error)
                then(nil, error)
            }
        }
    }

    func gists(using configuration: TokenConfiguration?) async throws -> [Gist]? {
        guard let configuration = configuration else {
            throw FragmentError.nilConfiguratioin
        }

        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).myGists { response in
                continuation.resume(returning: response)
            }
        }

        switch response {
        case let .success(gists):
            return gists
        case .failure:
            throw FragmentError.couldNotFetchData
        }
    }

    // MARK: - Profile

    func me(using configuration: TokenConfiguration?) async throws -> User? {
        guard let configuration = configuration else {
            throw FragmentError.nilConfiguratioin
        }

        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).me { response in
                continuation.resume(returning: response)
            }
        }
        
        switch response {
        case let .success(user):
            return user
        case let .failure(error):
            print(error)
            throw error
        }
    }
}
