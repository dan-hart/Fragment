//
//  GistServices.swift
//  Fragment
//

import Foundation
@preconcurrency import OctoKit

struct AuthenticationService {
    var validateToken: (String) async throws -> TokenConfiguration
    var fetchProfile: (TokenConfiguration) async throws -> User

    static let live = AuthenticationService(
        validateToken: { token in
            guard !token.isEmpty else {
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
        },
        fetchProfile: { configuration in
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
    )
}

struct GistService {
    var fetchMyGists: (TokenConfiguration) async throws -> [GistDocument]
    var fetchMyGist: (String, TokenConfiguration) async throws -> GistDocument?
    var createGist: (String, String, String, Visibility, TokenConfiguration) async throws -> GistDocument
    var updateGist: (String, String, String, String, TokenConfiguration) async throws -> GistDocument

    static let live = GistService(
        fetchMyGists: { configuration in
            try await fetchDocuments(using: configuration)
        },
        fetchMyGist: { identifier, configuration in
            let documents = try await fetchDocuments(using: configuration)
            return documents.first(where: { $0.id == identifier })
        },
        createGist: { filename, description, content, visibility, configuration in
            let response = await withCheckedContinuation { continuation in
                Octokit(configuration).postGistFile(
                    description: description,
                    filename: filename,
                    fileContent: content,
                    publicAccess: visibility == .public
                ) { response in
                    continuation.resume(returning: response)
                }
            }

            switch response {
            case let .success(gist):
                return GistDocument(gist: gist, source: .fresh)
            case let .failure(error):
                throw error
            }
        },
        updateGist: { identifier, description, filename, content, configuration in
            let response = await withCheckedContinuation { continuation in
                Octokit(configuration).patchGistFile(
                    id: identifier,
                    description: description,
                    filename: filename,
                    fileContent: content
                ) { response in
                    continuation.resume(returning: response)
                }
            }

            switch response {
            case let .success(gist):
                return GistDocument(gist: gist, source: .fresh)
            case let .failure(error):
                throw error
            }
        }
    )

    private static func fetchDocuments(using configuration: TokenConfiguration) async throws -> [GistDocument] {
        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).myGists { response in
                continuation.resume(returning: response)
            }
        }

        switch response {
        case let .success(gists):
            return gists.map { GistDocument(gist: $0, source: .fresh) }
        case .failure:
            throw FragmentError.couldNotFetchData
        }
    }
}
