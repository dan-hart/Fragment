//
//  AuthenticationView.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import DHCryptography
import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @State var token: String = ""

    var body: some View {
        VStack {
            Text("Github Personal Access Token")
                .font(.system(.body, design: .monospaced))
            SecureField(text: $token,
                        prompt: Text("uZnVflqpqr2U1M9x").font(.system(.body, design: .monospaced))) {
                Text("Token")
                    .font(.system(.body, design: .monospaced))
            }

            Button {
                _ = try? DHCryptography.shared.encrypt(stringDictionary: [TokenHandler.keyName: token])
                tokenHandler.checkNeedsAuthenticationStatus()
            } label: {
                HStack {
                    Image(systemName: "lock")
                    Text("Encrypt")
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .padding()

        .navigationTitle("Authentication")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
