import Foundation

enum WikipediaTodayService {
    static func load(now: Date = .now) async -> [TodayArticle] {
        let cal = Calendar(identifier: .gregorian)
        let parts = cal.dateComponents(in: TimeZone(identifier: "UTC") ?? TimeZone(secondsFromGMT: 0)!, from: now)
        guard let year = parts.year, let month = parts.month, let day = parts.day else {
            return TodayArticle.fallback
        }

        let path = String(format: "https://en.wikipedia.org/api/rest_v1/feed/featured/%04d/%02d/%02d", year, month, day)
        guard let url = URL(string: path) else { return TodayArticle.fallback }

        var request = URLRequest(url: url)
        request.setValue(
            "IceFiShBrowser/1.0 (https://github.com/KannanSA/IceFiSh-Browser; iOS browser)",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 12

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
                return TodayArticle.fallback
            }
            let articles = try parse(data)
            return articles.isEmpty ? TodayArticle.fallback : Array(articles.prefix(6))
        } catch {
            return TodayArticle.fallback
        }
    }

    private static func parse(_ data: Data) throws -> [TodayArticle] {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        var results: [TodayArticle] = []
        var seen = Set<String>()

        func append(from dict: [String: Any]?, source: String) {
            guard let dict, let article = article(from: dict, source: source) else { return }
            guard seen.insert(article.id).inserted else { return }
            results.append(article)
        }

        append(from: json["tfa"] as? [String: Any], source: "Today's featured")

        if let news = json["news"] as? [[String: Any]] {
            for item in news.prefix(2) {
                if let links = item["links"] as? [[String: Any]], let first = links.first {
                    append(from: first, source: "In the news")
                }
            }
        }

        if let mostRead = json["mostread"] as? [String: Any],
           let list = mostRead["articles"] as? [[String: Any]] {
            for item in list.prefix(8) {
                append(from: item, source: "Most read")
            }
        }

        return results
    }

    private static func article(from dict: [String: Any], source: String) -> TodayArticle? {
        let title = (dict["titles"] as? [String: Any])?["normalized"] as? String
            ?? dict["title"] as? String
            ?? ""
        guard !title.isEmpty else { return nil }

        let summary = (dict["extract"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let page = ((dict["content_urls"] as? [String: Any])?["desktop"] as? [String: Any])?["page"] as? String
            ?? ((dict["content_urls"] as? [String: Any])?["mobile"] as? [String: Any])?["page"] as? String

        guard let page, let url = URL(string: page) else { return nil }

        let image = (dict["thumbnail"] as? [String: Any])?["source"] as? String
            ?? (dict["originalimage"] as? [String: Any])?["source"] as? String

        return TodayArticle(
            id: (dict["title"] as? String) ?? url.absoluteString,
            title: title.replacingOccurrences(of: "_", with: " "),
            summary: summary,
            url: url,
            imageURL: image.flatMap(URL.init(string:)),
            source: source
        )
    }
}
