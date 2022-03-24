//
//  TokenHandler.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import DHCryptography
import Foundation

class TokenHandler: ObservableObject {
    static var keyName = "GITHUB_API_TOKEN"

    @Published var value: String?
    @Published var needsAuthentication: Bool = true

    init() {
        checkNeedsAuthenticationStatus()
    }

    func checkNeedsAuthenticationStatus() {
        if let token = try? DHCryptography.shared.decryptValue(fromKey: TokenHandler.keyName) {
            value = token
            needsAuthentication = false
        } else {
            needsAuthentication = true
        }
    }
}
