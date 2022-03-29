//
//  CodeView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import Foundation
import Highlightr
import OctoKit
import SFSafeSymbols
import SwiftUI
import CodeEditor

struct CodeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var theme: Theme {
        colorScheme == .dark ? Theme.atelierSavannaDark : Theme.atelierSavannaLight
    }
    
    @Binding var cachedGist: CachedGist
    @Binding var isLoadingParent: Bool
    
    @State var isLoadingLines = true
    @State var formattedLines: [CodableAttributedString] = []
    @State var triggerLoad = false
    
    @State var sourceCode = ""
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ScrollViewReader { reader in
                EmptyView()
                    .id(0)
                if isLoadingParent || isLoadingLines {
                    VStack(alignment: .leading) {
                        Text("Loading...")
                            .font(.system(.caption, design: .monospaced))
                            .unredacted()
                        Spacer()
                        ForEach(cachedGist.parent.lines, id: \.self) { line in
                            HStack {
                                Text("0")
                                    .font(.system(.caption, design: .monospaced))
                                Text(line)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                    .onAppear {
                        triggerLoad.toggle()
                    }
                } else {
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
        }
        .content.offset(x: 0, y: 0)
        .onAppear {
            sourceCode = cachedGist.parent.text
        }
        .onChange(of: $triggerLoad.wrappedValue, perform: { _ in
            isLoadingLines = true
            Task {
                formattedLines = await cachedGist.loadAttributedLines(using: theme)
                isLoadingLines = false
            }
        })
        .redacted(reason: isLoadingParent || isLoadingLines ? .placeholder : [])
        .padding()
        .toolbar {
            ToolbarItem {
                HStack {
                    Button {
#if canImport(UIKit)
                        UIPasteboard.general.string = cachedGist.parent.text
#else
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects([(cachedGist.parent.text) as NSString])
#endif
                    } label: {
                        Label {
                            Text("Copy")
                        } icon: {
                            Image(systemSymbol: SFSymbol.docOnDocFill)
                        }
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

// MARK: - UIKit Wrapper

#if canImport(UIKit)
import UIKit

struct UIKitCodableAttributedStringWrapper: UIViewRepresentable {
    typealias TheUIView = UILabel
    fileprivate var configuration = { (_: TheUIView) in }
    
    func makeUIView(context _: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context _: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
#endif

// MARK: - AppKit Wrapper

#if canImport(AppKit)
import AppKit

struct AppKitCodableAttributedStringWrapper: NSViewRepresentable {
    typealias NSViewType = NSTextField
    fileprivate var configuration = { (_: NSViewType) in }
    
    func makeNSView(context _: NSViewRepresentableContext<Self>) -> NSViewType { NSViewType() }
    func updateNSView(_ nsView: NSViewType, context _: NSViewRepresentableContext<Self>) {
        configuration(nsView)
    }
}
#endif
