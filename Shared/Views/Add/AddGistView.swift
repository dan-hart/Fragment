//
//  EditGistView.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import CodeEditor
import OctoKit
import SwiftUI

struct AddGistView: View {
    @EnvironmentObject var snippetHandler: SnippetHandler
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @State var language: Language = .swift
    @State var filename: String
    @State var description: String
    @AppStorage("addingGistDefaultVisibility") var visibility: Visibility = .public
    @State var content: String

    @State var isAddingData = true
    @State var error: String?

    var didAdd: (Gist) -> Void

    var body: some View {
        Form {
            Section(header: Text("Details").font(.system(.caption, design: .monospaced))) {
                Picker("Language", selection: $language) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue)
                            .font(.system(.caption, design: .monospaced))
                            .tag(language.rawValue)
                    }
                }
                TextField("File Name", text: $filename)
                TextField("Description", text: $description)
                Picker("Visibility", selection: $visibility) {
                    ForEach(Visibility.allCases, id: \.self) { access in
                        access.body.tag(access)
                    }
                }
            }
            .font(.system(.caption, design: .monospaced))

            Section(header: Text("Content").font(.system(.caption, design: .monospaced))) {
                CodeEditor(source: $content, language: CodeEditor.Language(rawValue: language.rawValue))
                    .font(.system(.caption, design: .monospaced))
            }

            Button {
                snippetHandler.create(gist: filename, description, content, visibility) { optionalGist, optionalError in
                    if let gist = optionalGist {
                        didAdd(gist)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        error = optionalError?.localizedDescription
                    }
                }
            } label: {
                Text("Save")
                    .font(.system(.body, design: .monospaced))
            }

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
