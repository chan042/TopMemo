import AppKit

extension StyledText {
    init(attributedString: NSAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedString.length)

        guard fullRange.length > 0 else {
            self = .empty
            return
        }

        var runs: [StyledTextRun] = []
        attributedString.enumerateAttributes(in: fullRange) { attributes, range, _ in
            let text = attributedString.attributedSubstring(from: range).string
            let color = MemoColor.from(nsColor: attributes[.foregroundColor] as? NSColor)
            runs.append(StyledTextRun(text: text, color: color))
        }

        self.init(runs: runs)
    }

    func makeAttributedString(font: NSFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()

        for run in runs {
            attributedString.append(
                NSAttributedString(
                    string: run.text,
                    attributes: [
                        .font: font,
                        .foregroundColor: run.color.nsColor
                    ]
                )
            )
        }

        return attributedString
    }
}

extension MemoColor {
    static func from(nsColor: NSColor?) -> MemoColor {
        guard let target = nsColor?.resolvedMemoColor else {
            return .black
        }

        return MemoColor.allCases.min {
            $0.nsColor.memoDistance(to: target) < $1.nsColor.memoDistance(to: target)
        } ?? .black
    }
}

private extension NSColor {
    var resolvedMemoColor: NSColor? {
        return usingColorSpace(.deviceRGB)
    }

    func memoDistance(to other: NSColor) -> CGFloat {
        guard
            let lhs = resolvedMemoColor,
            let rhs = other.resolvedMemoColor
        else {
            return .greatestFiniteMagnitude
        }

        let red = lhs.redComponent - rhs.redComponent
        let green = lhs.greenComponent - rhs.greenComponent
        let blue = lhs.blueComponent - rhs.blueComponent
        return (red * red) + (green * green) + (blue * blue)
    }
}
