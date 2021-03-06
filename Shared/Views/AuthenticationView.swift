//
//  AuthenticationView.swift
//  Fragment
//
//  Created by Dan Hart on 3/23/22.
//

import SFSafeSymbols
import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

    @Binding var isLoading: Bool

    @State var token: String = ""
    @State var isShowingSupportThisAppView = false

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
            .onSubmit {
                go()
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
                .padding(.bottom)
            }
            Divider()
            Button {
                isShowingSupportThisAppView = true
            } label: {
                HStack {
                    Image(systemSymbol: SFSymbol.person3)
                    Text("Support this app")
                        .font(.system(.body, design: .monospaced))
                }
            }
            .padding(.top)
            Spacer()
        }
        .sheet(isPresented: $isShowingSupportThisAppView) {
            NavigationView {
                SupportThisAppView(showCancelButton: true)
            }
        }
        .redacted(reason: isLoading ? .placeholder : [])
        .padding()

        .navigationTitle("Authentication")
    }

    func go() {
        sessionHandler.callTask {
            try await sessionHandler.startSession(with: token)
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(isLoading: .constant(false))
    }
}
