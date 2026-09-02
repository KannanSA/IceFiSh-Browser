import SwiftUI

struct HomeView: View {
    @Environment(BrowserStore.self) private var store

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                IceWordmark()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)

                SearchPillView()
                QuickChipsView()

                if let voiceError = store.voice.lastError {
                    Text(voiceError)
                        .font(.footnote)
                        .foregroundStyle(IcePalette.deep.opacity(0.8))
                        .padding(.horizontal, 4)
                }

                sectionHeader("Favorites")
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(store.favorites) { site in
                        FavoriteTile(site: site) {
                            store.open(site.url)
                        }
                    }
                }

                sectionHeader("Today")
                VStack(spacing: 14) {
                    ForEach(store.articles) { article in
                        ArticleCard(article: article) {
                            store.open(article.url)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(IcePalette.deep.opacity(0.72))
            .padding(.top, 6)
    }
}

struct FavoriteTile: View {
    let site: FavoriteSite
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(site.tint.opacity(0.16))
                    Image(systemName: site.symbol)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(site.tint)
                }
                .frame(height: 72)

                Text(site.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(IcePalette.ink)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .iceGlass(cornerRadius: 24)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(site.title)
    }
}

struct ArticleCard: View {
    let article: TodayArticle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                articleImage
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.source.uppercased())
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(IcePalette.lagoon)
                        .tracking(0.6)
                    Text(article.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(IcePalette.ink)
                        .multilineTextAlignment(.leading)
                    if !article.summary.isEmpty {
                        Text(article.summary)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(IcePalette.deep.opacity(0.8))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .iceGlass(cornerRadius: 24)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(article.title), \(article.source)")
    }

    @ViewBuilder
    private var articleImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [IcePalette.pack, IcePalette.lagoon.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            if let imageURL = article.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image(systemName: "photo")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            } else {
                Image(systemName: "snowflake")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .frame(width: 78, height: 78)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
