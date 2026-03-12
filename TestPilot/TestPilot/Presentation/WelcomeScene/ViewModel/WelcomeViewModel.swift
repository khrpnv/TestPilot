//
//  WelcomeViewModel.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 28.06.2025.
//

import Foundation

enum WelcomeTransition {
    case generate(type: TestType)
    case evaluate
    case userFlows
    case accessibility
}

final class WelcomeViewModel: ViewModel, ObservableObject {
    // MARK: - Transition
    var transitionHandler: (WelcomeTransition) -> ()
    
    // MARK: - Published
    @Published var selectedModel: PromptModel = PromptServiceConfigurations.shared.model
    @Published var isFeatureEnabled: Bool = false
    
    // MARK: - Init
    init(transitionHandler: @escaping (WelcomeTransition) -> ()) {
        self.transitionHandler = transitionHandler
    }
}

// MARK: - Controls
extension WelcomeViewModel {
    func generate(type: TestType) {
        transitionHandler(.generate(type: type))
    }
    
    func evaluate() {
        transitionHandler(.evaluate)
    }
    
    func userFlows() {
        transitionHandler(.userFlows)
    }
    
    func accessibility() {
        ApplicationConfigurations.useMocks = !isFeatureEnabled
        transitionHandler(.accessibility)
    }
    
    func selectModel(_ model: PromptModel) {
        selectedModel = model
        PromptServiceConfigurations.shared.model = model
    }
}
