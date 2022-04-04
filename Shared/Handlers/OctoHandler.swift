//
//  OctoHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
import OctoKit

class OctoHandler: ObservableObject {
    @Published var me: User?
    
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

    func gists(using configuration: TokenConfiguration?, then: @escaping ([Gist]?) -> Void) {
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

    // MARK: - Profile
    func fetchMe(using configuration: TokenConfiguration?) async {
        guard let configuration = configuration else {
            return
        }
        self.me = me(using: configuration)
    }

    func me(using configuration: TokenConfiguration) async -> User? {
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
            return nil
        }
    }
}
