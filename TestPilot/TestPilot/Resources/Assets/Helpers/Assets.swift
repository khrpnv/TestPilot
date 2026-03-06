//
//  Assets.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import SwiftUI

enum Assets {
    enum Shared {
        enum Images {
            static let logo = Image("image_logo")
        }
        enum Icons {
            static let copy = Image(systemName: "doc.on.doc")
            static let close = Image(systemName: "xmark")
            static let plus = Image(systemName: "plus")
            static let rightArrow = Image(systemName: "arrow.right")
        }
    }
}
