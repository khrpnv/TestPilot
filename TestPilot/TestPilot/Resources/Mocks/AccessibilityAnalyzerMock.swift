//
//  AccessibilityAnalyzerMock.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

enum AccessibilityAnalyzerMock {
    static let response = PromptResponse(
        choices: [
            .init(
                message: .init(
                    role: .assistant,
                    content: "{\n  \"view\": \"CardEntryView\",\n  \"issues\": [\n    {\n      \"id\": \"Label-1\",\n      \"type\": \"Label\",\n      \"line\": 11,\n      \"description\": \"Icon-only button is missing an accessibility label.\",\n      \"suggestion\": \"Add an .accessibilityLabel to the Button containing the \'xmark\' Image.\",\n      \"severity\": \"High\",\n      \"manualCheck\": false\n    },\n    {\n      \"id\": \"TouchTarget-1\",\n      \"type\": \"TouchTarget\",\n      \"line\": 12,\n      \"description\": \"Image button might be too small to touch easily.\",\n      \"suggestion\": \"Ensure the button has a minimum size of 44x44 points.\",\n      \"severity\": \"Low\",\n      \"manualCheck\": true\n    },\n    {\n      \"id\": \"SensitiveData-1\",\n      \"type\": \"SensitiveData\",\n      \"line\": 19,\n      \"description\": \"Card number is exposed to accessibility.\",\n      \"suggestion\": \"Mask the card number in the accessibility label or use secure text entry.\",\n      \"severity\": \"High\",\n      \"manualCheck\": false\n    },\n    {\n      \"id\": \"DynamicType-1\",\n      \"type\": \"DynamicType\",\n      \"line\": 24,\n      \"description\": \"TextField does not support Dynamic Type.\",\n      \"suggestion\": \"Ensure that the font scales with Dynamic Type settings using .font(.system(.body, design: .default)).\",\n      \"severity\": \"Medium\",\n      \"manualCheck\": false\n    },\n    {\n      \"id\": \"DynamicType-2\",\n      \"type\": \"DynamicType\",\n      \"line\": 29,\n      \"description\": \"TextField does not support Dynamic Type.\",\n      \"suggestion\": \"Ensure that the font scales with Dynamic Type settings using .font(.system(.body, design: .default)).\",\n      \"severity\": \"Medium\",\n      \"manualCheck\": false\n    },\n    {\n      \"id\": \"DynamicType-3\",\n      \"type\": \"DynamicType\",\n      \"line\": 32,\n      \"description\": \"TextField does not support Dynamic Type.\",\n      \"suggestion\": \"Ensure that the font scales with Dynamic Type settings using .font(.system(.body, design: .default)).\",\n      \"severity\": \"Medium\",\n      \"manualCheck\": false\n    },\n    {\n      \"id\": \"DynamicType-4\",\n      \"type\": \"DynamicType\",\n      \"line\": 38,\n      \"description\": \"Toggle does not support Dynamic Type.\",\n      \"suggestion\": \"Ensure that the font scales with Dynamic Type settings using .font(.system(.body, design: .default)).\",\n      \"severity\": \"Medium\",\n      \"manualCheck\": false\n    },\n    {\n      \"id\": \"TouchTarget-2\",\n      \"type\": \"TouchTarget\",\n      \"line\": 45,\n      \"description\": \"Button has small vertical padding, potentially reducing touch target size.\",\n      \"suggestion\": \"Consider increasing padding to ensure a minimum height of 44 points.\",\n      \"severity\": \"Low\",\n      \"manualCheck\": true\n    }\n  ],\n  \"score\": 1\n}"
                )
            )
        ]
    )
}
