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
    @EnvironmentObject var snippetHandler: SnippetHandler
    @Environment(\.colorScheme) var colorScheme

    var theme: CodeEditor.ThemeName {
        colorScheme == .dark ? .atelierSavannaDark : .atelierSavannaLight
    }

    @Binding var Gist: Gist
    @Binding var isLoadingParent: Bool

    @State var loadedSourceCode = ""
    @State var sourceCode = ""
    @State var assignCodeOnAppear = true

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ScrollViewReader { reader in
                // swiftlint:disable all
                CodeEditor(source: $sourceCode, language: CodeEditor.Language(rawValue: Gist.ext), theme: theme, fontSize: .constant(18), flags: .defaultEditorFlags, indentStyle: .system, autoPairs: nil, inset: nil)
                #if canImport(AppKit)
                    .frame(minWidth: (NSScreen.main?.frame.width ?? 1000) * 0.75, minHeight: (NSScreen.main?.frame.height ?? 1000) * 0.75)
                #endif

                    .onAppear {
                        reader.scrollTo(0, anchor: .topLeading)
                    }
                // swiftlint:enable all
            }
        }
        .content.offset(x: 0, y: 0)
        .onAppear {
            if assignCodeOnAppear {
                loadedSourceCode = Gist.parent.text
                sourceCode = Gist.parent.text
            }
        }
        .onDisappear {
            if loadedSourceCode != sourceCode {
                guard let id = Gist.parent.id,
                      let description = Gist.parent.description,
                      let filename = Gist.parent.files.first?.key
                else {
                    return
                }
                assignCodeOnAppear = false
                snippetHandler.update(id, description, filename, sourceCode) { optionalGist, optionalError in
                    DispatchQueue.main.async {
                        if let gist = optionalGist {
                            Gist = gist.cached
                            sourceCode = Gist.parent.text
                            loadedSourceCode = Gist.parent.text
                        } else {
                            print(optionalError?.localizedDescription ?? "")
                        }
                    }
                }
            } else {
                assignCodeOnAppear = true
            }
        }
        .toolbar {
            ToolbarItem {
                HStack {
                    Menu {
                        // Menu Content
                        Button {
                            #if canImport(UIKit)
                                UIPasteboard.general.string = Gist.parent.text
                            #else
                                let pasteBoard = NSPasteboard.general
                                pasteBoard.clearContents()
                                pasteBoard.writeObjects([(Gist.parent.text) as NSString])
                            #endif
                        } label: {
                            HStack {
                                Image(systemSymbol: SFSymbol.docOnDoc)
                                Text("Copy File Contents")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }

                        if let url = Gist.parent.htmlURL {
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
