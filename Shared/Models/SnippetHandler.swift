//
//  SnippetHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
import OctoKit

class SnippetHandler: ObservableObject {
    @Published var isAuthenticated = false
    @Published var configuration: TokenConfiguration?

    init() {}

    // MARK: - Add Data

    func create(
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

    // MARK: - Get Data

    func gists(then: @escaping ([Gist]?) -> Void) {
        guard let configuration = configuration else {
            return then(nil)
        }

        Octokit(configuration).myGists { response in
            switch response {
            case let .success(gists):
                then(gists)
            case .failure:
                then(nil)
            }
        }
    }

    // MARK: - Authentication

    func authenticate(using token: String, then: @escaping (Bool) -> Void) {
        configuration = TokenConfiguration(token)
        guard let configuration = configuration else {
            return then(false)
        }

        Octokit(configuration).me { [self] response in
            switch response {
            case .success:
                self.isAuthenticated = true
            case .failure:
                self.isAuthenticated = false
            }
            then(isAuthenticated)
        }
    }
}