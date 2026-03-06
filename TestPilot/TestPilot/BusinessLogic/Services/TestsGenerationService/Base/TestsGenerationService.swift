//
//  TestsGenerationService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import Foundation

protocol TestsGenerationService {
    func generateTests(
        code: String,
        language: SupportedLanguage,
        completion: @escaping (Result<String, Error>) -> Void
    )
}
