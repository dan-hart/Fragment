//
//  CodeView.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import Foundation
import Splash
import SwiftUI

struct CodeView: View {
    @Environment(\.colorScheme) var colorScheme

    var url: URL?

    // MARK: - Computed Properties

    var font: Splash.Font {
        // TODO: Preference, or dynamic size
        return Splash.Font(size: 18)
    }

    var theme: Splash.Theme {
        colorScheme == .dark ? .midnight(withFont: font) : .presentation(withFont: font)
    }

    var highlighter: Splash.SyntaxHighlighter<AttributedStringOutputFormat> {
        SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
    }

    var text: String {
        if let url = url, let text = try? String(contentsOf: url) {
            return text
        } else {
            return ""
        }
    }

    var lines: [String] {
        text.components(separatedBy: "\n")
    }

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ForEach(lines.indices, id: \.self) { index in
                HStack {
                    Text("\(index)")
                        .font(.system(.body, design: .monospaced))
                    #if canImport(UIKit)
                        UIKitNSAttributedStringWrapper { label in
                            label.attributedText = highlighter.highlight(lines[index])
                        }
                    #endif

                    #if canImport(AppKit)
                        AppKitNSAttributedStringWrapper { label in
                            label.attributedStringValue = highlighter.highlight(lines[index])
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
                    guard let url = url else {
                        return
                    }
                    #if canImport(UIKit)
                        UIPasteboard.general.string = try? String(contentsOf: url)
                    #else
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        let string = try? NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
                        pasteBoard.writeObjects([(string ?? "") as NSString])
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
