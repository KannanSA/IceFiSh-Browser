import SwiftUI

struct RootView: View {
    @Environment(BrowserStore.self) private var store

    var body: some View {
        @Bindable var store = store
        ZStack {
            IceBackground()

            VStack(spacing: 0) {
                if !store.selectedTab.showsHome {
                    SearchPillView(compact: true)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                }

                ZStack {
                    if store.selectedTab.showsHome {
                        HomeView()
                    } else if let webView = store.webView(for: store.selectedTabID) {
                        TabWebView(webView: webView)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FloatingDock()
        }
        .sheet(isPresented: $store.showingTabs) {
            TabSwitcherView()
                .environment(store)
                .presentationDetents([.large])
        }
        .task {
            await store.loadToday()
        }
        .tint(IcePalette.lagoon)
    }
}

#Preview {
    RootView()
        .environment(BrowserStore())
}
