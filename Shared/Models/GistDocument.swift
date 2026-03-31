//
//  GistDocument.swift
//  Fragment
//

import Foundation
@preconcurrency import OctoKit

enum GistSource: String, Codable {
    case fresh
    case cached
}

struct GistDocument: Identifiable, Codable, Hashable {
    let id: String
    var fileName: String
    var gistDescription: String?
    var content: String
    var fileExtension: String?
    var visibility: Visibility
    var htmlURL: URL?
    var updatedAt: Date?
    var source: GistSource

    init(
        id: String,
        fileName: String,
        gistDescription: String?,
        content: String,
        fileExtension: String?,
        visibility: Visibility,
        htmlURL: URL?,
        updatedAt: Date?,
        source: GistSource
    ) {
        self.id = id
        self.fileName = fileName
        self.gistDescription = gistDescription
        self.content = content
        self.fileExtension = fileExtension
        self.visibility = visibility
        self.htmlURL = htmlURL
        self.updatedAt = updatedAt
        self.source = source
    }

    init(gist: Gist, source: GistSource) {
        self.init(
            id: gist.identifier,
            fileName: gist.filename,
            gistDescription: gist.description,
            content: gist.text,
            fileExtension: gist.fileExtension,
            visibility: Visibility(isPublic: gist.publicGist),
            htmlURL: gist.htmlURL,
            updatedAt: gist.updatedAt,
            source: source
        )
    }

    var title: String {
        if fileName.isEmpty {
            "Untitled"
        } else {
            fileName
        }
    }

    var fileNameWithoutExtension: String {
        (fileName as NSString).deletingPathExtension
    }

    func withSource(_ source: GistSource) -> GistDocument {
        var copy = self
        copy.source = source
        return copy
    }

    func updatingContent(_ content: String, updatedAt: Date? = nil, source: GistSource? = nil) -> GistDocument {
        var copy = self
        copy.content = content
        if let updatedAt {
            copy.updatedAt = updatedAt
        }
        if let source {
            copy.source = source
        }
        return copy
    }
}

enum GistCollectionStatus: Equatable {
    case idle
    case loading
    case fresh(Date?)
    case cached(Date?)

    var title: String {
        switch self {
        case .idle:
            "Not loaded"
        case .loading:
            "Refreshing gists"
        case .fresh:
            "Up to date"
        case .cached:
            "Using cached gists"
        }
    }

    var detail: String {
        switch self {
        case .idle:
            "Connect GitHub to load your gists."
        case .loading:
            "Fragment is syncing with GitHub."
        case let .fresh(date):
            if let date {
                "Last synced \(date.formatted(date: .abbreviated, time: .shortened))."
            } else {
                "Showing fresh results from GitHub."
            }
        case let .cached(date):
            if let date {
                "Showing the last cached copy from \(date.formatted(date: .abbreviated, time: .shortened))."
            } else {
                "Showing the last cached copy available on this Mac."
            }
        }
    }
}
