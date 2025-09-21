//
//  AddGistView.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import CodeEditor
import OctoKit
import SwiftUI

struct AddGistView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

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
            if !$filename.wrappedValue.hasSuffix(ext) {
                filename.append(ext)
            }
            Task {
                do {
                    let gist = try await sessionHandler.create(gist: filename, description, content, visibility)
                    didAdd(gist)
                    presentationMode.wrappedValue.dismiss()

                } catch {
                    self.error = error.localizedDescription
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
                    .onChange(of: filename) {
                        let pathExtention = (filename as NSString).pathExtension
                        if let lang = Language(rawValue: pathExtention) {
                            language = lang
                        }
                    }
                Picker("Language", selection: $language) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue)
                            .font(.system(.footnote, design: .monospaced))
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
                CodeEditor(source: $content, language: CodeEditor.Language(rawValue: language.rawValue), fontSize: $sessionHandler.cgFloatFontSize)
                    .font(.system(.caption, design: .monospaced))
                    .frame(minHeight: 100)
            }
            .onAppear {
                if let clipboardText = clipboard {
                    content = clipboardText
                }
            }

            #if os(iOS)
                getSaveButton()
            #endif

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
