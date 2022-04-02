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

    @Binding var cachedGist: CachedGist
    @Binding var isLoadingParent: Bool

    @State var loadedSourceCode = ""
    @State var sourceCode = ""

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ScrollViewReader { reader in
                // swiftlint:disable all
                CodeEditor(source: $sourceCode, language: CodeEditor.Language(rawValue: cachedGist.ext), theme: theme, fontSize: .constant(18), flags: .defaultEditorFlags, indentStyle: .system, autoPairs: nil, inset: nil)
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
            loadedSourceCode = cachedGist.parent.text
            sourceCode = cachedGist.parent.text
        }
        .onDisappear {
            if loadedSourceCode != sourceCode {
                guard let id = cachedGist.parent.id,
                      let description = cachedGist.parent.description,
                      let filename = cachedGist.parent.files.first?.key
                else {
                    return
                }
                snippetHandler.update(id, description, filename, sourceCode) { optionalGist, optionalError in
                    MainActor.run {
                    if let gist = optionalGist {
                        cachedGist = gist.cached
                        sourceCode = cachedGist.parent.text
                    } else {
                        print(optionalError?.localizedDescription ?? "")
                    }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                HStack {
                    Menu {
                        // Menu Content
                        Button {
                            #if canImport(UIKit)
                                UIPasteboard.general.string = cachedGist.parent.text
                            #else
                                let pasteBoard = NSPasteboard.general
                                pasteBoard.clearContents()
                                pasteBoard.writeObjects([(cachedGist.parent.text) as NSString])
                            #endif
                        } label: {
                            HStack {
                                Image(systemSymbol: SFSymbol.docOnDoc)
                                Text("Copy File Contents")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }

                        if let url = cachedGist.parent.htmlURL {
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
