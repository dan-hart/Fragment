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
    
    var font: Splash.Font {
        return Splash.Font(size: 18)
    }
    
    var theme: Splash.Theme {
        colorScheme == .dark ? .midnight(withFont: font) : .presentation(withFont: font)
    }
    
    var highlighter: Splash.SyntaxHighlighter<AttributedStringOutputFormat> {
        SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
    }
    
    var htmlHighlighter: Splash.SyntaxHighlighter<HTMLOutputFormat> {
        SyntaxHighlighter(format: HTMLOutputFormat())
    }
    
    var url: URL?
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
                    NSASLabel { label in
                        label.attributedText = highlighter.highlight(lines[index])
                    }
#else
                    NSASLabel { label in
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

#if canImport(UIKit)
import UIKit

struct NSASLabel: UIViewRepresentable {
    typealias TheUIView = UILabel
    fileprivate var configuration = { (view: TheUIView) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
#else
import AppKit
struct NSASLabel: NSViewRepresentable {
    typealias NSViewType = NSTextField
    fileprivate var configuration = { (view: NSViewType) in }
    
    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSViewType { NSViewType() }
    func updateNSView(_ nsView: NSViewType, context: NSViewRepresentableContext<Self>) {
        configuration(nsView)
    }
}
#endif
