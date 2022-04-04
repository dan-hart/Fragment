//
//  AddGistView.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import CodeEditor
import OctoKit
import SwifterSwift
import SwiftUI

struct AddGistView: View {
    @EnvironmentObject var tokenHandler: TokenHandler
    @EnvironmentObject var snippetHandler: OctoHandler

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @State var language: Language = .swift
    @State var filename: String
    @State var description: String
    @AppStorage("addingGistDefaultVisibility") var visibility: Visibility = .public
    @State var content: String

    @State var isAddingData = true
    @State var error: String?

    var didAdd: (Gist) -> Void

    let clipboard = ClipboardHelper.getText()

    @ViewBuilder
    func getSaveButton() -> some View {
        Button {
            let ext = ".\(language.rawValue)"
            if !$filename.wrappedValue.ends(with: ext) {
                filename.append(ext)
            }
            snippetHandler.create(
                using: tokenHandler.configuration,
                gist: filename,
                description,
                content,
                visibility
            ) { optionalGist, optionalError in
                if let gist = optionalGist {
                    didAdd(gist)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    error = optionalError?.localizedDescription
                }
            }
        } label: {
            HStack {
                Text("Save")
                    .font(.system(.body, design: .monospaced))
            }
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Details").font(.system(.caption, design: .monospaced))) {
                TextField("File Name", text: $filename)
                    .onChange(of: filename) { newValue in
                        let filename: NSString = newValue as NSString
                        let pathExtention = filename.pathExtension
                        if let lang = Language(rawValue: pathExtention) {
                            language = lang
                        }
                    }
                Picker("Language", selection: $language) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue)
                            .font(.system(.caption, design: .monospaced))
                            .tag(language.rawValue)
                    }
                }
                TextField("Description", text: $description)
                Picker("Visibility", selection: $visibility) {
                    ForEach(Visibility.allCases, id: \.self) { access in
                        access.body.tag(access)
                    }
                }
            }
            .font(.system(.caption, design: .monospaced))

            if clipboard != nil, !content.isEmpty {
                Button {
                    content = ""
                } label: {
                    Text("Clear Code")
                        .font(.system(.body, design: .monospaced))
                }
            }

            Section(header: Text("Code").font(.system(.caption, design: .monospaced))) {
                CodeEditor(source: $content, language: CodeEditor.Language(rawValue: language.rawValue))
                    .font(.system(.caption, design: .monospaced))
                    .frame(minHeight: 100)
            }
            .onAppear {
                if let clipboardText = clipboard {
                    content = clipboardText
                }
            }

            getSaveButton()

            if error != nil {
                Section(header: Text("Error").font(.system(.body, design: .monospaced))) {
                    Text(error ?? "")
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(.body, design: .monospaced))
                }
            }

            ToolbarItem(placement: .primaryAction) {
                getSaveButton()
            }
        }

        .navigationTitle(isAddingData ? "Add Gist" : "Edit Gist")
    }
}

struct EditGistView_Previews: PreviewProvider {
    static var previews: some View {
        AddGistView(
            filename: "",
            description: "",
            visibility: .public,
            content: ""
        ) { _ in
        }
    }
}
