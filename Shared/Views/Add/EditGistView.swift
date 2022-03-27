//
//  EditGistView.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import SwiftUI

struct EditGistView: View {
    @EnvironmentObject var snippetHandler: SnippetHandler
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

//    @Binding var existingFilename: String?
//    @Binding var existingDescription: String?
//    @Binding var existingVisibility: Visibility?
//    @Binding var existingContent: String?

    @State var filename: String
    @State var description: String
    @State var visibility: Visibility
    @State var content: String

    @State var isAddingData = true
    @State var error: String?

    var body: some View {
        Form {
            Section(header: Text("Details").font(.system(.caption, design: .monospaced))) {
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
                TextEditor(text: $content)
                    .font(.system(.caption, design: .monospaced))
            }

            Button {
                snippetHandler.create(gistFrom: filename,
                                      description: description,
                                      content: content,
                                      visibility: visibility)
                { optionalGist, optionalError in
                    if optionalGist != nil {
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

        .navigationTitle(isAddingData ? "Add Gist" : "Edit Gist")
    }
}

struct EditGistView_Previews: PreviewProvider {
    static var previews: some View {
        EditGistView(
            filename: "",
            description: "",
            visibility: .public,
            content: ""
        )
    }
}
