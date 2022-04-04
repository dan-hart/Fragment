//
//  SessionHandler.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import Foundation

class SessionHandler: ObservableObject {
    static var keyName = "FRAGMENT_GITHUB_API_TOKEN"

    @Published var isAuthenticated = false
}
