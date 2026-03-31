//
//  GistStorage.swift
//  Fragment
//
//  Created by Codex on 3/30/26.
//

import Foundation

struct GistCacheSnapshot: Codable, Equatable {
    let syncedAt: Date
    let documents: [GistDocument]
}

struct GistCacheStore {
    private let fileManager: FileManager
    let cacheURL: URL

    init(fileManager: FileManager = .default, cacheURL: URL? = nil) {
        self.fileManager = fileManager
        if let cacheURL {
            self.cacheURL = cacheURL
        } else {
            self.cacheURL = Self.defaultCacheURL(fileManager: fileManager)
        }
    }

    func load() throws -> GistCacheSnapshot? {
        guard fileManager.fileExists(atPath: cacheURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: cacheURL)
        return try JSONDecoder().decode(GistCacheSnapshot.self, from: data)
    }

    func save(_ snapshot: GistCacheSnapshot) throws {
        let directory = cacheURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: cacheURL, options: .atomic)
    }

    func clear() throws {
        guard fileManager.fileExists(atPath: cacheURL.path) else {
            return
        }

        try fileManager.removeItem(at: cacheURL)
    }

    private static func defaultCacheURL(fileManager: FileManager) -> URL {
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return applicationSupport
            .appendingPathComponent(Constants.appName, isDirectory: true)
            .appendingPathComponent("gist-cache.json", isDirectory: false)
    }
}

struct GistQuery: Equatable {
    let rawValue: String
    let textTerms: [String]
    let extensionFilter: String?
    let visibilityFilter: Visibility?
    let sourceFilter: GistSource?

    init(rawValue: String) {
        self.rawValue = rawValue

        var textTerms: [String] = []
        var extensionFilter: String?
        var visibilityFilter: Visibility?
        var sourceFilter: GistSource?

        for token in rawValue
            .split(whereSeparator: \.isWhitespace)
            .map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ !$0.isEmpty })
        {
            let lowercasedToken = token.lowercased()
            let parts = lowercasedToken.split(separator: ":", maxSplits: 1).map(String.init)

            if parts.count == 2 {
                let key = parts[0]
                let value = parts[1]
                switch key {
                case "ext", "extension", "language":
                    extensionFilter = value
                case "visibility", "vis":
                    visibilityFilter = Visibility(rawValue: value)
                case "state", "source":
                    sourceFilter = GistSource(rawValue: value)
                default:
                    textTerms.append(lowercasedToken)
                }
            } else {
                textTerms.append(lowercasedToken)
            }
        }

        self.textTerms = textTerms
        self.extensionFilter = extensionFilter
        self.visibilityFilter = visibilityFilter
        self.sourceFilter = sourceFilter
    }

    func filter(_ documents: [GistDocument]) -> [GistDocument] {
        documents.filter(matches(_:))
    }

    func matches(_ document: GistDocument) -> Bool {
        if let extensionFilter,
           document.fileExtension?.lowercased() != extensionFilter
        {
            return false
        }

        if let visibilityFilter, document.visibility != visibilityFilter {
            return false
        }

        if let sourceFilter, document.source != sourceFilter {
            return false
        }

        guard !textTerms.isEmpty else {
            return true
        }

        let haystack = [
            document.fileName,
            document.gistDescription ?? "",
            document.fileExtension ?? "",
            document.content,
        ]
        .joined(separator: "\n")
        .lowercased()

        return textTerms.allSatisfy(haystack.contains(_:))
    }
}

struct GistDiffSummary: Equatable {
    let replacements: Int
    let insertions: Int
    let removals: Int

    init(original: String, updated: String) {
        let originalLines = original.components(separatedBy: .newlines)
        let updatedLines = updated.components(separatedBy: .newlines)

        var insertedCount = 0
        var removedCount = 0

        for change in updatedLines.difference(from: originalLines) {
            switch change {
            case .insert:
                insertedCount += 1
            case .remove:
                removedCount += 1
            }
        }

        let replacements = min(insertedCount, removedCount)
        let insertions = max(0, insertedCount - replacements)
        let removals = max(0, removedCount - replacements)

        self.replacements = replacements
        self.insertions = insertions
        self.removals = removals
    }

    var hasChanges: Bool {
        replacements > 0 || insertions > 0 || removals > 0
    }

    var headline: String {
        if !hasChanges {
            return "No changes"
        }

        var parts: [String] = []
        if replacements > 0 {
            parts.append("\(replacements) replaced")
        }
        if insertions > 0 {
            parts.append("\(insertions) added")
        }
        if removals > 0 {
            parts.append("\(removals) removed")
        }

        return parts.joined(separator: ", ")
    }

    static func conflictExists(remoteContent: String, loadedContent: String) -> Bool {
        normalize(remoteContent) != normalize(loadedContent)
    }

    private static func normalize(_ value: String) -> String {
        value.replacingOccurrences(of: "\r\n", with: "\n")
    }
}

struct GistSavePreview: Equatable {
    let summary: GistDiffSummary
    let conflictDetected: Bool
    let latestRemoteUpdate: Date?
}
