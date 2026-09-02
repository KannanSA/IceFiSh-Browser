import SwiftUI

struct TabSwitcherView: View {
    @Environment(BrowserStore.self) private var store

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                IceBackground()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(store.tabs) { tab in
                            TabCard(tab: tab)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Tabs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { store.showingTabs = false }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.newTab()
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("New tab")
                }
            }
        }
        .tint(IcePalette.lagoon)
    }
}

private struct TabCard: View {
    @Environment(BrowserStore.self) private var store
    let tab: BrowserTab

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                store.selectTab(id: tab.id)
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [IcePalette.glacier, IcePalette.pack],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                        .overlay {
                            Image(systemName: tab.showsHome ? "snowflake" : "safari")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(IcePalette.deep.opacity(0.45))
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(tab.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(IcePalette.ink)
                            .lineLimit(1)
                        Text(tab.showsHome ? "Start Page" : tab.address)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(IcePalette.deep.opacity(0.7))
                            .lineLimit(1)
                    }
                    .padding(12)
                }
                .iceGlass(cornerRadius: 22, shadow: tab.id == store.selectedTabID)
                .overlay {
                    if tab.id == store.selectedTabID {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(IcePalette.lagoon.opacity(0.85), lineWidth: 2)
                    }
                }
            }
            .buttonStyle(.plain)

            Button {
                store.closeTab(id: tab.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(IcePalette.deep)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.92)))
            }
            .padding(8)
            .accessibilityLabel("Close tab")
        }
    }
}
