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
