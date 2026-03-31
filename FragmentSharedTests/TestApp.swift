//
//  TestApp.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

@testable import Fragment
@preconcurrency import OctoKit
import XCTest

class TestApp: XCTestCase {
    static func appTest() {
        let app = FragmentApp()
        XCTAssertNotNil(app)
    }
}

final class GistQueryTests: XCTestCase {
    func testQueryParsesStructuredFilters() {
        let query = GistQuery(rawValue: "ext:swift visibility:public state:cached utility")

        XCTAssertEqual(query.extensionFilter, "swift")
        XCTAssertEqual(query.visibilityFilter, .public)
        XCTAssertEqual(query.sourceFilter, .cached)
        XCTAssertEqual(query.textTerms, ["utility"])
    }

    func testQueryFiltersDocumentsUsingFiltersAndPlainText() {
        let matching = GistDocument(
            id: "1",
            fileName: "Utility.swift",
            gistDescription: "Helpful utility functions",
            content: "print(\"hello\")",
            fileExtension: "swift",
            visibility: .public,
            htmlURL: nil,
            updatedAt: nil,
            source: .fresh
        )
        let nonMatching = GistDocument(
            id: "2",
            fileName: "Notes.md",
            gistDescription: "Private draft",
            content: "todo",
            fileExtension: "md",
            visibility: .secret,
            htmlURL: nil,
            updatedAt: nil,
            source: .cached
        )

        let query = GistQuery(rawValue: "ext:swift visibility:public state:fresh utility")
        let results = query.filter([matching, nonMatching])

        XCTAssertEqual(results, [matching])
    }
}

final class GistCacheStoreTests: XCTestCase {
    func testCacheStoreRoundTripsSnapshot() throws {
        let cacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let store = GistCacheStore(cacheURL: cacheURL)
        let snapshot = GistCacheSnapshot(
            syncedAt: Date(timeIntervalSince1970: 1234),
            documents: [
                GistDocument(
                    id: "gist-1",
                    fileName: "Snippet.swift",
                    gistDescription: "Cached gist",
                    content: "print(\"cached\")",
                    fileExtension: "swift",
                    visibility: .public,
                    htmlURL: nil,
                    updatedAt: nil,
                    source: .fresh
                ),
            ]
        )

        try store.save(snapshot)
        let loaded = try XCTUnwrap(store.load())

        XCTAssertEqual(loaded, snapshot)
    }
}

final class GistDiffSummaryTests: XCTestCase {
    func testDiffSummaryReportsReplacementsAndInsertions() {
        let summary = GistDiffSummary(
            original: "line 1\nline 2\nline 3",
            updated: "line 1\nline two\nline 3\nline 4"
        )

        XCTAssertTrue(summary.hasChanges)
        XCTAssertEqual(summary.replacements, 1)
        XCTAssertEqual(summary.insertions, 1)
        XCTAssertEqual(summary.removals, 0)
    }

    func testConflictDetectionTriggersWhenRemoteContentChanged() {
        XCTAssertTrue(
            GistDiffSummary.conflictExists(
                remoteContent: "server copy",
                loadedContent: "local baseline"
            )
        )
        XCTAssertFalse(
            GistDiffSummary.conflictExists(
                remoteContent: "same text",
                loadedContent: "same text"
            )
        )
    }
}

@MainActor
final class SessionHandlerTests: XCTestCase {
    func testStartSessionKeepsAuthenticationWhenRefreshFailsWithoutCache() async throws {
        let handler = try makeHandler(
            authenticationService: makeAuthenticationService { _ in
                TokenConfiguration("valid-token")
            },
            gistService: makeGistService { _ in
                throw FragmentError.couldNotFetchData
            }
        )
        defer { handler.invalidateSession() }

        do {
            try await handler.startSession(with: "valid-token")
            XCTFail("Expected refresh failure to be rethrown when no cache exists.")
        } catch {
            XCTAssertEqual(error as? FragmentError, .couldNotFetchData)
        }

        XCTAssertTrue(handler.isAuthenticated)
        XCTAssertTrue(handler.gists.isEmpty)
        XCTAssertEqual(handler.gistCollectionStatus, .idle)
    }

    func testStartSessionTreatsEmptySnapshotAsCachedFallback() async throws {
        let cachedAt = Date(timeIntervalSince1970: 4567)
        let handler = try makeHandler(
            authenticationService: makeAuthenticationService { _ in
                TokenConfiguration("valid-token")
            },
            gistService: makeGistService { _ in
                throw FragmentError.couldNotFetchData
            },
            snapshot: GistCacheSnapshot(syncedAt: cachedAt, documents: [])
        )
        defer { handler.invalidateSession() }

        try await handler.startSession(with: "valid-token")

        XCTAssertTrue(handler.isAuthenticated)
        XCTAssertTrue(handler.gists.isEmpty)
        XCTAssertEqual(handler.gistCollectionStatus, .cached(cachedAt))
        XCTAssertEqual(handler.lastRefreshError, FragmentError.couldNotFetchData.rawValue)
    }

    func testStartSessionLoadsCachedGistsWhenTokenValidationFails() async throws {
        let cachedAt = Date(timeIntervalSince1970: 8765)
        let cachedGist = makeDocument(source: .fresh)
        let handler = try makeHandler(
            authenticationService: makeAuthenticationService { _ in
                throw FragmentError.invalidToken
            },
            gistService: makeGistService { _ in
                XCTFail("Gists should not refresh when token validation fails.")
                return []
            },
            snapshot: GistCacheSnapshot(syncedAt: cachedAt, documents: [cachedGist])
        )
        defer { handler.invalidateSession() }

        try await handler.startSession(with: "revoked-token")

        XCTAssertFalse(handler.isAuthenticated)
        XCTAssertEqual(handler.gists, [cachedGist.withSource(.cached)])
        XCTAssertEqual(handler.gistCollectionStatus, .cached(cachedAt))
        XCTAssertEqual(handler.lastRefreshError, FragmentError.invalidToken.rawValue)
    }

    private func makeHandler(
        authenticationService: AuthenticationService,
        gistService: GistService,
        snapshot: GistCacheSnapshot? = nil
    ) throws -> SessionHandler {
        let cacheURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let cacheStore = GistCacheStore(cacheURL: cacheURL)

        if let snapshot {
            try cacheStore.save(snapshot)
        }

        let handler = SessionHandler(
            authenticationService: authenticationService,
            gistService: gistService,
            cacheStore: cacheStore
        )
        handler.keychainKeyIdentifier = "TEST_TOKEN_\(UUID().uuidString)"
        return handler
    }

    private func makeAuthenticationService(
        validateToken: @escaping (String) async throws -> TokenConfiguration
    ) -> AuthenticationService {
        AuthenticationService(
            validateToken: validateToken,
            fetchProfile: { _ in
                fatalError("Unexpected profile fetch during SessionHandler tests.")
            }
        )
    }

    private func makeGistService(
        fetchMyGists: @escaping (TokenConfiguration) async throws -> [GistDocument]
    ) -> GistService {
        GistService(
            fetchMyGists: fetchMyGists,
            fetchMyGist: { _, _ in
                fatalError("Unexpected single gist fetch during SessionHandler tests.")
            },
            createGist: { _, _, _, _, _ in
                fatalError("Unexpected gist creation during SessionHandler tests.")
            },
            updateGist: { _, _, _, _, _ in
                fatalError("Unexpected gist update during SessionHandler tests.")
            }
        )
    }

    private func makeDocument(
        source: GistSource,
        id: String = "cached-gist"
    ) -> GistDocument {
        GistDocument(
            id: id,
            fileName: "Snippet.swift",
            gistDescription: "Cached gist",
            content: "print(\"cached\")",
            fileExtension: "swift",
            visibility: .public,
            htmlURL: nil,
            updatedAt: nil,
            source: source
        )
    }
}

final class MainViewRoutingTests: XCTestCase {
    func testCachedBrowsingStillShowsAuthenticationPromptWhenSignedOut() {
        XCTAssertEqual(
            MainView.contentState(
                isLoading: false,
                isAuthenticated: false,
                canBrowseGists: true
            ),
            .browsing(showAuthenticationPrompt: true)
        )
    }

    func testAuthenticatedBrowsingDoesNotShowAuthenticationPrompt() {
        XCTAssertEqual(
            MainView.contentState(
                isLoading: false,
                isAuthenticated: true,
                canBrowseGists: true
            ),
            .browsing(showAuthenticationPrompt: false)
        )
    }

    func testUnauthenticatedWithoutCachedGistsShowsAuthenticationFlow() {
        XCTAssertEqual(
            MainView.contentState(
                isLoading: false,
                isAuthenticated: false,
                canBrowseGists: false
            ),
            .authentication
        )
    }
}
