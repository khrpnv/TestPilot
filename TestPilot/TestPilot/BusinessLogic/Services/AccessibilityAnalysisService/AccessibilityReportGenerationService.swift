//
//  AccessibilityReportGenerationService.swift
//  TestPilot
//
//  Created by Illia Khrypunov on 14.09.2025.
//

import AppKit
import Foundation
import CoreGraphics
import UniformTypeIdentifiers

protocol AccessibilityReportGenerationService {
    func export(
        feedback: AccessibilityAnalysisFeedback,
        presentingWindow: NSWindow?,
        completion: ((URL?) -> Void)?
    )
}

final class AccessibilityReportGenerationServiceImpl: AccessibilityReportGenerationService {
    // MARK: - Options
    struct Options {
        var title: String = "Accessibility Analysis Report"
        var author: String = "Accessibility Tool"
        var pageSize: CGSize = CGSize(width: 595.28, height: 841.89) // A4 @ 72dpi
        var margins: NSEdgeInsets = .init(top: 48, left: 48, bottom: 48, right: 48)
        var showPageNumbers: Bool = true
        var scoreMax: Int = 10
    }

    // MARK: - Properties
    private let options: Options
    private let pdfAppearance = NSAppearance(named: .aqua)

    private var contentWidth: CGFloat {
        options.pageSize.width - options.margins.left - options.margins.right
    }

    // MARK: - Init
    init(options: Options = Options()) {
        self.options = options
    }

    // MARK: - Generate
    func generate(feedback: AccessibilityAnalysisFeedback) -> Data {
        let pdfData = NSMutableData()

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else {
            return Data()
        }

        var mediaBox = CGRect(origin: .zero, size: options.pageSize)
        guard let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return Data()
        }

        let metadata: [CFString: Any] = [
            kCGPDFContextTitle: options.title,
            kCGPDFContextAuthor: options.author,
            kCGPDFContextCreator: "AccessibilityReportPDFGenerator"
        ]

        var pageNumber = 1
        ctx.beginPDFPage(metadata as CFDictionary)

        var cursorY = options.pageSize.height - options.margins.top

        withNSGraphicsContext(ctx) {
            cursorY = drawCoverHeader(
                feedback: feedback,
                at: cursorY,
                pageWidth: options.pageSize.width
            )

            cursorY = consumeVerticalSpaceIfNeeded(
                ctx: ctx,
                cursorY: cursorY,
                pageNumber: &pageNumber,
                needed: 180,
                pageMetadata: metadata as CFDictionary
            )

            drawSectionTitle("Summary", atY: &cursorY)
            drawSummary(feedback: feedback, cursorY: &cursorY)

            if let formal = feedback.formal {
                cursorY = beginNewPage(
                    ctx: ctx,
                    pageNumber: &pageNumber,
                    pageMetadata: metadata as CFDictionary,
                    sectionTitle: "Formal Findings"
                )

                drawAnalysisMetaRow(
                    score: formal.score,
                    confidence: formal.analysisConfidence.rawValue.capitalized,
                    findingsCount: formal.formalFindings.count,
                    cursorY: &cursorY
                )

                if formal.formalFindings.isEmpty {
                    drawBodyText(
                        "No formal findings.",
                        at: CGRect(
                            x: options.margins.left,
                            y: cursorY - 22,
                            width: contentWidth,
                            height: 22
                        )
                    )
                    cursorY -= 30
                } else {
                    for (idx, finding) in formal.formalFindings.enumerated() {
                        let estimated = estimateFormalFindingCardHeight(
                            finding,
                            width: contentWidth
                        )

                        cursorY = consumeVerticalSpaceIfNeeded(
                            ctx: ctx,
                            cursorY: cursorY,
                            pageNumber: &pageNumber,
                            needed: estimated,
                            pageMetadata: metadata as CFDictionary,
                            continuedSectionTitle: "Formal Findings (continued)"
                        )

                        drawFormalFindingCard(
                            finding,
                            index: idx + 1,
                            cursorY: &cursorY
                        )
                    }
                }
            }

            if let heuristic = feedback.heuristic {
                cursorY = beginNewPage(
                    ctx: ctx,
                    pageNumber: &pageNumber,
                    pageMetadata: metadata as CFDictionary,
                    sectionTitle: "Heuristic Findings"
                )

                drawAnalysisMetaRow(
                    score: heuristic.score,
                    confidence: heuristic.analysisConfidence.rawValue.capitalized,
                    findingsCount: heuristic.heuristicFindings.count,
                    cursorY: &cursorY
                )

                if heuristic.heuristicFindings.isEmpty {
                    drawBodyText(
                        "No heuristic findings.",
                        at: CGRect(
                            x: options.margins.left,
                            y: cursorY - 22,
                            width: contentWidth,
                            height: 22
                        )
                    )
                    cursorY -= 30
                } else {
                    for (idx, finding) in heuristic.heuristicFindings.enumerated() {
                        let estimated = estimateHeuristicFindingCardHeight(
                            finding,
                            width: contentWidth
                        )

                        cursorY = consumeVerticalSpaceIfNeeded(
                            ctx: ctx,
                            cursorY: cursorY,
                            pageNumber: &pageNumber,
                            needed: estimated,
                            pageMetadata: metadata as CFDictionary,
                            continuedSectionTitle: "Heuristic Findings (continued)"
                        )

                        drawHeuristicFindingCard(
                            finding,
                            index: idx + 1,
                            cursorY: &cursorY
                        )
                    }
                }

                if shouldStartRuntimeRecommendationsOnNewPage(
                    heuristic: heuristic,
                    cursorY: cursorY
                ) {
                    cursorY = beginNewPage(
                        ctx: ctx,
                        pageNumber: &pageNumber,
                        pageMetadata: metadata as CFDictionary,
                        sectionTitle: "Runtime Validation Recommendations"
                    )
                } else {
                    cursorY = consumeVerticalSpaceIfNeeded(
                        ctx: ctx,
                        cursorY: cursorY,
                        pageNumber: &pageNumber,
                        needed: 80,
                        pageMetadata: metadata as CFDictionary
                    )
                    drawSectionTitle("Runtime Validation Recommendations", atY: &cursorY)
                }

                if heuristic.runtimeValidationRecommended.isEmpty {
                    drawBodyText(
                        "No runtime validation recommendations.",
                        at: CGRect(
                            x: options.margins.left,
                            y: cursorY - 22,
                            width: contentWidth,
                            height: 22
                        )
                    )
                    cursorY -= 30
                } else {
                    for (idx, item) in heuristic.runtimeValidationRecommended.enumerated() {
                        let estimated = estimateRuntimeRecommendationCardHeight(
                            item,
                            width: contentWidth
                        )

                        cursorY = consumeVerticalSpaceIfNeeded(
                            ctx: ctx,
                            cursorY: cursorY,
                            pageNumber: &pageNumber,
                            needed: estimated,
                            pageMetadata: metadata as CFDictionary,
                            continuedSectionTitle: "Runtime Validation Recommendations (continued)"
                        )

                        drawRuntimeRecommendationCard(
                            item,
                            index: idx + 1,
                            cursorY: &cursorY
                        )
                    }
                }
            }

            if feedback.formal == nil && feedback.heuristic == nil {
                cursorY = consumeVerticalSpaceIfNeeded(
                    ctx: ctx,
                    cursorY: cursorY,
                    pageNumber: &pageNumber,
                    needed: 50,
                    pageMetadata: metadata as CFDictionary
                )

                drawSectionTitle("Results", atY: &cursorY)
                drawBodyText(
                    "No formal or heuristic analysis data is available.",
                    at: CGRect(
                        x: options.margins.left,
                        y: cursorY - 22,
                        width: contentWidth,
                        height: 22
                    )
                )
                cursorY -= 30
            }

            if options.showPageNumbers {
                drawFooterPageNumber(pageNumber)
            }
        }

        ctx.endPDFPage()
        ctx.closePDF()
        return pdfData as Data
    }
}

// MARK: - Drawing helpers
private extension AccessibilityReportGenerationServiceImpl {
    func withNSGraphicsContext(_ cg: CGContext, _ actions: () -> Void) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: false)

        if let appearance = pdfAppearance {
            appearance.performAsCurrentDrawingAppearance {
                actions()
            }
        } else {
            actions()
        }

        NSGraphicsContext.restoreGraphicsState()
    }

    func resolved(_ color: NSColor) -> NSColor {
        color
    }

    @discardableResult
    func drawCoverHeader(
        feedback: AccessibilityAnalysisFeedback,
        at y: CGFloat,
        pageWidth: CGFloat
    ) -> CGFloat {
        var cursorY = y

        let titleFont = NSFont.systemFont(ofSize: 24, weight: .bold)
        let subFont = NSFont.systemFont(ofSize: 12, weight: .regular)

        let title = options.title
        let titleHeight = title.boundingHeight(width: contentWidth, font: titleFont)

        draw(
            text: title,
            font: titleFont,
            color: resolved(.labelColor),
            in: CGRect(
                x: options.margins.left,
                y: cursorY - titleHeight,
                width: contentWidth,
                height: titleHeight
            )
        )
        cursorY -= (titleHeight + 8)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let meta = "View: \(feedback.view)   •   Generated: \(formatter.string(from: Date()))"
        let metaHeight = meta.boundingHeight(width: contentWidth, font: subFont)

        draw(
            text: meta,
            font: subFont,
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: options.margins.left,
                y: cursorY - metaHeight,
                width: contentWidth,
                height: metaHeight
            )
        )
        cursorY -= (metaHeight + 16)

        let overallScore = combinedScore(for: feedback)

        let ringRect = CGRect(
            x: options.margins.left,
            y: cursorY - 120,
            width: 120,
            height: 120
        )
        drawScoreRing(score: overallScore, in: ringRect)

        let rightX = ringRect.maxX + 16
        let rightWidth = options.pageSize.width - options.margins.right - rightX

        let scoreLabel = "Overall Accessibility Score"
        let scoreLabelHeight = scoreLabel.boundingHeight(
            width: rightWidth,
            font: NSFont.systemFont(ofSize: 13, weight: .semibold)
        )

        draw(
            text: scoreLabel,
            font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: rightX,
                y: ringRect.maxY - 20,
                width: rightWidth,
                height: scoreLabelHeight
            )
        )

        let scoreText = "\(overallScore)/\(options.scoreMax)"
        let scoreTextHeight = scoreText.boundingHeight(
            width: rightWidth,
            font: NSFont.systemFont(ofSize: 28, weight: .bold)
        )

        draw(
            text: scoreText,
            font: NSFont.systemFont(ofSize: 28, weight: .bold),
            color: colorForScore(overallScore),
            in: CGRect(
                x: rightX,
                y: ringRect.maxY - 50,
                width: rightWidth,
                height: scoreTextHeight
            )
        )

        let formalText = feedback.formal.map {
            "Formal: \($0.score)/\(options.scoreMax) (\($0.analysisConfidence.rawValue.capitalized))"
        } ?? "Formal: —"

        let heuristicText = feedback.heuristic.map {
            "Heuristic: \($0.score)/\(options.scoreMax) (\($0.analysisConfidence.rawValue.capitalized))"
        } ?? "Heuristic: —"

        let details = "\(formalText)\n\(heuristicText)"
        let detailsHeight = details.boundingHeight(
            width: rightWidth,
            font: NSFont.systemFont(ofSize: 12)
        )

        draw(
            text: details,
            font: NSFont.systemFont(ofSize: 12),
            color: resolved(.labelColor),
            in: CGRect(
                x: rightX,
                y: ringRect.minY + 8,
                width: rightWidth,
                height: detailsHeight
            )
        )

        cursorY = ringRect.minY - 16
        drawDivider(atY: cursorY)
        cursorY -= 16

        return cursorY
    }

    func drawRunningHeader(title: String, at cursorY: inout CGFloat) {
        let height = title.boundingHeight(
            width: contentWidth,
            font: NSFont.systemFont(ofSize: 12, weight: .medium)
        )

        draw(
            text: title,
            font: NSFont.systemFont(ofSize: 12, weight: .medium),
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: options.margins.left,
                y: cursorY - height,
                width: contentWidth,
                height: height
            )
        )

        cursorY -= (height + 12)
        drawDivider(atY: cursorY)
        cursorY -= 16
    }

    func drawSectionTitle(_ text: String, atY cursorY: inout CGFloat) {
        let font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        let height = text.boundingHeight(width: contentWidth, font: font)

        draw(
            text: text,
            font: font,
            color: resolved(.labelColor),
            in: CGRect(
                x: options.margins.left,
                y: cursorY - height,
                width: contentWidth,
                height: height
            )
        )

        cursorY -= (height + 8)
    }

    func drawSummary(
        feedback: AccessibilityAnalysisFeedback,
        cursorY: inout CGFloat
    ) {
        let formalCount = feedback.formal?.formalFindings.count ?? 0
        let heuristicCount = feedback.heuristic?.heuristicFindings.count ?? 0
        let runtimeCount = feedback.heuristic?.runtimeValidationRecommended.count ?? 0
        let totalCount = formalCount + heuristicCount

        let columns = 4
        let gap: CGFloat = 12
        let cardWidth = (contentWidth - CGFloat(columns - 1) * gap) / CGFloat(columns)
        let cardHeight: CGFloat = 70
        let startX = options.margins.left
        let yTop = cursorY

        let items: [(title: String, value: String, color: NSColor)] = [
            ("Total Findings", "\(totalCount)", resolved(.labelColor)),
            ("Formal", "\(formalCount)", resolved(.systemBlue)),
            ("Heuristic", "\(heuristicCount)", resolved(.systemPurple)),
            ("Runtime Checks", "\(runtimeCount)", resolved(.systemOrange))
        ]

        for i in 0..<columns {
            let x = startX + CGFloat(i) * (cardWidth + gap)
            drawInfoCard(
                title: items[i].title,
                value: items[i].value,
                accent: items[i].color,
                in: CGRect(
                    x: x,
                    y: yTop - cardHeight,
                    width: cardWidth,
                    height: cardHeight
                )
            )
        }

        let scoreNote = summaryScoreLine(feedback: feedback)
        let noteHeight = scoreNote.boundingHeight(
            width: contentWidth,
            font: NSFont.systemFont(ofSize: 11)
        )

        draw(
            text: scoreNote,
            font: NSFont.systemFont(ofSize: 11),
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: options.margins.left,
                y: yTop - cardHeight - 8 - noteHeight,
                width: contentWidth,
                height: noteHeight
            )
        )

        cursorY = yTop - cardHeight - 8 - noteHeight - 12
    }

    func drawAnalysisMetaRow(
        score: Int,
        confidence: String,
        findingsCount: Int,
        cursorY: inout CGFloat
    ) {
        let text = "Score: \(score)/\(options.scoreMax)   •   Confidence: \(confidence)   •   Findings: \(findingsCount)"
        let height = text.boundingHeight(width: contentWidth, font: NSFont.systemFont(ofSize: 11))

        draw(
            text: text,
            font: NSFont.systemFont(ofSize: 11),
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: options.margins.left,
                y: cursorY - height,
                width: contentWidth,
                height: height
            )
        )

        cursorY -= (height + 10)
    }
    
    func drawFormalFindingCard(
        _ finding: AccessibilityAnalysisFormalFindings.FormalFinding,
        index: Int,
        cursorY: inout CGFloat
    ) {
        let cardHeight = estimateFormalFindingCardHeight(finding, width: contentWidth)
        let cardRect = CGRect(
            x: options.margins.left,
            y: cursorY - cardHeight,
            width: contentWidth,
            height: cardHeight
        )
        
        drawCardBackground(in: cardRect)
        
        let headerFont = NSFont.systemFont(ofSize: 12, weight: .semibold)
        let chipFont = NSFont.systemFont(ofSize: 10, weight: .semibold)
        
        let title = "\(index). \(finding.category.formatted())"
        draw(
            text: title,
            font: headerFont,
            color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: cardRect.maxY - 28,
                width: cardRect.width - 24,
                height: 14
            )
        )
        
        let severityRect = drawTag(
            text: finding.severity.rawValue.capitalized,
            backgroundColor: colorForFormalSeverity(finding.severity),
            textColor: .white,
            font: chipFont,
            origin: CGPoint(x: cardRect.minX + 12, y: cardRect.maxY - 50)
        )
        
        _ = drawTag(
            text: "Confidence: \(finding.confidence.rawValue.capitalized)",
            backgroundColor: colorForConfidence(finding.confidence.rawValue),
            textColor: .white,
            font: chipFont,
            origin: CGPoint(x: severityRect.maxX + 8, y: cardRect.maxY - 50)
        )
        
        var bodyY = severityRect.minY - 10
        bodyY = drawLabeledParagraph(title: "Evidence", text: finding.evidence, x: cardRect.minX + 12, y: bodyY, width: cardRect.width - 24)
        bodyY = drawLabeledParagraph(title: "Why it matters", text: finding.whyItMatters, x: cardRect.minX + 12, y: bodyY, width: cardRect.width - 24)
        _ = drawLabeledParagraph(title: "Suggested fix", text: finding.suggestedFix, x: cardRect.minX + 12, y: bodyY, width: cardRect.width - 24)
        
        cursorY = cardRect.minY - 16
    }
    
    func drawHeuristicFindingCard(
        _ finding: AccessibilityAnalysisHeuristicFindings.HeuristicFinding,
        index: Int,
        cursorY: inout CGFloat
    ) {
        let cardHeight = estimateHeuristicFindingCardHeight(finding, width: contentWidth)
        let cardRect = CGRect(
            x: options.margins.left,
            y: cursorY - cardHeight,
            width: contentWidth,
            height: cardHeight
        )
        
        drawCardBackground(in: cardRect)
        
        let headerFont = NSFont.systemFont(ofSize: 12, weight: .semibold)
        let chipFont = NSFont.systemFont(ofSize: 10, weight: .semibold)
        
        let title = "\(index). \(finding.category.formatted())"
        draw(
            text: title,
            font: headerFont,
            color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: cardRect.maxY - 28,
                width: cardRect.width - 24,
                height: 14
            )
        )

        let severityRect = drawTag(
            text: finding.severity.rawValue.capitalized,
            backgroundColor: colorForHeuristicSeverity(finding.severity),
            textColor: .white,
            font: chipFont,
            origin: CGPoint(x: cardRect.minX + 12, y: cardRect.maxY - 50)
        )

        _ = drawTag(
            text: "Confidence: \(finding.confidence.rawValue.capitalized)",
            backgroundColor: colorForConfidence(finding.confidence.rawValue),
            textColor: .white,
            font: chipFont,
            origin: CGPoint(x: severityRect.maxX + 8, y: cardRect.maxY - 50)
        )

        var bodyY = severityRect.minY - 10
        bodyY = drawLabeledParagraph(title: "Rationale", text: finding.rationale, x: cardRect.minX + 12, y: bodyY, width: cardRect.width - 24)
        bodyY = drawLabeledParagraph(title: "Potential user impact", text: finding.potentialUserImpact, x: cardRect.minX + 12, y: bodyY, width: cardRect.width - 24)
        _ = drawLabeledParagraph(title: "Suggested improvement", text: finding.suggestedImprovement, x: cardRect.minX + 12, y: bodyY, width: cardRect.width - 24)

        cursorY = cardRect.minY - 16
    }

    func drawRuntimeRecommendationCard(
        _ recommendation: AccessibilityAnalysisHeuristicFindings.RuntimeValidationRecommendation,
        index: Int,
        cursorY: inout CGFloat
    ) {
        let cardHeight = estimateRuntimeRecommendationCardHeight(recommendation, width: contentWidth)
        let cardRect = CGRect(
            x: options.margins.left,
            y: cursorY - cardHeight,
            width: contentWidth,
            height: cardHeight
        )

        drawCardBackground(in: cardRect)

        let headerFont = NSFont.systemFont(ofSize: 12, weight: .semibold)
        let chipFont = NSFont.systemFont(ofSize: 10, weight: .semibold)

        let title = "\(index). \(recommendation.area.formatted())"
        draw(
            text: title,
            font: headerFont,
            color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: cardRect.maxY - 28,
                width: cardRect.width * 0.65,
                height: 14
            )
        )

        _ = drawTag(
            text: "Runtime validation",
            backgroundColor: resolved(.systemOrange),
            textColor: .white,
            font: chipFont,
            origin: CGPoint(x: cardRect.minX + 12, y: cardRect.maxY - 50)
        )

        _ = drawLabeledParagraph(
            title: "Reason",
            text: recommendation.reason,
            x: cardRect.minX + 12,
            y: cardRect.maxY - 60,
            width: cardRect.width - 24
        )

        cursorY = cardRect.minY - 16
    }

    @discardableResult
    func drawLabeledParagraph(
        title: String,
        text: String,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat
    ) -> CGFloat {
        var cursorY = y

        draw(
            text: title,
            font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            color: resolved(.labelColor),
            in: CGRect(
                x: x,
                y: cursorY - 12,
                width: width,
                height: 12
            )
        )
        cursorY -= 16

        let bodyFont = NSFont.systemFont(ofSize: 12)
        let bodyHeight = text.boundingHeight(width: width, font: bodyFont)

        draw(
            text: text,
            font: bodyFont,
            color: resolved(.labelColor),
            in: CGRect(
                x: x,
                y: cursorY - bodyHeight,
                width: width,
                height: bodyHeight
            )
        )
        cursorY -= (bodyHeight + 10)

        return cursorY
    }

    func estimateFormalFindingCardHeight(
        _ finding: AccessibilityAnalysisFormalFindings.FormalFinding,
        width: CGFloat
    ) -> CGFloat {
        let innerWidth = width - 24
        var total: CGFloat = 16
        total += 36
        total += 16
        total += finding.evidence.boundingHeight(width: innerWidth, font: NSFont.systemFont(ofSize: 12)) + 26
        total += finding.whyItMatters.boundingHeight(width: innerWidth, font: NSFont.systemFont(ofSize: 12)) + 26
        total += finding.suggestedFix.boundingHeight(width: innerWidth, font: NSFont.systemFont(ofSize: 12)) + 26
        total += 10
        return max(total, 140)
    }

    func estimateHeuristicFindingCardHeight(
        _ finding: AccessibilityAnalysisHeuristicFindings.HeuristicFinding,
        width: CGFloat
    ) -> CGFloat {
        let innerWidth = width - 24
        var total: CGFloat = 16
        total += 36
        total += 16
        total += finding.rationale.boundingHeight(width: innerWidth, font: NSFont.systemFont(ofSize: 12)) + 26
        total += finding.potentialUserImpact.boundingHeight(width: innerWidth, font: NSFont.systemFont(ofSize: 12)) + 26
        total += finding.suggestedImprovement.boundingHeight(width: innerWidth, font: NSFont.systemFont(ofSize: 12)) + 26
        total += 10
        return max(total, 140)
    }

    func estimateRuntimeRecommendationCardHeight(
        _ recommendation: AccessibilityAnalysisHeuristicFindings.RuntimeValidationRecommendation,
        width: CGFloat
    ) -> CGFloat {
        let innerWidth = width - 24
        var total: CGFloat = 16
        total += 36
        total += 16
        total += recommendation.reason.boundingHeight(width: innerWidth, font: NSFont.systemFont(ofSize: 12)) + 26
        total += 10
        return max(total, 90)
    }

    func drawCardBackground(in rect: CGRect) {
        let path = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
        resolved(.quaternaryLabelColor).withAlphaComponent(0.12).setFill()
        path.fill()
    }

    @discardableResult
    func drawTag(
        text: String,
        backgroundColor: NSColor,
        textColor: NSColor,
        font: NSFont,
        origin: CGPoint
    ) -> CGRect {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        let size = (text as NSString).size(withAttributes: attrs)
        let rect = CGRect(
            x: origin.x,
            y: origin.y,
            width: size.width + 16,
            height: 16
        )

        let path = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
        backgroundColor.setFill()
        path.fill()

        (text as NSString).draw(
            in: CGRect(
                x: rect.minX + 8,
                y: rect.minY + 2,
                width: size.width,
                height: size.height
            ),
            withAttributes: attrs
        )

        return rect
    }

    func drawInfoCard(
        title: String,
        value: String,
        accent: NSColor,
        in rect: CGRect
    ) {
        let bg = NSBezierPath(roundedRect: rect, xRadius: 10, yRadius: 10)
        resolved(.quaternaryLabelColor).withAlphaComponent(0.12).setFill()
        bg.fill()

        let bar = NSBezierPath(
            roundedRect: CGRect(
                x: rect.minX,
                y: rect.minY,
                width: 4,
                height: rect.height
            ),
            xRadius: 2,
            yRadius: 2
        )
        resolved(accent).setFill()
        bar.fill()

        let titleFont = NSFont.systemFont(ofSize: 11, weight: .medium)
        let valueFont = NSFont.systemFont(ofSize: 20, weight: .bold)

        let titleH = title.boundingHeight(width: rect.width - 16, font: titleFont)
        draw(
            text: title,
            font: titleFont,
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: rect.minX + 10,
                y: rect.maxY - 14,
                width: rect.width - 16,
                height: titleH
            )
        )

        let valueH = value.boundingHeight(width: rect.width - 16, font: valueFont)
        draw(
            text: value,
            font: valueFont,
            color: resolved(.labelColor),
            in: CGRect(
                x: rect.minX + 10,
                y: rect.minY + (rect.height - valueH) / 2 - 6,
                width: rect.width - 16,
                height: valueH
            )
        )
    }

    func drawDivider(atY y: CGFloat) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: options.margins.left, y: y))
        path.line(to: CGPoint(x: options.pageSize.width - options.margins.right, y: y))
        resolved(.separatorColor).setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    func drawFooterPageNumber(_ page: Int) {
        let text = "Page \(page)"
        let font = NSFont.systemFont(ofSize: 10)
        let width = text.size(withAttributes: [.font: font]).width

        draw(
            text: text,
            font: font,
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: options.pageSize.width - options.margins.right - width,
                y: options.margins.bottom - 20,
                width: width,
                height: 12
            )
        )
    }
    
    func beginNewPage(
        ctx: CGContext,
        pageNumber: inout Int,
        pageMetadata: CFDictionary,
        sectionTitle: String
    ) -> CGFloat {
        if options.showPageNumbers {
            withNSGraphicsContext(ctx) {
                drawFooterPageNumber(pageNumber)
            }
        }
        
        ctx.endPDFPage()
        pageNumber += 1
        ctx.beginPDFPage(pageMetadata)
        
        var cursorY = options.pageSize.height - options.margins.top
        withNSGraphicsContext(ctx) {
            drawRunningHeader(title: options.title, at: &cursorY)
            drawSectionTitle(sectionTitle, atY: &cursorY)
        }
        return cursorY
    }
    
    func shouldStartRuntimeRecommendationsOnNewPage(
        heuristic: AccessibilityAnalysisHeuristicFindings,
        cursorY: CGFloat
    ) -> Bool {
        guard !heuristic.runtimeValidationRecommended.isEmpty else { return false }
        
        let manyHeuristicFindings = heuristic.heuristicFindings.count >= 4
        
        let firstRecommendationHeight = heuristic.runtimeValidationRecommended.first.map {
            estimateRuntimeRecommendationCardHeight($0, width: contentWidth)
        } ?? 0
        
        let minimumNeededOnCurrentPage: CGFloat = 28 + 10 + max(60, firstRecommendationHeight)
        let notEnoughSpace = (cursorY - minimumNeededOnCurrentPage) < options.margins.bottom
        
        return manyHeuristicFindings || notEnoughSpace
    }
}

// MARK: - Score Ring
private extension AccessibilityReportGenerationServiceImpl {
    func drawScoreRing(score: Int, in rect: CGRect) {
        let maxScore = max(1, options.scoreMax)
        let clamped = max(0, min(score, maxScore))
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 6
        
        let bg = NSBezierPath()
        bg.appendArc(
            withCenter: center,
            radius: radius,
            startAngle: 90,
            endAngle: -270,
            clockwise: true
        )
        bg.lineWidth = 8
        resolved(.quaternaryLabelColor).withAlphaComponent(0.3).setStroke()
        bg.stroke()
        
        let endAngle = 90 - (360.0 * CGFloat(clamped) / CGFloat(maxScore))
        let progress = NSBezierPath()
        progress.appendArc(
            withCenter: center,
            radius: radius,
            startAngle: 90,
            endAngle: endAngle,
            clockwise: true
        )
        progress.lineCapStyle = .round
        progress.lineWidth = 8
        colorForScore(clamped).setStroke()
        progress.stroke()
    }
}

// MARK: - Text primitives
private extension AccessibilityReportGenerationServiceImpl {
    func draw(text: String, font: NSFont, color: NSColor, in rect: CGRect) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: resolved(color)
        ]
        
        (text as NSString).draw(
            with: rect,
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: attrs
        )
    }
    
    func drawBodyText(_ text: String, at rect: CGRect) {
        draw(
            text: text,
            font: NSFont.systemFont(ofSize: 12),
            color: resolved(.labelColor),
            in: rect
        )
    }
}

// MARK: - Pagination helper
private extension AccessibilityReportGenerationServiceImpl {
    func consumeVerticalSpaceIfNeeded(
        ctx: CGContext,
        cursorY: CGFloat,
        pageNumber: inout Int,
        needed: CGFloat,
        pageMetadata: CFDictionary,
        continuedSectionTitle: String? = nil
    ) -> CGFloat {
        var cursor = cursorY

        if cursor - needed < options.margins.bottom {
            if options.showPageNumbers {
                withNSGraphicsContext(ctx) {
                    drawFooterPageNumber(pageNumber)
                }
            }

            ctx.endPDFPage()
            pageNumber += 1
            ctx.beginPDFPage(pageMetadata)
            cursor = options.pageSize.height - options.margins.top

            withNSGraphicsContext(ctx) {
                drawRunningHeader(title: options.title, at: &cursor)
                if let continuedSectionTitle {
                    drawSectionTitle(continuedSectionTitle, atY: &cursor)
                }
            }
        }

        return cursor
    }
}

// MARK: - Severity / score utilities
private extension AccessibilityReportGenerationServiceImpl {
    func combinedScore(for feedback: AccessibilityAnalysisFeedback) -> Int {
        let scores = [feedback.formal?.score, feedback.heuristic?.score].compactMap { $0 }
        guard !scores.isEmpty else { return 0 }
        let avg = Double(scores.reduce(0, +)) / Double(scores.count)
        return Int(avg.rounded())
    }

    func summaryScoreLine(feedback: AccessibilityAnalysisFeedback) -> String {
        let overall = combinedScore(for: feedback)

        let formalPart = feedback.formal.map {
            "Formal \($0.score)/\(options.scoreMax)"
        } ?? "Formal —"

        let heuristicPart = feedback.heuristic.map {
            "Heuristic \($0.score)/\(options.scoreMax)"
        } ?? "Heuristic —"

        return "Overall score: \(overall)/\(options.scoreMax)   •   \(formalPart)   •   \(heuristicPart)"
    }

    func colorForFormalSeverity(_ severity: AccessibilityAnalysisFormalFindings.Severity) -> NSColor {
        switch severity {
        case .high:
            return resolved(.systemRed)
        case .medium:
            return resolved(.systemOrange)
        case .low:
            return resolved(.systemYellow)
        }
    }

    func colorForHeuristicSeverity(_ severity: AccessibilityAnalysisHeuristicFindings.Severity) -> NSColor {
        switch severity {
        case .high:
            return resolved(.systemRed)
        case .medium:
            return resolved(.systemOrange)
        case .low:
            return resolved(.systemYellow)
        }
    }

    func colorForConfidence(_ rawValue: String) -> NSColor {
        switch rawValue.lowercased() {
        case "high":
            return resolved(.systemBlue)
        case "medium":
            return resolved(.systemMint)
        case "low":
            return resolved(.systemGray)
        default:
            return resolved(.systemGray)
        }
    }

    func colorForScore(_ score: Int) -> NSColor {
        let maxScore = max(1, options.scoreMax)
        let ratio = Double(score) / Double(maxScore)

        if ratio >= 0.85 { return resolved(.systemGreen) }
        if ratio >= 0.50 { return resolved(.systemOrange) }
        return resolved(.systemRed)
    }
}

// MARK: - Small string helpers
private extension String {
    func boundingHeight(width: CGFloat, font: NSFont) -> CGFloat {
        let attr = NSAttributedString(string: self, attributes: [.font: font])
        let rect = attr.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        return ceil(rect.height)
    }
}

// MARK: - Export flow
extension AccessibilityReportGenerationServiceImpl {
    func export(
        feedback: AccessibilityAnalysisFeedback,
        presentingWindow: NSWindow? = nil,
        completion: ((URL?) -> Void)? = nil
    ) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.export(
                    feedback: feedback,
                    presentingWindow: presentingWindow,
                    completion: completion
                )
            }
            return
        }

        let suggested = defaultFileName(for: feedback) + ".pdf"

        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = suggested
        panel.title = "Export Accessibility Report"
        panel.message = "Choose where to save the PDF report."

        let finish: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let url = panel.url else {
                completion?(nil)
                return
            }

            let needsScopedAccess = url.startAccessingSecurityScopedResource()
            defer {
                if needsScopedAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = self.generate(feedback: feedback)

            do {
                try data.write(to: url, options: .atomic)
                NSWorkspace.shared.activateFileViewerSelecting([url])
                completion?(url)
            } catch {
                self.presentErrorAlert(
                    "Failed to save the report.",
                    informativeText: "\(error.localizedDescription) (domain: \((error as NSError).domain), code: \((error as NSError).code))",
                    in: presentingWindow
                )
                completion?(nil)
            }
        }

        if let window = presentingWindow {
            panel.beginSheetModal(for: window, completionHandler: finish)
        } else {
            finish(panel.runModal())
        }
    }

    private func presentErrorAlert(
        _ message: String,
        informativeText: String,
        in window: NSWindow?
    ) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.informativeText = informativeText

        if let window = window {
            alert.beginSheetModal(for: window)
        } else {
            alert.runModal()
        }
    }

    private func defaultFileName(for feedback: AccessibilityAnalysisFeedback) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd_HHmmss"

        let stamp = df.string(from: Date())
        let viewSlug = feedback.view
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^A-Za-z0-9_-]+", with: "_", options: .regularExpression)
            .prefix(40)

        return "AccessibilityReport_\(viewSlug)_\(stamp)"
    }
}
