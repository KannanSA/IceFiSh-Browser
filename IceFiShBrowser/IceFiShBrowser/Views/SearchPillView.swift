import SwiftUI

struct SearchPillView: View {
    @Environment(BrowserStore.self) private var store
    @FocusState private var focused: Bool
    var compact: Bool = false

    var body: some View {
        @Bindable var store = store
        HStack(spacing: 10) {
            Image(systemName: store.selectedTab.isLoading && compact ? "safari" : "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(IcePalette.lagoon)
                .symbolEffect(.pulse, isActive: store.selectedTab.isLoading)

            TextField(store.chipPrompt.placeholder, text: $store.query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.webSearch)
                .submitLabel(.go)
                .focused($focused)
                .font(.system(size: compact ? 15 : 17, weight: .medium, design: .rounded))
                .foregroundStyle(IcePalette.ink)
                .onSubmit {
                    store.submitQuery()
                    focused = false
                }

            if !store.query.isEmpty {
                Button {
                    store.query = ""
                    store.chipPrompt = .none
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(IcePalette.lagoon.opacity(0.85))
                }
                .accessibilityLabel("Clear")
            }

            if compact, !store.selectedTab.showsHome {
                Button {
                    store.reloadOrStop()
                } label: {
                    Image(systemName: store.selectedTab.isLoading ? "xmark" : "arrow.clockwise")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(IcePalette.deep)
                }
                .accessibilityLabel(store.selectedTab.isLoading ? "Stop" : "Reload")
            }

            Button {
                store.toggleVoice()
                focused = true
            } label: {
                Image(systemName: store.voice.isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(store.voice.isListening ? Color.white : IcePalette.deep)
                    .padding(8)
                    .background {
                        Circle()
                            .fill(store.voice.isListening ? IcePalette.lagoon : Color.white.opacity(0.55))
                    }
            }
            .accessibilityLabel(store.voice.isListening ? "Stop listening" : "Voice search")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, compact ? 10 : 14)
        .iceCapsule()
        .overlay(alignment: .bottom) {
            if compact, store.selectedTab.isLoading {
                ProgressView(value: min(max(store.selectedTab.progress, 0.05), 1))
                    .progressViewStyle(.linear)
                    .tint(IcePalette.lagoon)
                    .offset(y: 6)
                    .padding(.horizontal, 22)
            }
        }
        .onChange(of: store.voice.isListening) { _, listening in
            if listening { focused = true }
        }
    }
}

struct QuickChipsView: View {
    @Environment(BrowserStore.self) private var store

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(QuickChip.allCases) { chip in
                    Button {
                        store.activate(chip: chip)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: chip.symbol)
                                .font(.system(size: 13, weight: .semibold))
                            Text(chip.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(isSelected(chip) ? Color.white : IcePalette.deep)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background {
                            Capsule(style: .continuous)
                                .fill(isSelected(chip) ? IcePalette.lagoon : Color.white.opacity(0.55))
                        }
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func isSelected(_ chip: QuickChip) -> Bool {
        switch chip {
        case .browseForMe: return store.chipPrompt == .browseForMe
        case .wikipedia: return store.chipPrompt == .wikipedia
        case .translate: return store.chipPrompt == .translate
        }
    }
}
