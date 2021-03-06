//
//  SupportThisAppView.swift
//  Fragment
//
//  Created by Dan Hart on 4/4/22.
//

import SwiftUI

struct SupportThisAppView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    var showCancelButton: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Support this project")
                .font(.system(.title, design: .monospaced))
                .padding(.bottom)
            Text("\(Constants.appName) will always be free and open-source.")
                .font(.system(.headline, design: .monospaced))
                .padding(.bottom)
            Text("If you have found this app useful, please consider:")
                .font(.system(.subheadline, design: .monospaced))
            Button {
                WebLauncher.go(to: URL(string: Constants.URL.repositoryOnGitHub.rawValue))
            } label: {
                Text("Contributing on Github ")
            }
            .padding()
            Text("or")
                .font(.system(.subheadline, design: .monospaced))
                .padding(.horizontal)
            Button {
                WebLauncher.go(to: URL(string: Constants.URL.buyMeACoffee.rawValue))
            } label: {
                Text("☕️ Buying Me A Coffee")
            }
            .padding()
            Text("Thank you,\nDan")
                .font(.system(.subheadline, design: .monospaced))
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if showCancelButton {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportThisAppView(showCancelButton: false)
    }
}
