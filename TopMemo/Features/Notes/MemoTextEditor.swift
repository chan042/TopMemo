import AppKit
import SwiftUI

struct MemoTextEditor: NSViewRepresentable {
    @Binding var styledText: StyledText
    @Binding var activeColor: MemoColor
    var colorSelectionRequest: MemoColorSelectionRequest?
    var focusToken: UUID
    var onSave: () -> Void
    var onEscape: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(styledText: $styledText, activeColor: $activeColor)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        let textView = CommandTextView()
        textView.delegate = context.coordinator
        textView.font = AppTheme.editorFont
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.textContainerInset = NSSize(width: 0, height: 12)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: 0,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.onSave = onSave
        textView.onEscape = onEscape
        textView.listContinuationHandler = {
            context.coordinator.syncState(from: textView)
        }
        textView.selectionColorHandler = {
            context.coordinator.syncActiveColor(from: textView)
        }

        textView.applyDocument(styledText, activeColor: activeColor)
        context.coordinator.lastStyledText = styledText
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? CommandTextView else {
            return
        }

        if context.coordinator.lastStyledText != styledText {
            let selectedRange = textView.selectedRange()
            textView.applyDocument(styledText, activeColor: activeColor)
            textView.setSelectedRange(
                NSRange(
                    location: min(selectedRange.location, textView.string.utf16.count),
                    length: 0
                )
            )
            context.coordinator.lastStyledText = styledText
        }

        textView.onSave = onSave
        textView.onEscape = onEscape
        textView.listContinuationHandler = {
            context.coordinator.syncState(from: textView)
        }
        textView.selectionColorHandler = {
            context.coordinator.syncActiveColor(from: textView)
        }

        if context.coordinator.lastColorSelectionRequestID != colorSelectionRequest?.id,
           let colorSelectionRequest {
            context.coordinator.lastColorSelectionRequestID = colorSelectionRequest.id
            textView.applySelectedColor(colorSelectionRequest.color)
            context.coordinator.syncState(from: textView)
        }

        if context.coordinator.lastFocusToken != focusToken {
            context.coordinator.lastFocusToken = focusToken
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var styledText: Binding<StyledText>
        var activeColor: Binding<MemoColor>
        var lastFocusToken = UUID()
        var lastStyledText: StyledText = .empty
        var lastColorSelectionRequestID: UUID?

        init(styledText: Binding<StyledText>, activeColor: Binding<MemoColor>) {
            self.styledText = styledText
            self.activeColor = activeColor
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            syncState(from: textView)
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            syncActiveColor(from: textView)
        }

        func syncState(from textView: NSTextView) {
            let nextStyledText = StyledText(attributedString: textView.attributedString())
            styledText.wrappedValue = nextStyledText
            lastStyledText = nextStyledText
            syncActiveColor(from: textView)
        }

        func syncActiveColor(from textView: NSTextView) {
            let memoTextView = textView as? CommandTextView
            activeColor.wrappedValue = MemoColor.from(nsColor: memoTextView?.currentEditingColor)
        }
    }
}

final class CommandTextView: NSTextView {
    var onSave: (() -> Void)?
    var onEscape: (() -> Void)?
    var listContinuationHandler: (() -> Void)?
    var selectionColorHandler: (() -> Void)?

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if flags == .command, event.charactersIgnoringModifiers?.lowercased() == "s" {
            onSave?()
            return true
        }

        if event.keyCode == 53 {
            onEscape?()
            return true
        }

        return super.performKeyEquivalent(with: event)
    }

    override func insertNewline(_ sender: Any?) {
        if continueMarkdownListIfNeeded() {
            return
        }

        super.insertNewline(sender)
        selectionColorHandler?()
    }

    private func continueMarkdownListIfNeeded() -> Bool {
        guard selectedRange().length == 0 else {
            return false
        }

        let range = selectedRange()
        let nsString = string as NSString
        let lineRange = nsString.lineRange(for: NSRange(location: range.location, length: 0))
        let lineText = nsString.substring(with: lineRange)

        switch listContinuation(for: lineText) {
        case .none:
            return false
        case .insert(let insertion):
            insertText(insertion, replacementRange: range)
            listContinuationHandler?()
            return true
        case .removeCurrentLine(let replacement):
            replaceCurrentLine(lineRange: lineRange, with: replacement)
            listContinuationHandler?()
            return true
        }
    }

    private func listContinuation(for lineText: String) -> ListContinuation {
        let normalizedLine = lineText.hasSuffix("\n") ? String(lineText.dropLast()) : lineText
        let indent = String(normalizedLine.prefix { $0 == " " || $0 == "\t" })
        let content = String(normalizedLine.dropFirst(indent.count))
        let emptyLineReplacement = lineText.hasSuffix("\n") ? "\n\(indent)" : indent

        if let marker = content.first, ["-", "*", "+"].contains(marker), content.dropFirst().first == " " {
            let body = String(content.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            if body.isEmpty {
                return .removeCurrentLine(replacement: emptyLineReplacement)
            }

            return .insert("\n\(indent)\(marker) ")
        }

        let numberedParts = content.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        if numberedParts.count == 2,
           let number = Int(numberedParts[0]),
           numberedParts[1].first == " " {
            let body = String(numberedParts[1].dropFirst()).trimmingCharacters(in: .whitespaces)
            if body.isEmpty {
                return .removeCurrentLine(replacement: emptyLineReplacement)
            }

            return .insert("\n\(indent)\(number + 1). ")
        }

        return ListContinuation.none
    }

    private func replaceCurrentLine(lineRange: NSRange, with replacement: String) {
        guard let textStorage else {
            return
        }

        if shouldChangeText(in: lineRange, replacementString: replacement) {
            let attributedReplacement = NSAttributedString(
                string: replacement,
                attributes: typingAttributesForCurrentColor
            )
            textStorage.replaceCharacters(in: lineRange, with: attributedReplacement)
            didChangeText()
            setSelectedRange(NSRange(location: lineRange.location + replacement.utf16.count, length: 0))
            selectionColorHandler?()
        }
    }

    var currentEditingColor: NSColor {
        let range = selectedRange()

        if range.length > 0,
           let textStorage,
           let color = textStorage.attribute(.foregroundColor, at: range.location, effectiveRange: nil) as? NSColor {
            return color
        }

        if let color = typingAttributes[.foregroundColor] as? NSColor {
            return color
        }

        let lookupIndex = max(0, min(string.utf16.count - 1, range.location))
        if string.utf16.count > 0,
           let textStorage,
           let color = textStorage.attribute(.foregroundColor, at: lookupIndex, effectiveRange: nil) as? NSColor {
            return color
        }

        return MemoColor.black.nsColor
    }

    private var typingAttributesForCurrentColor: [NSAttributedString.Key: Any] {
        [
            .font: AppTheme.editorFont,
            .foregroundColor: currentEditingColor
        ]
    }

    func applyDocument(_ styledText: StyledText, activeColor: MemoColor) {
        textStorage?.setAttributedString(styledText.makeAttributedString(font: AppTheme.editorFont))
        applyTypingColor(activeColor)
    }

    func applySelectedColor(_ color: MemoColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppTheme.editorFont,
            .foregroundColor: color.nsColor
        ]

        if selectedRange().length > 0 {
            textStorage?.addAttributes(attributes, range: selectedRange())
        }

        applyTypingColor(color)
    }

    private func applyTypingColor(_ color: MemoColor) {
        typingAttributes = [
            .font: AppTheme.editorFont,
            .foregroundColor: color.nsColor
        ]
        insertionPointColor = color.nsColor
    }
}

private enum ListContinuation {
    case none
    case insert(String)
    case removeCurrentLine(replacement: String)
}
