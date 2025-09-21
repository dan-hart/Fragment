//
//  SessionHandler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation
import KeychainAccess
import Network
@preconcurrency import OctoKit
@preconcurrency import RequestKit
import SwiftUI

@MainActor
class SessionHandler: ObservableObject {
    var keychainKeyIdentifier = "FRAGMENT_GITHUB_API_TOKEN"

    // MARK: - Publishable data

    @Published var isAuthenticated = false
    @Published var gists: [Gist] = []

    private var configuration = TokenConfiguration()

    // MARK: - Computed

    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    private var keychain: Keychain {
        Keychain(service: bundleID)
    }

    var token: String? {
        keychain[keychainKeyIdentifier]
    }

    // MARK: - Alerts

    @Published var alert: Alert? {
        didSet { isShowingAlert = alert != nil }
    }

    @Published var isShowingAlert = false

    // MARK: - Settings

    @AppStorage("fontSize") var fontSize: Int = 12 {
        didSet {
            cgFloatFontSize = CGFloat(fontSize)
        }
    }

    @Published var cgFloatFontSize: CGFloat = 12

    // MARK: - Initialization

    init() {
        cgFloatFontSize = CGFloat(fontSize)
    }

    // MARK: - Methods

    func invalidateSession() {
        keychain[keychainKeyIdentifier] = nil
        isAuthenticated = false
    }

    func startSession(with optionalToken: String? = nil) async throws {
        if let token = optionalToken {
            // Continue existing session
            configuration = try await authenticate(using: token)
            keychain[keychainKeyIdentifier] = token
        } else {
            // No token. Start a new session by providing one.
        }
    }

    // MARK: - Authentication

    private func getToken() throws -> String {
        guard let token = keychain[keychainKeyIdentifier] else {
            throw FragmentError.nilToken
        }

        return token
    }

    private nonisolated func authenticate(using token: String?) async throws -> TokenConfiguration {
        guard let token, !token.isEmpty else {
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
            await MainActor.run {
                isAuthenticated = true
            }
            return configuration
        case let .failure(error):
            throw error
        }
    }

    // MARK: - Gist CRU

    nonisolated func update(
        _ identifier: String,
        _ description: String,
        _ filename: String,
        _ content: String
    ) async throws -> Gist {
        try await validate()
        let config = await MainActor.run { configuration }

        let response = await withCheckedContinuation { continuation in
            Octokit(config).patchGistFile(id: identifier,
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

    nonisolated func create(
        gist filename: String,
        _ description: String,
        _ content: String,
        _ visibility: Visibility
    ) async throws -> Gist {
        try await validate()
        let config = await MainActor.run { configuration }

        let response = await withCheckedContinuation { continuation in
            Octokit(config).postGistFile(
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

    @MainActor
    func refreshGists() async throws {
        try await validate()
        gists = try await myGists()
    }

    nonisolated func myGists() async throws -> [Gist] {
        try await validate()
        let config = await MainActor.run { configuration }

        let response = await withCheckedContinuation { continuation in
            Octokit(config).myGists { response in
                continuation.resume(returning: response)
            }
        }

        switch response {
        case let .success(gists):
            for gist in gists {
                print(gist.aiPrompt)
            }
            return gists
        case .failure:
            throw FragmentError.couldNotFetchData
        }
    }

    // MARK: - Profile

    nonisolated func me() async throws -> User {
        try await validate()
        let config = await MainActor.run { configuration }

        let response = await withCheckedContinuation { continuation in
            Octokit(config).me { response in
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

    nonisolated func validate() async throws {
        let authenticated = await MainActor.run { isAuthenticated }
        if !authenticated { throw FragmentError.notAuthenticated }
    }

    func call(thisAsyncThrowingCode: @escaping () async throws -> Void) async {
        do {
            try await thisAsyncThrowingCode()
        } catch {
            var errorMessage = ""
            if error is FragmentError {
                errorMessage = (error as? FragmentError)?.rawValue ?? "Error"
            } else {
                errorMessage = error.localizedDescription
            }

            alert = Alert(title: Text("Oops!").font(.system(.body, design: .monospaced)), message: Text(errorMessage).font(.system(.caption, design: .monospaced)))
        }
    }

    func callTask(thisAsyncThrowingCode: @escaping () async throws -> Void) {
        Task {
            await call(thisAsyncThrowingCode: thisAsyncThrowingCode)
        }
    }
}
