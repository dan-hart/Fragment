//
//  Visibility.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation
import SFSafeSymbols
import SwiftUI

enum Visibility: String, CaseIterable {
    case `public`
    case secret

    init(isPublic: Bool?) {
        if isPublic ?? false {
            self = .public
        } else {
            self = .secret
        }
    }

    var body: some View {
        var symbol: SFSymbol = .star
        switch self {
        case .public:
            symbol = .network
        case .private:
            symbol = .lock
        }

        return HStack {
            Image(systemSymbol: symbol)
            Text(rawValue)
                .font(.system(.footnote, design: .monospaced))
        }
    }
}
