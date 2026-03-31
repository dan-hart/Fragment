//
//  SessionHandler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation
import KeychainAccess
@preconcurrency import OctoKit
import SwiftUI

@MainActor
class SessionHandler: ObservableObject {
    var keychainKeyIdentifier = "FRAGMENT_GITHUB_API_TOKEN"

    // MARK: - Publishable data

    @Published var isAuthenticated = false
    @Published var gists: [GistDocument] = []
    @Published var gistCollectionStatus: GistCollectionStatus = .idle
    @Published var lastRefreshError: String?

    private var configuration = TokenConfiguration()

    private let authenticationService: AuthenticationService
    private let gistService: GistService
    private let cacheStore: GistCacheStore

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

    var canBrowseGists: Bool {
        isAuthenticated || !gists.isEmpty
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

    init(
        authenticationService: AuthenticationService = .live,
        gistService: GistService = .live,
        cacheStore: GistCacheStore = GistCacheStore()
    ) {
        self.authenticationService = authenticationService
        self.gistService = gistService
        self.cacheStore = cacheStore
        cgFloatFontSize = CGFloat(fontSize)
    }

    // MARK: - Methods

    func invalidateSession() {
        keychain[keychainKeyIdentifier] = nil
        isAuthenticated = false
        gists = []
        gistCollectionStatus = .idle
        lastRefreshError = nil

        do {
            try cacheStore.clear()
        } catch {
            lastRefreshError = error.localizedDescription
        }
    }

    func clearCachedGists() {
        do {
            try cacheStore.clear()
            gists = []
            gistCollectionStatus = isAuthenticated ? .fresh(nil) : .idle
        } catch {
            lastRefreshError = describe(error)
        }
    }

    func startSession(with optionalToken: String? = nil) async throws {
        guard let token = optionalToken?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !token.isEmpty
        else {
            isAuthenticated = false
            gists = []
            gistCollectionStatus = .idle
            lastRefreshError = nil
            return
        }

        do {
            configuration = try await authenticationService.validateToken(token)
            keychain[keychainKeyIdentifier] = token
            isAuthenticated = true
            lastRefreshError = nil
        } catch {
            isAuthenticated = false

            if try loadCachedGists() == false {
                throw error
            }

            lastRefreshError = describe(error)
            return
        }

        try await refreshGists()
    }

    // MARK: - Gist CRU

    func update(
        _ gist: GistDocument,
        _ content: String,
        allowConflictOverwrite: Bool = false
    ) async throws -> GistDocument {
        try await validate()
        let config = configuration

        if !allowConflictOverwrite,
           let latest = try await gistService.fetchMyGist(gist.id, config),
           GistDiffSummary.conflictExists(remoteContent: latest.content, loadedContent: gist.content)
        {
            throw FragmentError.remoteContentChanged
        }

        let updated = try await gistService.updateGist(
            gist.id,
            gist.gistDescription ?? "",
            gist.fileName,
            content,
            config
        )

        replace(document: updated)
        try persistCache(using: .fresh(Date()))
        return updated
    }

    func create(
        gist filename: String,
        _ description: String,
        _ content: String,
        _ visibility: Visibility
    ) async throws -> GistDocument {
        try await validate()
        let config = configuration
        return try await gistService.createGist(filename, description, content, visibility, config)
    }

    func refreshGists() async throws {
        try await validate()
        gistCollectionStatus = .loading

        do {
            let documents = try await gistService.fetchMyGists(configuration)
            gists = documents
            let now = Date()
            gistCollectionStatus = .fresh(now)
            lastRefreshError = nil
            try persistCache(using: .fresh(now))
        } catch {
            if try loadCachedGists() == false {
                gistCollectionStatus = .idle
                throw error
            }

            lastRefreshError = describe(error)
        }
    }

    func noteCreated(_ gist: GistDocument) {
        gists.insert(gist, at: 0)
        try? persistCache(using: .fresh(Date()))
    }

    // MARK: - Profile

    func me() async throws -> User {
        try await validate()
        return try await authenticationService.fetchProfile(configuration)
    }

    // MARK: - Save Preview

    func previewSave(for gist: GistDocument, proposedContent: String) async throws -> GistSavePreview {
        try await validate()

        let summary = GistDiffSummary(original: gist.content, updated: proposedContent)
        let latest = try await gistService.fetchMyGist(gist.id, configuration)
        let conflictDetected = latest.map {
            GistDiffSummary.conflictExists(remoteContent: $0.content, loadedContent: gist.content)
        } ?? false

        return GistSavePreview(
            summary: summary,
            conflictDetected: conflictDetected,
            latestRemoteUpdate: latest?.updatedAt
        )
    }

    // MARK: - Helpers

    func validate() async throws {
        if !isAuthenticated {
            throw FragmentError.notAuthenticated
        }
    }

    func call(thisAsyncThrowingCode: @escaping () async throws -> Void) async {
        do {
            try await thisAsyncThrowingCode()
        } catch {
            alert = Alert(
                title: Text("Oops!").font(.system(.body, design: .monospaced)),
                message: Text(describe(error)).font(.system(.caption, design: .monospaced))
            )
        }
    }

    func callTask(thisAsyncThrowingCode: @escaping () async throws -> Void) {
        Task {
            await call(thisAsyncThrowingCode: thisAsyncThrowingCode)
        }
    }

    private func replace(document: GistDocument) {
        if let index = gists.firstIndex(where: { $0.id == document.id }) {
            gists[index] = document
        }
    }

    @discardableResult
    private func loadCachedGists() throws -> Bool {
        guard let snapshot = try cacheStore.load() else {
            return false
        }

        gists = snapshot.documents.map { $0.withSource(.cached) }
        gistCollectionStatus = .cached(snapshot.syncedAt)
        return true
    }

    private func persistCache(using status: GistCollectionStatus) throws {
        let documents = gists.map { $0.withSource(.fresh) }
        let snapshot = GistCacheSnapshot(syncedAt: Date(), documents: documents)
        try cacheStore.save(snapshot)
        gistCollectionStatus = status
    }

    private func describe(_ error: Error) -> String {
        if let fragmentError = error as? FragmentError {
            fragmentError.rawValue
        } else {
            error.localizedDescription
        }
    }
}
