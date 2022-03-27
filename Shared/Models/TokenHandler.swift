//
//  TokenHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import Foundation

class TokenHandler: ObservableObject {
    static var keyName = "GITHUB_API_TOKEN"

    @Published var value: String?
    @Published var needsAuthentication: Bool = true

    init() {
        checkNeedsAuthenticationStatus()
    }

    func checkNeedsAuthenticationStatus() {
        // TODO: Get token here, set to value
        if true {
            value = nil
            needsAuthentication = false
        } else {
            needsAuthentication = true
        }
    }
}
