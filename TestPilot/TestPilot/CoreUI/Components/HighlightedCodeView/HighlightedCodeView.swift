//
//  HighlightedCodeView.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import AppKit
import SwiftUI
import Highlightr

struct HighlightedCodeView: NSViewRepresentable {
    // MARK: - Properties
    let code: String
    let language: String
    
    // MARK: - Representable
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.autohidesScrollers = true
        
        let textView = NSTextView()
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.isRichText = false
        textView.string = code
        
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let textView = nsView.documentView as? NSTextView {
            updateTextView(textView)
        }
    }
}

// MARK: - Private
private extension HighlightedCodeView {
    func updateTextView(_ textView: NSTextView) {
        let highlightr = Highlightr()
        highlightr?.setTheme(to: Constant.theme)
        
        if let highlighted = highlightr?.highlight(code, as: language) {
            textView.textStorage?.setAttributedString(highlighted)
        } else {
            textView.textStorage?.setAttributedString(
                NSAttributedString(string: code)
            )
        }
    }
}

// MARK: - Constants
private enum Constant {
    static let theme = "paraiso-dark"
}
