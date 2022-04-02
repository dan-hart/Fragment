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
    @Environment(\.colorScheme) var colorScheme

    var theme: Theme {
        colorScheme == .dark ? Theme.atelierSavannaDark : Theme.atelierSavannaLight
    }

    @Binding var cachedGist: CachedGist
    @Binding var isLoadingParent: Bool

    @State var sourceCode = ""

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ScrollViewReader { reader in
                // swiftlint:disable all
                CodeEditor(source: $sourceCode, language: .swift, theme: .atelierSavannaDark, fontSize: .constant(18), flags: .defaultEditorFlags, indentStyle: .system, autoPairs: nil, inset: nil)
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
            sourceCode = cachedGist.parent.text
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
                                Text("Copy File Contents")
                            }
                            Label {
                                Text("Copy")
                            } icon: {
                                Image(systemSymbol: SFSymbol.docOnDocFill)
                            }
                        }
                        // End Menu Content
                    } label: {
                        Image(systemSymbol: .ellipsisCircle)
                    }
                    

                    if let url = cachedGist.parent.htmlURL {
                        Button {
                            WebLauncher.go(to: url)
                        } label: {
                            Label {
                                Text("Web")
                            } icon: {
                                Image(systemSymbol: SFSymbol.docPlaintextFill)
                            }
                        }
                    }
                }
            }
        }
    }
}
