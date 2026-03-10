//
//  AccessibilityAnalysisComponentPurpose.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import Foundation

struct AccessibilityAnalysisComponentPurpose: Codable {
    let componentName: String
    let componentPurpose: String
    let uiPattern: UIPattern
    let domainContext: DomainContext
    let primaryAction: String?
    let secondaryActions: [String]
    let interactiveElements: [InteractiveElement]
    let contentElements: [ContentElement]
    let statesDetected: [DetectedState]
    let dataElements: [DataElement]
    let structuralNotes: [String]

    enum CodingKeys: String, CodingKey {
        case componentName = "component_name"
        case componentPurpose = "component_purpose"
        case uiPattern = "ui_pattern"
        case domainContext = "domain_context"
        case primaryAction = "primary_action"
        case secondaryActions = "secondary_actions"
        case interactiveElements = "interactive_elements"
        case contentElements = "content_elements"
        case statesDetected = "states_detected"
        case dataElements = "data_elements"
        case structuralNotes = "structural_notes"
    }
}

// MARK: - Details
extension AccessibilityAnalysisComponentPurpose {
    enum UIPattern: String, Codable {
        case card
        case listRow = "list_row"
        case settingsRow = "settings_row"
        case formSection = "form_section"
        case confirmationSummary = "confirmation_summary"
        case alertBanner = "alert_banner"
        case controlPanel = "control_panel"
        case dashboardWidget = "dashboard_widget"
        case modalContent = "modal_content"
        case fullScreenView = "full_screen_view"
        case other
    }
    
    enum DomainContext: String, Codable {
        case accountOverview = "account_overview"
        case transferFlow = "transfer_flow"
        case cardManagement = "card_management"
        case transactionHistory = "transaction_history"
        case paymentConfirmation = "payment_confirmation"
        case securityAlert = "security_alert"
        case savingsGoal = "savings_goal"
        case loanOffer = "loan_offer"
        case profileSettings = "profile_settings"
        case authentication = "authentication"
        case other
    }
    
    struct InteractiveElement: Codable {
        let type: InteractiveElementType
        let description: String
    }
    
    enum InteractiveElementType: String, Codable {
        case button
        case gesture
        case toggle
        case navigation
        case input
        case other
    }
    
    struct ContentElement: Codable {
        let type: ContentElementType
        let description: String
    }
    
    struct DetectedState: Codable {
        let state: String
        let trigger: String
    }
    
    struct DataElement: Codable {
        let type: DataElementType
        let description: String
    }
    
    enum DataElementType: String, Codable {
        case amount
        case date
        case accountIdentifier = "account_identifier"
        case status
        case percentage
        case limit
        case identifier
        case other
    }
    
    enum ContentElementType: Codable, Equatable {
        case text
        case image
        case icon
        case value
        case badge
        case input
        case date
        case status
        case other
        case unknown(String)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)

            switch rawValue {
            case "text": self = .text
            case "image": self = .image
            case "icon": self = .icon
            case "value": self = .value
            case "badge": self = .badge
            case "input": self = .input
            case "date": self = .date
            case "status": self = .status
            case "other": self = .other
            default: self = .unknown(rawValue)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .text: try container.encode("text")
            case .image: try container.encode("image")
            case .icon: try container.encode("icon")
            case .value: try container.encode("value")
            case .badge: try container.encode("badge")
            case .input: try container.encode("input")
            case .date: try container.encode("date")
            case .status: try container.encode("status")
            case .other: try container.encode("other")
            case .unknown(let value): try container.encode(value)
            }
        }
    }
}

// MARK: - Helpers
extension AccessibilityAnalysisComponentPurpose {
    func toJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}
