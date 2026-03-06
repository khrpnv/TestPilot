//
//  ViewModel.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 04.07.2025.
//

import AppKit
import Foundation

class ViewModel {
    func openFile(completion: (String, SupportedLanguage) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["swift", "py"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url, let content = try? String(contentsOf: url, encoding: .utf8) {
            let ext = url.pathExtension.lowercased()
            let currentLanguage: SupportedLanguage = (ext == "py") ? .python : .swift
            completion(content, currentLanguage)
        }
    }
    
    func copyToPasteboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
