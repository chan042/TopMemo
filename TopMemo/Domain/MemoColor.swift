import AppKit
import SwiftUI

enum MemoColor: String, Codable, CaseIterable, Identifiable {
    case black
    case red
    case blue
    case green
    case yellow

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .black:
            return "검정"
        case .red:
            return "빨강"
        case .blue:
            return "파랑"
        case .green:
            return "초록"
        case .yellow:
            return "노랑"
        }
    }

    var nsColor: NSColor {
        switch self {
        case .black:
            return .labelColor
        case .red:
            return .systemRed
        case .blue:
            return .systemBlue
        case .green:
            return .systemGreen
        case .yellow:
            return NSColor(srgbRed: 0.97, green: 0.82, blue: 0.18, alpha: 1.0)
        }
    }

    var color: Color {
        Color(nsColor: nsColor)
    }
}
