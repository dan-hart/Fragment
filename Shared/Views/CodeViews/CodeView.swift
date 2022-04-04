//
//  CodeView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import CodeEditor
import Foundation
import Highlightr
import OctoKit
import SFSafeSymbols
import SwiftUI

struct CodeView: View {
    @EnvironmentObject var sessionHandler: SessionHandler
    
    @Environment(\.colorScheme) var colorScheme

    var theme: CodeEditor.ThemeName {
        colorScheme == .dark ? .atelierSavannaDark : .atelierSavannaLight
    }

    @Binding var gist: Gist
    @Binding var isLoadingParent: Bool

    @State var loadedSourceCode = ""
    @State var sourceCode = ""

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ScrollViewReader { reader in
                CodeEditor(source: $sourceCode, language: CodeEditor.Language(rawValue: gist.fileExtension ?? ""), theme: theme, fontSize: .constant(18), flags: .defaultEditorFlags, indentStyle: .system, autoPairs: nil, inset: nil)
                    .onAppear {
                        reader.scrollTo(0, anchor: .topLeading)
                    }
            }
        }
        .content.offset(x: 0, y: 0)
        .onAppear {
            loadedSourceCode = gist.text
            sourceCode = gist.text
        }
        .toolbar {
            ToolbarItem {
                HStack {
                    if loadedSourceCode != sourceCode {
                        Button {
                            guard let id = gist.id,
                                  let description = gist.description,
                                  let filename = gist.files.first?.key
                            else {
                                return
                            }
                            
                            isLoadingParent = true
                            sessionHandler.callTask {
                                let text = try await sessionHandler.update(id, description, filename, sourceCode)
                                self.isLoadingParent = false
                            }

                            octoHandler.update(
                                using: tokenHandler.configuration,
                                id,
                                description,
                                filename,
                                sourceCode
                            ) { optionalGist, optionalError in
                                isLoadingParent = false
                                DispatchQueue.main.async {
                                    if let gist = optionalGist {
                                        sourceCode = gist.text
                                        loadedSourceCode = gist.text
                                    } else {
                                        print(optionalError?.localizedDescription ?? "")
                                    }
                                }
                            }
                        } label: {
                            Text("Save")
                                .font(.system(.body, design: .monospaced))
                        }
                    }

                    Menu {
                        // Menu Content
                        Button {
                            ClipboardHelper.set(text: gist.text)
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
    }
}
