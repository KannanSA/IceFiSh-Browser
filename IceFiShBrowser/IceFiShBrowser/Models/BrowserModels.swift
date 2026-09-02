import Foundation
import SwiftUI

struct FavoriteSite: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
    let symbol: String
    let tint: Color

    static let starter: [FavoriteSite] = [
        FavoriteSite(
            title: "Wikipedia",
            url: URL(string: "https://www.wikipedia.org")!,
            symbol: "book.fill",
            tint: Color(red: 0.22, green: 0.42, blue: 0.55)
        ),
        FavoriteSite(
            title: "Maps",
            url: URL(string: "https://maps.apple.com")!,
            symbol: "map.fill",
            tint: Color(red: 0.18, green: 0.58, blue: 0.48)
        ),
        FavoriteSite(
            title: "Gmail",
            url: URL(string: "https://mail.google.com")!,
            symbol: "envelope.fill",
            tint: Color(red: 0.78, green: 0.32, blue: 0.28)
        ),
        FavoriteSite(
            title: "GitHub",
            url: URL(string: "https://github.com")!,
            symbol: "chevron.left.forwardslash.chevron.right",
            tint: Color(red: 0.18, green: 0.22, blue: 0.28)
        )
    ]
}

enum QuickChip: String, CaseIterable, Identifiable {
    case browseForMe = "Browse for me"
    case wikipedia = "Wikipedia"
    case translate = "Translate"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .browseForMe: return "sparkles"
        case .wikipedia: return "book"
        case .translate: return "globe"
        }
    }
}

struct TodayArticle: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let url: URL
    let imageURL: URL?
    let source: String

    static let fallback: [TodayArticle] = [
        TodayArticle(
            id: "ice-sheet",
            title: "Ice sheet",
            summary: "A mass of glacial ice that covers surrounding terrain and is greater than 50,000 km² — the frozen heart of Greenland and Antarctica.",
            url: URL(string: "https://en.wikipedia.org/wiki/Ice_sheet")!,
            imageURL: nil,
            source: "Wikipedia"
        ),
        TodayArticle(
            id: "glacier",
            title: "Glacier",
            summary: "Persistent bodies of dense ice that move under their own weight, carving fjords, lakes, and the valleys they leave behind.",
            url: URL(string: "https://en.wikipedia.org/wiki/Glacier")!,
            imageURL: nil,
            source: "Wikipedia"
        ),
        TodayArticle(
            id: "sea-ice",
            title: "Sea ice",
            summary: "Frozen seawater that forms, grows, and melts in the ocean — a bright, shifting lid on the polar seas.",
            url: URL(string: "https://en.wikipedia.org/wiki/Sea_ice")!,
            imageURL: nil,
            source: "Wikipedia"
        )
    ]
}

enum ChipPrompt: Equatable {
    case none
    case browseForMe
    case wikipedia
    case translate

    var placeholder: String {
        switch self {
        case .none: return "Search or type a URL"
        case .browseForMe: return "What should I browse for?"
        case .wikipedia: return "Search Wikipedia"
        case .translate: return "Text or page to translate"
        }
    }
}
