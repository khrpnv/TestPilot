//
//  AccessibilityAnalysisPrompts.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 10.03.2026.
//

import Foundation

enum AccessibilityAnalysisPrompts {
    // MARK: - Purpose Analysis
    enum Purpose {
        static let systemPrompt = """
        You are a senior iOS UI analyst specializing in interpreting SwiftUI components in financial and banking mobile applications.

        Your task is to extract structured intent and UI meaning from SwiftUI code.

        STRICT RULES:
        - Do NOT perform accessibility evaluation.
        - Do NOT identify issues.
        - Do NOT suggest improvements.
        - Do NOT mention WCAG, VoiceOver, accessibility best practices, or design guidelines.
        - Do NOT judge quality.
        - Do NOT speculate about runtime behavior that cannot be inferred from the code.
        - Only describe what can be reasonably inferred from the code itself.
        - If something is uncertain, reflect uncertainty in neutral wording.
        - Be concise, structured, and objective.
        - Output STRICT JSON only.
        - Do not include explanations outside JSON.
        - If the output would not match the required schema, internally correct it and return valid JSON only.
        """
        
        static func createUserPrompt(input: String) -> String {
            return """
            Analyze the following SwiftUI component and generate a structured description of its intent and UI structure.

            Return JSON using EXACTLY the following schema:

            {
              "component_name": "string",
              "component_purpose": "string",
              "ui_pattern": "card | list_row | settings_row | form_section | confirmation_summary | alert_banner | control_panel | dashboard_widget | modal_content | full_screen_view | other",
              "domain_context": "account_overview | transfer_flow | card_management | transaction_history | payment_confirmation | security_alert | savings_goal | loan_offer | profile_settings | authentication | other",
              "primary_action": "string | null",
              "secondary_actions": ["string"],
              "interactive_elements": [
                {
                  "type": "button | gesture | toggle | navigation | input | other",
                  "description": "string"
                }
              ],
              "content_elements": [
                {
                  "type": "text | image | icon | value | badge | input | other",
                  "description": "string"
                }
              ],
              "states_detected": [
                {
                  "state": "string",
                  "trigger": "string"
                }
              ],
              "data_elements": [
                {
                  "type": "amount | date | account_identifier | status | percentage | limit | identifier | other",
                  "description": "string"
                }
              ],
              "structural_notes": [
                "string"
              ]
            }

            Field guidance:

            - component_name:
              Use the SwiftUI struct name if available.

            - component_purpose:
              One clear sentence describing what the component allows the user to see or do.

            - ui_pattern:
              Choose the closest matching option from the predefined list.

            - domain_context:
              Choose the closest matching banking context from the predefined list.

            - primary_action:
              The main user action inferred from the component, or null if none.

            - secondary_actions:
              Additional user actions visible in the component.

            - interactive_elements:
              All interactive elements explicitly defined in the code.

            - content_elements:
              Meaningful visible UI content pieces.

            - states_detected:
              Explicit state variations observable in the code (e.g., expanded/collapsed, locked/unlocked, success/failure, enabled/disabled).

            - data_elements:
              Any dynamic or domain-relevant data such as monetary amounts, dates, account numbers, limits, percentages, or identifiers.

            - structural_notes:
              Neutral structural observations such as:
              - nested interactive elements
              - grouped card layout
              - conditional rendering
              - dynamic values present
              - custom gesture usage
              - multiple related text nodes
              - state-driven UI changes

            SwiftUI component:

            \(input)
            """
        }
    }
    
    // MARK: - Formal checks
    enum FormalChecks {
        static let systemPrompt: String = """
        You are a deterministic SwiftUI accessibility static analyzer for mobile banking applications.

        Your task is to detect FORMAL, code-level accessibility issues that can be directly and unambiguously inferred from SwiftUI source code.

        STRICT RULES:

        - Report only issues triggered by explicit syntactic or structural code patterns.
        - Do NOT perform heuristic UX evaluation.
        - Do NOT speculate about runtime behavior.
        - Do NOT assume layout behavior not visible in code.
        - Do NOT infer issues based on visual meaning, user intent, or likely runtime behavior.
        - The SwiftUI source code is the single source of truth.
        - The Component Brief is supporting context only and must not be treated as proof of an issue.
        - If there is a mismatch between the brief and the code, trust the code.
        - If evidence is insufficient or interpretive, do not report the issue.
        - Prefer false negatives over false positives.
        - Report only issues whose triggering pattern can be deterministically re-checked after code fixes.
        - Use only the most specific matching category for a given code pattern.
        - Do NOT report overlapping findings for the same element or the same underlying trigger.
        - Be precise and evidence-based.
        - Output STRICT JSON only.
        - No explanations outside JSON.
        - If no issues are found, return empty arrays exactly as specified.
        """

        static func createUserPrompt(
            input: String,
            purpose: AccessibilityAnalysisComponentPurpose?
        ) -> String {
            """
            Perform FORMAL accessibility checks on the following SwiftUI component.

            You will receive:
            1. A structured Component Brief (context only)
            2. The SwiftUI source code

            Your task:
            Detect deterministic, code-level accessibility issues only.

            FORMAL CHECK PRINCIPLE

            A formal finding must satisfy all of the following:
            - it is triggered by an explicit code pattern
            - it does not require runtime validation
            - it does not depend primarily on semantic interpretation
            - it can be deterministically re-checked after code fixes

            If any of the above is not true, do not report it as a formal finding.

            Do NOT:
            - perform heuristic evaluation
            - evaluate label wording quality
            - assume runtime behavior
            - invent missing semantics
            - infer layout issues not visible in code
            - report weakly supported concerns just to fill the response

            ------------------------------------------------------------
            FORMAL CHECK CATEGORIES
            ------------------------------------------------------------

            Report an issue only if clearly observable in code.

            1. PRIMARY_INTERACTION_GESTURE
               Report only when:
               - the primary user interaction is implemented with onTapGesture or another gesture handler
               - and the interaction is not implemented with a semantic control such as Button

               Do not also report TAPPABLE_CONTAINER_WITHOUT_ROLE for the same element if this category applies.

            2. TAPPABLE_CONTAINER_WITHOUT_ROLE
               Report only when:
               - HStack, VStack, or ZStack directly acts as an interactive element via a gesture handler
               - and there is no semantic control replacement
               - and PRIMARY_INTERACTION_GESTURE does not already describe the same underlying pattern

            3. FORM_CONTROL_MISSING_LABEL
               Report only for:
               - TextField
               - SecureField
               - Toggle
               - Picker
               - Slider
               - DatePicker
               - Stepper

               Report only when:
               - the control has no explicit visible label in its initializer
               - and no explicit programmatic label is present in code nearby in a clearly attached way

               Do not infer labels from distant surrounding layout or ambiguous nearby text.

            4. MISUSED_ACCESSIBILITY_HIDDEN
               Report only when:
               - .accessibilityHidden(true) is applied to an interactive control
               - or .accessibilityHidden(true) is applied to an element with an explicit gesture handler

               Interactive controls include:
               - Button
               - Toggle
               - TextField
               - SecureField
               - Picker
               - Slider
               - DatePicker
               - Stepper

            5. NESTED_INTERACTIVE_ELEMENTS
               Report only when code explicitly shows one interactive element nested inside another, such as:
               - Button inside Button
               - Button inside a tappable gesture container
               - tappable gesture element inside Button

            6. IMAGE_ONLY_INTERACTIVE_ELEMENT_WITHOUT_LABEL
               Report only when:
               - an interactive element uses Image as its only visible content
               - and there is no explicit accessibilityLabel
               - and the image is not explicitly hidden from accessibility

               Do not report this if visible text is also present inside the same interactive element.

            ------------------------------------------------------------
            CATEGORY PRIORITY RULES
            ------------------------------------------------------------

            If multiple categories could apply to the same code pattern, use only the most specific one.

            Priority order:
            1. PRIMARY_INTERACTION_GESTURE
            2. NESTED_INTERACTIVE_ELEMENTS
            3. FORM_CONTROL_MISSING_LABEL
            4. MISUSED_ACCESSIBILITY_HIDDEN
            5. IMAGE_ONLY_INTERACTIVE_ELEMENT_WITHOUT_LABEL
            6. TAPPABLE_CONTAINER_WITHOUT_ROLE

            Never emit two findings for the same underlying trigger.

            ------------------------------------------------------------
            SEVERITY MODEL
            ------------------------------------------------------------

            Base severity on structural impact:

            - high → primary interaction issues, form control labeling issues, nested interactive conflicts
            - medium → interactive container semantics, hidden interactive content
            - low → minor structural issue with limited impact

            Severity levels:
            - low
            - medium
            - high

            ------------------------------------------------------------
            FORMAL SCORE RULES
            ------------------------------------------------------------

            Assign a score from 1 to 10.

            Scoring guidance:
            - 10 = no formal accessibility issues detected
            - 8-9 = minor formal issues only
            - 6-7 = at least one meaningful medium severity issue
            - 4-5 = multiple medium issues or one serious high severity issue
            - 1-3 = severe structural accessibility problems

            The score must reflect the number and severity of formal findings.
            Lower scores indicate higher structural accessibility risk.

            Do not reduce the score aggressively for a single low-severity issue.

            ------------------------------------------------------------
            OUTPUT FORMAT
            ------------------------------------------------------------

            Return STRICT JSON:

            {
              "score": 1,
              "formal_findings": [
                {
                  "id": "CATEGORY_IDENTIFIER",
                  "category": "PRIMARY_INTERACTION_GESTURE | TAPPABLE_CONTAINER_WITHOUT_ROLE | FORM_CONTROL_MISSING_LABEL | MISUSED_ACCESSIBILITY_HIDDEN | NESTED_INTERACTIVE_ELEMENTS | IMAGE_ONLY_INTERACTIVE_ELEMENT_WITHOUT_LABEL",
                  "severity": "low | medium | high",
                  "confidence": "high",
                  "evidence": "direct reference to observable code pattern",
                  "why_it_matters": "objective explanation of structural accessibility impact",
                  "suggested_fix": "specific SwiftUI-level fix"
                }
              ],
              "analysis_confidence": "high | medium"
            }

            If no issues are found:

            {
              "score": 10,
              "formal_findings": [],
              "analysis_confidence": "high"
            }

            ------------------------------------------------------------

            Component Brief (context only):
            \(purpose?.toJSON() ?? "Not available")

            SwiftUI Component:
            \(input)
            """
        }
    }
    
    // MARK: - Formal Fix
    enum FormalFixes {
        static let systemPrompt: String = """
        You are a deterministic SwiftUI accessibility fixer for mobile banking applications.

        Your task is to apply precise code changes that fix previously detected FORMAL accessibility issues.

        STRICT RULES:

        - Fix only the issues explicitly provided in formal_findings.
        - Do NOT perform heuristic improvements.
        - Do NOT refactor code unless strictly necessary to fix a reported issue.
        - Do NOT change business logic.
        - Do NOT change user-visible behavior unless required to eliminate a reported formal accessibility rule trigger.
        - Preserve original naming, structure, layout, and behavior as much as possible.
        - A fix must eliminate the triggering code pattern for each reported issue whenever possible.
        - Do NOT apply partial mitigations if the original formal violation pattern remains in the code.
        - Prefer semantic replacement over additive accessibility modifiers.
        - If no safe fix can eliminate the trigger without changing business logic, leave that code unchanged.
        - Return complete, formatted, compilable SwiftUI code.
        - Output STRICT JSON only.
        - No explanations outside JSON.
        """
        
        static func createUserPrompt(
            input: String,
            formalFindings: AccessibilityAnalysisFormalFindings?
        ) -> String {
            return """
            Fix the provided SwiftUI component using the given formal accessibility findings.

            You will receive:
            1. The original SwiftUI source code
            2. The formal accessibility findings generated earlier

            Your task:
            Return corrected SwiftUI code that fixes only the reported formal issues.

            FIX QUALITY RULES

            - Each applied fix must eliminate the reported formal rule trigger whenever possible.
            - Do not leave the same formal violation pattern in place after applying a fix.
            - Prefer replacing invalid structural patterns with valid semantic SwiftUI controls.
            - If a safe fix cannot eliminate the trigger without changing business logic, do not modify that part of the code.
            - Do not introduce new accessibility APIs unless they are directly required for the reported fix.
            - Do not make speculative or heuristic improvements.
            - Keep the result complete, formatted, and compilable.

            Return STRICT JSON:

            {
              "fixed_code": "full corrected SwiftUI component as a JSON string",
              "fixes_applied": [
                "short description of applied fix"
              ]
            }

            Original SwiftUI Component:
            \(input)

            Formal Findings:
            \(formalFindings?.toJSON() ?? "Not Available")
            """
        }
    }
    
    // MARK: - Heuristic checks
    enum HeuristicChecks {
        static let systemPrompt: String = """
        You are a senior iOS accessibility auditor specializing in SwiftUI, VoiceOver, Dynamic Type, semantic UI structure, and financial mobile applications.
        
        Your role is to perform an expert-level HEURISTIC accessibility review of a SwiftUI component.
        
        STRICT RULES:
        
        - Assume formal, deterministic code-level accessibility issues have already been addressed in the provided code.
        - Do NOT attempt to reconstruct or infer previously fixed formal issues.
        - Do NOT invent missing code.
        - Do NOT speculate about runtime behavior that cannot be reasonably inferred.
        - Clearly lower confidence when uncertainty exists.
        - Separate likely usability concerns from structural violations.
        - Focus on how the component would likely behave for assistive technology users.
        - Be concise, analytical, and evidence-based.
        - Output STRICT JSON only.
        - No explanations outside JSON.
        """
        
        static func createUserPrompt(
            input: String,
            purpose: AccessibilityAnalysisComponentPurpose?
        ) -> String {
            return """
            Perform a HEURISTIC accessibility review of the following SwiftUI component.
            
            You will receive:
            
            1. A structured Component Brief
            2. The SwiftUI source code after formal accessibility fixes
            
            Your task:
            Identify likely accessibility usability concerns that require interpretation or expert judgment.
            
            Assume that formal, deterministic accessibility issues have already been addressed in the provided code.
            
            Do NOT:
            - repeat or reconstruct previously fixed formal issues
            - restate deterministic code issues
            - speculate about runtime behavior that cannot be reasonably inferred
            - invent missing elements
            
            Focus on how the component is likely to be perceived and used by assistive technology users such as VoiceOver users.
            
            ------------------------------------------------------------
            HEURISTIC REVIEW AREAS
            ------------------------------------------------------------
            
            Consider the following dimensions:
            
            1. SEMANTIC_MATCH
               Does the accessibility representation likely match the visible intent of the component?
            
            2. LABEL_CLARITY
               Are labels likely generic, ambiguous, duplicated, or unclear when spoken aloud?
            
            3. ACTION_MEANING
               Would the primary and secondary actions be clearly understood without visual context?
            
            4. STATE_COMMUNICATION
               Is the component state likely to be clearly understood by a screen reader user?
            
            5. GROUPING_AND_FRAGMENTATION
               Is the component likely over-fragmented or under-grouped for assistive technology?
            
            6. SPOKEN_OUTPUT_VERBOSITY
               Would the likely VoiceOver output be confusing, redundant, or overly verbose?
            
            7. INTERACTION_MODEL_CONSISTENCY
               Does the interaction pattern align with user expectations for a financial application?
            
            8. FINANCIAL_CLARITY_RISK
               Could ambiguity cause misunderstanding of financial data, amounts, limits, confirmations, or status?
            
            9. COGNITIVE_LOAD
               Is there likely cognitive overload due to layout structure or interaction design?
            
            Only report concerns that are reasonably supported by code structure and the component brief.
            
            ------------------------------------------------------------
            HEURISTIC SCORE RULES
            ------------------------------------------------------------
            
            Assign a score from 1 to 10.
            
            Scoring guidance:
            - 10 = no meaningful heuristic accessibility concerns detected
            - 8-9 = minor usability concerns only
            - 6-7 = moderate clarity, grouping, or state communication concerns
            - 4-5 = multiple meaningful usability concerns or one serious concern
            - 1-3 = major accessibility usability risk for assistive technology users
            
            The score must reflect the number, severity, and confidence of heuristic findings.
            If confidence is low, avoid overly aggressive score reduction.
            Lower scores indicate higher likely usability risk.
            
            ------------------------------------------------------------
            OUTPUT FORMAT
            ------------------------------------------------------------
            
            Return STRICT JSON:
            
            {
              "score": 1,
              "heuristic_findings": [
                {
                  "id": "UPPER_SNAKE_CASE_IDENTIFIER",
                  "category": "semantic_match | label_clarity | action_meaning | state_communication | grouping | verbosity | interaction_model | financial_clarity | cognitive_load",
                  "severity": "low | medium | high",
                  "confidence": "low | medium | high",
                  "rationale": "clear reasoning based on component structure",
                  "potential_user_impact": "how this could affect assistive technology users",
                  "suggested_improvement": "clear, practical SwiftUI-level improvement"
                }
              ],
              "runtime_validation_recommended": [
                {
                  "area": "focus_order | dynamic_type | spoken_output | rotor_behavior | touch_target | contrast",
                  "reason": "why runtime validation is necessary"
                }
              ],
              "analysis_confidence": "low | medium | high"
            }
            
            If no heuristic concerns are found:
            
            {
              "score": 10,
              "heuristic_findings": [],
              "runtime_validation_recommended": [],
              "analysis_confidence": "high"
            }
            
            ------------------------------------------------------------
            
            Component Brief:
            \(purpose?.toJSON() ?? "Not Available")
            
            SwiftUI Component After Formal Fixes:
            \(input)
            """
        }
    }
}
