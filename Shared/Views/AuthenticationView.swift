//
//  AuthenticationView.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import SFSafeSymbols
import SwiftUI

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
                .onSubmit {
                                print("Authenticating…")
                            }
                Text("Token")
                    .font(.system(.body, design: .monospaced))
            }

            Button {
                go()
            } label: {
                HStack {
                    Image(systemSymbol: SFSymbol.lock)
                    Text("Validate")
                        .font(.system(.body, design: .monospaced))
                }
            }
            Spacer()
            if let url = URL(string: Constants.URL.githubHowToPersonalAccessToken.rawValue) {
                Button {
                    WebLauncher.go(to: url)
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
    
    func go() {
        tokenHandler.save(token: token)
        tokenHandler.checkNeedsAuthenticationStatus()
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
