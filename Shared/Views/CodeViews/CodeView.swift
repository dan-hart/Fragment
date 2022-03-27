//
//  CodeView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import Foundation
import Highlightr
import OctoKit
import SwiftUI

struct CodeView: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var gist: Gist

    var theme: Theme {
        colorScheme == .dark ? .atelierSavannaDark : .atelierSavannaLight
    }

    var highlighter: Highlightr? {
        let highlightr = Highlightr()
        highlightr?.setTheme(to: Theme.atelierSavannaDark.rawValue)
        return highlightr
    }

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ForEach(gist.lines.indices, id: \.self) { index in
                HStack {
                    Text("\(index)")
                        .font(.system(.body, design: .monospaced))
                    #if canImport(UIKit)
                        UIKitNSAttributedStringWrapper { label in
                            let lineOfCode = gist.lines[index]
                            if let language = gist.language {
                                label.attributedText = highlighter?.highlight(lineOfCode, as: language.rawValue)
                            } else {
                                label.attributedText = highlighter?.highlight(lineOfCode)
                            }
                        }
                    #endif

                    #if canImport(AppKit)
                        AppKitNSAttributedStringWrapper { label in
                            let lineOfCode = gist.lines[index]
                            if let language = gist.language {
                                label.attributedStringValue = highlighter?.highlight(lineOfCode, as: language.rawValue) ?? NSAttributedString()
                            } else {
                                label.attributedStringValue = highlighter?.highlight(lineOfCode) ?? NSAttributedString()
                            }
                            label.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
                            label.backgroundColor = .clear
                            label.isBezeled = false
                            label.isEditable = false
                            label.sizeToFit()
                        }
                        .frame(minWidth: 1000)
                    #endif
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem {
                Button {
                    #if canImport(UIKit)
                        UIPasteboard.general.string = gist.text
                    #else
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects([(gist.text) as NSString])
                    #endif
                } label: {
                    Text("Copy")
                }
            }
        }
    }
}

// MARK: - UIKit Wrapper

#if canImport(UIKit)
    import UIKit

    struct UIKitNSAttributedStringWrapper: UIViewRepresentable {
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

    struct AppKitNSAttributedStringWrapper: NSViewRepresentable {
        typealias NSViewType = NSTextField
        fileprivate var configuration = { (_: NSViewType) in }

        func makeNSView(context _: NSViewRepresentableContext<Self>) -> NSViewType { NSViewType() }
        func updateNSView(_ nsView: NSViewType, context _: NSViewRepresentableContext<Self>) {
            configuration(nsView)
        }
    }
#endif
