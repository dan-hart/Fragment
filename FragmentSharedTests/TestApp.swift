//
//  TestApp.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

@testable import Fragment
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
