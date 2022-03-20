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
        .init(size: 18)
    }
    
    var theme: Splash.Theme {
        colorScheme == .dark ? .midnight(withFont: font) : .presentation(withFont: font)
    }
    
    var highlighter: Splash.SyntaxHighlighter<AttributedStringOutputFormat> {
        SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
    }
    
    var url: URL?
    var lines: [String] {
        if let url = url, let text = try? String(contentsOf: url) {
            return text.components(separatedBy: "\n")
        } else {
            return []
        }
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ForEach(lines.indices, id: \.self) { index in
                    HStack {
                        Text("\(index)")
                            .font(.system(size: 18, design: .monospaced))
                        NSASLabel { label in
                            label.attributedText = highlighter.highlight(lines[index])
                        }
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
                    UIPasteboard.general.string = try? String(contentsOf: url)
                } label: {
                    Text("Copy")
                }

            }
        }
    }
}

struct NSASLabel: UIViewRepresentable {
    typealias TheUIView = UILabel
    fileprivate var configuration = { (view: TheUIView) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
