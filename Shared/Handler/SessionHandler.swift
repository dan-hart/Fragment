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
    @Published public var isAuthenticated = false
    @Published public var gists: [Gist] = []
    
    private var configuration = TokenConfiguration()
    
    // MARK: - Computed
    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }
    
    private var keychain: Keychain {
        Keychain(service: bundleID)
    }
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Methods
    
    func invalidateSession() {
        keychain[keychainKeyIdentifier] = nil
        isAuthenticated = false
    }
    
    func startSession(with optionalToken: String? = nil) async throws {
        if let token = optionalToken {
            configuration = try await authenticate(using: token)
        } else {
            configuration = try await authenticate(using: getToken())
        }
    }
    
    // MARK: - Authentication
    private func getToken() throws -> String {
        guard let token = keychain[keychainKeyIdentifier] else {
            throw FragmentError.nilToken
        }
        
        return token
    }
    
    private func authenticate(using token: String?) async throws -> TokenConfiguration {
        guard let token = token, !token.isEmpty else {
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
            isAuthenticated = true
            return configuration
        case let .failure(error):
            throw error
        }
    }
    
    // MARK: - Gist CRU
    func update(
        _ id: String,
        _ description: String,
        _ filename: String,
        _ content: String) async throws -> Gist
    {
        try await validate()
        
        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).patchGistFile(id: id,
                                                 description: description,
                                                 filename: filename,
                                                 fileContent: content)
            { response in
                continuation.resume(returning: response)
            }
        }
        
        switch response {
        case let .success(gist):
            return gist
        case let .failure(error):
            throw error
        }
    }
    
    func create(
        gist filename: String,
        _ description: String,
        _ content: String,
        _ visibility: Visibility
    ) async throws -> Gist {
        try await validate()
        
        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).postGistFile(
                description: description,
                filename: filename,
                fileContent: content,
                publicAccess: visibility == .public ? true : false
            ) { response in
                continuation.resume(returning: response)
            }
        }
        
        switch response {
        case let .success(gist):
            return gist
        case let .failure(error):
            throw error
        }
    }
    
    func myGists() async throws -> [Gist] {
        try await validate()
        
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
    
    func me() async throws -> User {
        try await validate()
        
        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).me { response in
                continuation.resume(returning: response)
            }
        }
        
        switch response {
        case let .success(user):
            return user
        case let .failure(error):
            throw error
        }
    }
    
    // MARK: - Helpers
    func validate() async throws {
        if !isAuthenticated { throw FragmentError.notAuthenticated }
    }
    
    func call(thisAsyncThrowingCode: @escaping () -> Void) {
        Task {
        do {
            try await thisAsyncThrowingCode()
        } catch(let error) {
            print(
        }
        }
    }
}
