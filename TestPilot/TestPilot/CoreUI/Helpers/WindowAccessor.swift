//
//  WindowAccessor.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> ()

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
