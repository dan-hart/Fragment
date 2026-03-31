//
//  CodeView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

@preconcurrency import CodeEditor
import Foundation
import SFSafeSymbols
import SwiftUI

struct CodeView: View {
    @EnvironmentObject var sessionHandler: SessionHandler

    @Environment(\.colorScheme) var colorScheme

    var theme: CodeEditor.ThemeName {
        colorScheme == .dark ? .atelierSavannaDark : .atelierSavannaLight
    }

    @Binding var gist: GistDocument
    @Binding var isLoadingParent: Bool

    @State var loadedSourceCode = ""
    @State var sourceCode = ""
    @State var savePreview: GistSavePreview?
    @State var isShowingSaveSheet = false

    var body: some View {
        VStack(spacing: 0) {
            if !sessionHandler.isAuthenticated {
                Text("Read-only cached view. Sign in again before saving changes.")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }

            if loadedSourceCode != sourceCode {
                Text(GistDiffSummary(original: loadedSourceCode, updated: sourceCode).headline)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.quaternary)
            }

            ScrollView([.horizontal, .vertical]) {
                ScrollViewReader { reader in
                    CodeEditor(source: $sourceCode, language: CodeEditor.Language(rawValue: gist.fileExtension ?? ""), theme: theme, fontSize: $sessionHandler.cgFloatFontSize, flags: .defaultEditorFlags, indentStyle: .system, autoPairs: nil, inset: nil)
                        .disabled(!sessionHandler.isAuthenticated)
                        .onAppear {
                            reader.scrollTo(0, anchor: .topLeading)
                        }
                }
            }
        }
        .onAppear {
            loadedSourceCode = gist.content
            sourceCode = gist.content
        }
        .sheet(isPresented: $isShowingSaveSheet) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review Changes")
                    .font(.system(.title2, design: .monospaced, weight: .bold))

                if let savePreview {
                    Text(savePreview.summary.headline)
                        .font(.system(.body, design: .monospaced))

                    if savePreview.conflictDetected {
                        Text("GitHub has a newer remote version than the one you opened. Saving now will overwrite those remote changes.")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.red)
                    }

                    if let latestRemoteUpdate = savePreview.latestRemoteUpdate {
                        Text("Latest remote update: \(latestRemoteUpdate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Button("Cancel") {
                        isShowingSaveSheet = false
                    }

                    Spacer()

                    Button(savePreview?.conflictDetected == true ? "Save Anyway" : "Save") {
                        persistChanges(allowConflictOverwrite: savePreview?.conflictDetected == true)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(minWidth: 420)
        }
        .toolbar {
            ToolbarItemGroup {
                if loadedSourceCode != sourceCode, sessionHandler.isAuthenticated {
                    Button {
                        prepareSavePreview()
                    } label: {
                        Text("Review Save")
                            .font(.system(.body, design: .monospaced))
                    }

                    Button {
                        sourceCode = loadedSourceCode
                    } label: {
                        Text("Revert")
                            .font(.system(.body, design: .monospaced))
                    }
                }

                Menu {
                    // Menu Content
                    Button {
                        ClipboardHelper.set(text: gist.content)
                    } label: {
                        HStack {
                            Image(systemSymbol: SFSymbol.docOnDoc)
                            Text("Copy File Contents")
                                .font(.system(.body, design: .monospaced))
                        }
                    }

                    if let url = gist.htmlURL {
                        Button {
                            WebLauncher.go(to: url)
                        } label: {
                            HStack {
                                Image(systemSymbol: SFSymbol.docRichtext)
                                Text("Open on Web")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                    // End Menu Content
                } label: {
                    Image(systemSymbol: .ellipsisCircle)
                }
            }
        }
    }

    private func prepareSavePreview() {
        isLoadingParent = true

        Task {
            var preview: GistSavePreview?
            await sessionHandler.call {
                preview = try await sessionHandler.previewSave(for: gist, proposedContent: sourceCode)
            }

            isLoadingParent = false

            if let preview {
                savePreview = preview
                isShowingSaveSheet = true
            }
        }
    }

    private func persistChanges(allowConflictOverwrite: Bool) {
        isShowingSaveSheet = false
        isLoadingParent = true

        Task {
            var updated: GistDocument?
            await sessionHandler.call {
                updated = try await sessionHandler.update(gist, sourceCode, allowConflictOverwrite: allowConflictOverwrite)
            }

            isLoadingParent = false

            if let updated {
                gist = updated
                loadedSourceCode = updated.content
                sourceCode = updated.content
            }
        }
    }
}
