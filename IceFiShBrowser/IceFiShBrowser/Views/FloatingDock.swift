import SwiftUI
import UIKit

struct FloatingDock: View {
    @Environment(BrowserStore.self) private var store

    var body: some View {
        HStack(spacing: 0) {
            dockButton(
                "chevron.backward",
                label: "Back",
                enabled: store.selectedTab.canGoBack || !store.selectedTab.showsHome
            ) {
                store.goBack()
            }

            dockButton("square.on.square", label: "Tabs") {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                store.showingTabs = true
            }
            .overlay(alignment: .topTrailing) {
                Text("\(store.tabs.count)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(IcePalette.deep)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.white.opacity(0.92)))
                    .offset(x: 10, y: -6)
                    .accessibilityHidden(true)
            }

            dockButton("plus", label: "New tab") {
                store.newTab()
            }

            if let url = store.selectedTab.shareURL {
                ShareLink(item: url) {
                    dockGlyph("square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Share")
            } else {
                dockButton("square.and.arrow.up", label: "Share", enabled: false) {}
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .iceCapsule()
        .padding(.horizontal, 28)
        .padding(.bottom, 10)
    }

    private func dockButton(_ systemName: String, label: String, enabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            dockGlyph(systemName, enabled: enabled)
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func dockGlyph(_ systemName: String, enabled: Bool = true) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(enabled ? IcePalette.deep : IcePalette.deep.opacity(0.28))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
    }
}
