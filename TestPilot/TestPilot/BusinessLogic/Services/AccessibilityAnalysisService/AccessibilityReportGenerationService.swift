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
    
    private var contentWidth: CGFloat { options.pageSize.width - options.margins.left - options.margins.right }
    
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
        ctx.beginPDFPage(metadata as CFDictionary)
        
        var pageNumber = 1
        var cursorY = options.pageSize.height - options.margins.top
        
        withNSGraphicsContext(ctx) {
            cursorY = drawCoverHeader(feedback: feedback, at: cursorY, pageWidth: options.pageSize.width)
            
            cursorY = consumeVerticalSpaceIfNeeded(ctx: ctx, cursorY: cursorY, needed: 180) // ensure room
            drawSectionTitle("Summary", atY: &cursorY)
            drawSummary(feedback: feedback, cursorY: &cursorY, pageWidth: options.pageSize.width)
            
            cursorY = consumeVerticalSpaceIfNeeded(ctx: ctx, cursorY: cursorY, needed: 60)
            drawSectionTitle("Issues", atY: &cursorY)
            
            if feedback.issues.isEmpty {
                drawBodyText(
                    "No issues found 🎉",
                    at: CGRect(
                        x: options.margins.left,
                        y: cursorY - 22,
                        width: contentWidth,
                        height: 22
                    )
                )
                cursorY -= 30
            } else {
                for (idx, issue) in feedback.issues.enumerated() {
                    let estimated = estimateIssueCardHeight(issue, width: contentWidth)
                    if cursorY - estimated < options.margins.bottom {
                        if options.showPageNumbers { drawFooterPageNumber(pageNumber) }
                        ctx.endPDFPage()
                        pageNumber += 1
                        ctx.beginPDFPage(metadata as CFDictionary)
                        cursorY = options.pageSize.height - options.margins.top
                        withNSGraphicsContext(ctx) {
                            drawRunningHeader(title: options.title, at: &cursorY)
                            drawSectionTitle("Issues (continued)", atY: &cursorY)
                        }
                    }
                    drawIssueCard(issue, index: idx + 1, cursorY: &cursorY, pageWidth: options.pageSize.width)
                }
            }
            
            if options.showPageNumbers { drawFooterPageNumber(pageNumber) }
        }
        
        ctx.endPDFPage()
        ctx.closePDF()
        return pdfData as Data
    }
}

// MARK: - Drawing helpers
private extension AccessibilityReportGenerationServiceImpl {
    func withNSGraphicsContext(
        _ cg: CGContext,
        _ actions: () -> Void
    ) {
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
        return color
    }
    
    @discardableResult
    func drawCoverHeader(
        feedback: AccessibilityAnalysisFeedback,
        at y: CGFloat,
        pageWidth: CGFloat)
    -> CGFloat {
        var cursorY = y
        
        let titleFont = NSFont.systemFont(ofSize: 24, weight: .bold)
        let subFont = NSFont.systemFont(ofSize: 12, weight: .regular)
        
        let title = options.title
        let titleHeight = title.boundingHeight(
            width: contentWidth,
            font: titleFont
        )
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
        formatter.dateStyle = .medium; formatter.timeStyle = .short
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
        
        let ringRect = CGRect(
            x: options.margins.left,
            y: cursorY - 120,
            width: 120,
            height: 120
        )
        drawScoreRing(
            score: feedback.score,
            in: ringRect
        )
        
        let rightX = ringRect.maxX + 16
        let rightWidth = options.pageSize.width - options.margins.right - rightX
        let scoreLabel = "Accessibility Score"
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
        
        let scoreText = "\(feedback.score)/\(options.scoreMax)"
        let scoreTextHeight = scoreText.boundingHeight(
            width: rightWidth,
            font: NSFont.systemFont(ofSize: 28, weight: .bold)
        )
        draw(
            text: scoreText,
            font: NSFont.systemFont(ofSize: 28, weight: .bold),
            color: colorForScore(feedback.score),
            in: CGRect(
                x: rightX,
                y: ringRect.maxY - 50,
                width: rightWidth,
                height: scoreTextHeight
            )
        )
        
        cursorY = ringRect.minY - 16
        drawDivider(atY: cursorY)
        cursorY -= 16
        
        return cursorY
    }
    
    func drawRunningHeader(
        title: String,
        at cursorY: inout CGFloat
    ) {
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
        let h = text.boundingHeight(
            width: contentWidth,
            font: font
        )
        draw(
            text: text,
            font: font,
            color: resolved(.labelColor),
            in: CGRect(
                x: options.margins.left,
                y: cursorY - h,
                width: contentWidth,
                height: h
            )
        )
        cursorY -= (h + 8)
    }
    
    func drawSummary(
        feedback: AccessibilityAnalysisFeedback,
        cursorY: inout CGFloat,
        pageWidth: CGFloat
    ) {
        let totals = feedback.issues.reduce(into: (low: 0, med: 0, high: 0, manual: 0)) { acc, issue in
            let key = String(describing: issue.severity).lowercased()
            if key.contains("high") { acc.high += 1 }
            else if key.contains("medium") { acc.med += 1 }
            else { acc.low += 1 }
            if issue.manualCheck { acc.manual += 1 }
        }
        let totalIssues = feedback.issues.count
        
        let columns = 4
        let gap: CGFloat = 12
        let cardWidth = (contentWidth - CGFloat(columns - 1) * gap) / CGFloat(columns)
        let cardHeight: CGFloat = 70
        let startX = options.margins.left
        let yTop = cursorY
        
        let items: [(title: String, value: String, color: NSColor)] = [
            ("Total Issues", "\(totalIssues)", resolved(.labelColor)),
            ("High", "\(totals.high)", resolved(.systemRed)),
            ("Medium", "\(totals.med)", resolved(.systemOrange)),
            ("Low", "\(totals.low)", resolved(.systemYellow))
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
        
        let manualNote = "Requires manual check: \(totals.manual)"
        let noteHeight = manualNote.boundingHeight(width: contentWidth, font: NSFont.systemFont(ofSize: 11))
        draw(text: manualNote,
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
    
    func drawIssueCard(
        _ issue: AccessibilityAnalysisFeedback.Issue,
        index: Int,
        cursorY: inout CGFloat,
        pageWidth: CGFloat
    ) {
        let cardHeight = estimateIssueCardHeight(issue, width: contentWidth)
        let cardRect = CGRect(
            x: options.margins.left,
            y: cursorY - cardHeight,
            width: contentWidth,
            height: cardHeight
        )
        
        let path = NSBezierPath(roundedRect: cardRect, xRadius: 8, yRadius: 8)
        resolved(.quaternaryLabelColor).withAlphaComponent(0.12).setFill()
        path.fill()
        
        let headerY = cardRect.maxY - 14
        let headerFont = NSFont.systemFont(ofSize: 12, weight: .semibold)
        let minorFont = NSFont.systemFont(ofSize: 11)
        
        draw(
            text: "\(index). \(issue.type)",
            font: headerFont, color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: headerY - 12,
                width: contentWidth * 0.5,
                height: 14
            )
        )
        
        let lineText = "Line \(issue.line)"
        let lineWidth = lineText.size(withAttributes: [.font: minorFont]).width
        draw(
            text: lineText,
            font: minorFont,
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: cardRect.maxX - 12 - lineWidth,
                y: headerY - 12,
                width: lineWidth,
                height: 12
            )
        )
        
        let sevText = severityDisplayName(issue.severity)
        let sevColor = colorForSeverity(issue.severity)
        let sevAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let sevSize = (sevText as NSString).size(withAttributes: sevAttrs)
        let sevRect = CGRect(
            x: cardRect.maxX - 12 - lineWidth - 8 - sevSize.width - 16,
            y: headerY - 14,
            width: sevSize.width + 16,
            height: 16
        )
        let sevPath = NSBezierPath(roundedRect: sevRect, xRadius: 8, yRadius: 8)
        sevColor.setFill(); sevPath.fill()
        (sevText as NSString).draw(
            in: CGRect(
                x: sevRect.minX + 8,
                y: sevRect.minY + 2,
                width: sevSize.width,
                height: sevSize.height),
            withAttributes: sevAttrs
        )
        
        var bodyY = sevRect.minY - 8
        let descTitle = "Description"
        draw(
            text: descTitle,
            font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: bodyY - 12,
                width: contentWidth - 24,
                height: 12
            )
        )
        bodyY -= 16
        
        let descHeight = issue.description.boundingHeight(
            width: contentWidth - 24,
            font: NSFont.systemFont(ofSize: 12)
        )
        draw(
            text: issue.description,
            font: NSFont.systemFont(ofSize: 12),
            color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: bodyY - descHeight,
                width: contentWidth - 24,
                height: descHeight
            )
        )
        bodyY -= (descHeight + 10)
        
        let sugTitle = "Suggestion"
        draw(
            text: sugTitle,
            font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: bodyY - 12,
                width: contentWidth - 24,
                height: 12
            )
        )
        bodyY -= 16
        
        let sugHeight = issue.suggestion.boundingHeight(
            width: contentWidth - 24,
            font: NSFont.systemFont(ofSize: 12)
        )
        draw(
            text: issue.suggestion,
            font: NSFont.systemFont(ofSize: 12),
            color: resolved(.labelColor),
            in: CGRect(
                x: cardRect.minX + 12,
                y: bodyY - sugHeight,
                width: contentWidth - 24,
                height: sugHeight
            )
        )
        bodyY -= (sugHeight + 6)
        
        if issue.manualCheck {
            let note = "⚠ Requires manual check"
            draw(
                text: note,
                font: NSFont.systemFont(ofSize: 11),
                color: resolved(.systemOrange),
                in: CGRect(
                    x: cardRect.minX + 12,
                    y: bodyY - 12,
                    width: contentWidth - 24,
                    height: 12
                )
            )
        }
        
        cursorY = cardRect.minY - 16
    }
    
    func estimateIssueCardHeight(
        _ issue: AccessibilityAnalysisFeedback.Issue,
        width: CGFloat
    ) -> CGFloat {
        var total: CGFloat = 16
        total += 18
        total += 16
        total += issue.description.boundingHeight(width: width - 24, font: NSFont.systemFont(ofSize: 12)) + 10
        total += 16
        total += issue.suggestion.boundingHeight(width: width - 24, font: NSFont.systemFont(ofSize: 12)) + 8
        if issue.manualCheck { total += 16 }
        total += 12
        return max(total, 90)
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
        
        // Accent bar
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
        
        let titleH = title.boundingHeight(
            width: rect.width - 16,
            font: titleFont
        )
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
        
        let valueH = value.boundingHeight(
            width: rect.width - 16,
            font: valueFont
        )
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
        let w = text.size(withAttributes: [.font: font]).width
        draw(
            text: text,
            font: font,
            color: resolved(.secondaryLabelColor),
            in: CGRect(
                x: options.pageSize.width - options.margins.right - w,
                y: options.margins.bottom - 20,
                width: w,
                height: 12
            )
        )
    }
}

// MARK: - Score Ring
private extension AccessibilityReportGenerationServiceImpl {
    func drawScoreRing(score: Int, in rect: CGRect) {
        let maxScore = max(1, options.scoreMax)
        let clamped = max(0, min(score, maxScore))
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height)/2 - 6
        
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
        (text as NSString).draw(with: rect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: attrs)
    }
    
    func drawBodyText(_ text: String, at rect: CGRect) {
        draw(text: text, font: NSFont.systemFont(ofSize: 12), color: resolved(.labelColor), in: rect)
    }
}

// MARK: - Pagination helper
private extension AccessibilityReportGenerationServiceImpl {
    func consumeVerticalSpaceIfNeeded(ctx: CGContext, cursorY: CGFloat, needed: CGFloat) -> CGFloat {
        var cursor = cursorY
        if cursor - needed < options.margins.bottom {
            ctx.endPDFPage()
            ctx.beginPDFPage([:] as CFDictionary)
            cursor = options.pageSize.height - options.margins.top
            withNSGraphicsContext(ctx) {
                drawRunningHeader(title: options.title, at: &cursor)
            }
        }
        return cursor
    }
}

// MARK: - Severity utilities
private extension AccessibilityReportGenerationServiceImpl {
    func colorForSeverity(_ severity: AccessibilityAnalysisFeedback.Severity) -> NSColor {
        let key = String(describing: severity).lowercased()
        if key.contains("high") { return resolved(.systemRed) }
        if key.contains("medium") { return resolved(.systemOrange) }
        if key.contains("low") { return resolved(.systemYellow) }
        return resolved(.systemGray)
    }

    func severityDisplayName(_ severity: AccessibilityAnalysisFeedback.Severity) -> String {
        let raw = String(describing: severity)
        switch raw.lowercased() {
        case "high": return "High"
        case "medium": return "Medium"
        case "low": return "Low"
        default: return raw.capitalized
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
            defer { if needsScopedAccess { url.stopAccessingSecurityScopedResource() } }

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
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd_HHmmss"
        let stamp = df.string(from: Date())
        let viewSlug = feedback.view
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^A-Za-z0-9_-]+", with: "_", options: .regularExpression)
            .prefix(40)
        return "AccessibilityReport_\(viewSlug)_\(stamp)"
    }
}
