import Foundation

enum SearchRouting {
    static let duckDuckGo = URL(string: "https://duckduckgo.com")!
    static let wikipedia = URL(string: "https://www.wikipedia.org")!
    static let translate = URL(string: "https://translate.google.com")!

    static func resolve(_ raw: String, prompt: ChipPrompt = .none, currentPage: URL? = nil) -> URL {
        let input = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        switch prompt {
        case .browseForMe:
            return browseForMe(input)
        case .wikipedia:
            return wikipediaURL(input)
        case .translate:
            return translateURL(input, currentPage: currentPage)
        case .none:
            break
        }

        if input.isEmpty { return duckDuckGo }
        if let url = parsedURL(input) { return url }
        return searchURL(input)
    }

    static func browseForMe(_ query: String) -> URL {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return duckDuckGo }
        return searchURL(q)
    }

    static func wikipediaURL(_ query: String) -> URL {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return wikipedia }
        var components = URLComponents(string: "https://en.wikipedia.org/w/index.php")!
        components.queryItems = [URLQueryItem(name: "search", value: q)]
        return components.url ?? wikipedia
    }

    static func translateURL(_ query: String, currentPage: URL?) -> URL {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty, let currentPage {
            var components = URLComponents(string: "https://translate.google.com/translate")!
            components.queryItems = [
                URLQueryItem(name: "sl", value: "auto"),
                URLQueryItem(name: "tl", value: "en"),
                URLQueryItem(name: "u", value: currentPage.absoluteString)
            ]
            return components.url ?? translate
        }
        if let url = parsedURL(q) {
            var components = URLComponents(string: "https://translate.google.com/translate")!
            components.queryItems = [
                URLQueryItem(name: "sl", value: "auto"),
                URLQueryItem(name: "tl", value: "en"),
                URLQueryItem(name: "u", value: url.absoluteString)
            ]
            return components.url ?? translate
        }
        if q.isEmpty { return translate }
        var components = URLComponents(string: "https://translate.google.com/")!
        components.queryItems = [
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "tl", value: "en"),
            URLQueryItem(name: "text", value: q)
        ]
        return components.url ?? translate
    }

    static func searchURL(_ query: String) -> URL {
        var components = URLComponents(string: "https://duckduckgo.com/")!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        return components.url ?? duckDuckGo
    }

    static func parsedURL(_ input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains(" ") else { return nil }

        if let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(),
           ["http", "https"].contains(scheme), url.host != nil {
            return url
        }

        if looksLikeHost(trimmed) {
            return URL(string: "https://\(trimmed)")
        }
        return nil
    }

    static func looksLikeHost(_ value: String) -> Bool {
        let host = value.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? value
        guard host.contains("."), !host.hasPrefix(".") , !host.hasSuffix(".") else { return false }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-"))
        return host.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    static func displayAddress(for url: URL?) -> String {
        guard let url else { return "" }
        if let host = url.host {
            let clean = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
            if url.path.count > 1 {
                return clean + url.path
            }
            return clean
        }
        return url.absoluteString
    }
}
