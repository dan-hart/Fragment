//
//  AuthenticationView.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import SFSafeSymbols
import SwiftUI
#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

struct AuthenticationView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @State var token: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Github Personal Access Token")
                .font(.system(.body, design: .monospaced))
            SecureField(text: $token,
                        prompt: Text("uZnVflqpqr2U1M9x984h3985a48dn74n").font(.system(.body, design: .monospaced))) {
                Text("Token")
                    .font(.system(.body, design: .monospaced))
            }

            Button {
                tokenHandler.save(token: token)
                tokenHandler.checkNeedsAuthenticationStatus()
            } label: {
                HStack {
                    Image(systemSymbol: SFSymbol.lock)
                    Text("Encrypt")
                        .font(.system(.body, design: .monospaced))
                }
            }
            Spacer()
            if let url = URL(string: Constants.URL.githubHowToPersonalAccessToken.rawValue) {
                Button {
                    #if canImport(UIKit)
                        UIApplication.shared.open(url)
                    #else
                        NSWorkspace.shared.open(url)
                    #endif
                } label: {
                    HStack {
                        Image(systemSymbol: SFSymbol.questionmarkCircle)
                        Text("How To")
                            .font(.system(.body, design: .monospaced))
                    }
                }
                Spacer()
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
