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
                TextField("Code", text: $content)
            }

            Button {
                snippetHandler.create(gistFrom: filename,
                                      description: description,
                                      content: content,
                                      visibility: visibility)
                { optionalGist in
                    if optionalGist != nil {
                        print("Created Gist")
                    }
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Save")
                    .font(.system(.body, design: .monospaced))
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
