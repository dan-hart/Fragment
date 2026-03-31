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
            Text("Project Resources")
                .font(.system(.title, design: .monospaced))
                .padding(.bottom)
            Text("\(Constants.appName) is a free and open source GitHub Gist manager.")
                .font(.system(.headline, design: .monospaced))
                .padding(.bottom)
            Text("A few useful places to start:")
                .font(.system(.subheadline, design: .monospaced))
            Button {
                WebLauncher.go(to: URL(string: Constants.URL.repositoryOnGitHub.rawValue))
            } label: {
                Text("View on GitHub")
            }
            .padding()
            Button {
                WebLauncher.go(to: URL(string: Constants.URL.repositoryIssues.rawValue))
            } label: {
                Text("Report an Issue")
            }
            .padding()
            Button {
                WebLauncher.go(to: URL(string: Constants.URL.contributorGuide.rawValue))
            } label: {
                Text("Read the Contributor Guide")
            }
            .padding()
            Button {
                WebLauncher.go(to: URL(string: Constants.URL.roadmap.rawValue))
            } label: {
                Text("View the Roadmap")
            }
            .padding()
            Text("Thanks for helping improve Fragment.")
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
