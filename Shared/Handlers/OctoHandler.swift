//
//  OctoHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import DHCacheKit
import Foundation
import OctoKit
import SwiftUI

class OctoHandler: ObservableObject {
    @Published var gists = []
    
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
    
    func fetchGists(_ tokenHandler: TokenHandler, _ cacheHandler: CacheHandler, isLoading: Binding<Bool>, usingCache: Bool = true) async throws -> [Gist] {
        isLoading.wrappedValue = true
        
        if usingCache {
            cacheHandler.gistsCache.removeValue(forKey: tokenHandler.token ?? "")
        }
        
        if !tokenHandler.isAuthenticated {
            tokenHandler.taskCheckingAuthenticationStatus()
        }
        
        let gists = try await self.gists(using: tokenHandler.configuration)
        
        if tokenHandler.isElidgibleForCaching {
            cacheHandler.gistsCache.insert(gists, forKey: tokenHandler.token ?? "")
        }
        isLoading.wrappedValue = false
        
        return gists
    }
    
    func gists(using configuration: TokenConfiguration?) async throws -> [Gist]? {
        guard let configuration = configuration else {
            throw FragmentError.nilConfiguratioin
        }
        
        let response = await withCheckedContinuation { continuation in
            Octokit(configuration).myGists { response in
                continuation.resume(returning: response)
            }
        }
        
        switch response {
        case let .success(gists):
            return gists
        case .failure:
            throw FragmentError.couldNotFetchData
        }
    }
    
    // MARK: - Profile
    
    func me(using configuration: TokenConfiguration?) async -> User? {
        guard let configuration = configuration else {
            return nil
        }
        
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
