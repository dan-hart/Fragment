//
//  AddGistView.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import CodeEditor
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

    var didAdd: (GistDocument) -> Void

    let clipboard = ClipboardHelper.getText()

    func getSaveButton() -> some View {
        Button {
            let normalizedFilename = normalizedFileName()
            Task {
                do {
                    let gist = try await sessionHandler.create(gist: normalizedFilename, description, content, visibility)
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
                .onChange(of: language) { _ in
                    syncFileExtension()
                }
                TextField("Description", text: $description)
                Picker("Visibility", selection: $visibility) {
                    ForEach(Visibility.allCases, id: \.self) { access in
                        access.body.tag(access)
                    }
                }
                Text("Tip: search later with filters like `ext:\(language.rawValue)` or `visibility:\(visibility.rawValue)`.")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.secondary)
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

    private func normalizedFileName() -> String {
        let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseName = trimmed.isEmpty ? "snippet" : trimmed
        let ext = language.rawValue

        if baseName.hasSuffix(".\(ext)") {
            return baseName
        }

        if (baseName as NSString).pathExtension.isEmpty {
            return "\(baseName).\(ext)"
        }

        return ((baseName as NSString).deletingPathExtension as String) + ".\(ext)"
    }

    private func syncFileExtension() {
        let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        filename = normalizedFileName()
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
