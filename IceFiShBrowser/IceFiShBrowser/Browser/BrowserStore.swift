import Foundation
import Observation
import SwiftUI
import UIKit
import WebKit

struct BrowserTab: Identifiable, Equatable {
    let id: UUID
    var title: String
    var address: String
    var url: URL?
    var isLoading: Bool
    var progress: Double
    var canGoBack: Bool
    var showsHome: Bool

    init(
        id: UUID = UUID(),
        title: String = "New Tab",
        address: String = "",
        url: URL? = nil,
        isLoading: Bool = false,
        progress: Double = 0,
        canGoBack: Bool = false,
        showsHome: Bool = true
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.url = url
        self.isLoading = isLoading
        self.progress = progress
        self.canGoBack = canGoBack
        self.showsHome = showsHome
    }

    var shareURL: URL? { url }
}

@MainActor
@Observable
final class BrowserStore {
    var tabs: [BrowserTab]
    var selectedTabID: UUID
    var query: String = ""
    var chipPrompt: ChipPrompt = .none
    var showingTabs = false
    var articles: [TodayArticle] = TodayArticle.fallback
    let favorites = FavoriteSite.starter
    let voice = VoiceSearchController()

    @ObservationIgnored private var sessions: [UUID: TabSession] = [:]

    init() {
        let first = BrowserTab()
        tabs = [first]
        selectedTabID = first.id
    }

    var selectedTab: BrowserTab {
        tabs.first(where: { $0.id == selectedTabID }) ?? tabs[0]
    }

    var selectedIndex: Int {
        tabs.firstIndex(where: { $0.id == selectedTabID }) ?? 0
    }

    func webView(for tabID: UUID) -> WKWebView? {
        sessions[tabID]?.webView
    }

    func session(for tabID: UUID) -> TabSession {
        if let existing = sessions[tabID] { return existing }
        let session = TabSession(tabID: tabID, store: self)
        sessions[tabID] = session
        return session
    }

    func update(tabID: UUID, mutate: (inout BrowserTab) -> Void) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        mutate(&tabs[index])
    }

    func submitQuery() {
        voice.stop()
        let destination = SearchRouting.resolve(
            query,
            prompt: chipPrompt,
            currentPage: selectedTab.showsHome ? nil : selectedTab.url
        )
        open(destination)
        chipPrompt = .none
    }

    func activate(chip: QuickChip) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch chip {
        case .browseForMe:
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                chipPrompt = .browseForMe
            } else {
                chipPrompt = .browseForMe
                submitQuery()
            }
        case .wikipedia:
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                open(SearchRouting.wikipedia)
                chipPrompt = .none
            } else {
                chipPrompt = .wikipedia
                submitQuery()
            }
        case .translate:
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, selectedTab.showsHome {
                open(SearchRouting.translate)
                chipPrompt = .none
            } else {
                chipPrompt = .translate
                submitQuery()
            }
        }
    }

    func open(_ url: URL, inNewTab: Bool = false) {
        voice.stop()
        if inNewTab {
            newTab(load: url)
            return
        }
        update(tabID: selectedTabID) { tab in
            tab.showsHome = false
            tab.url = url
            tab.address = SearchRouting.displayAddress(for: url)
            tab.title = url.host ?? "Loading"
            tab.isLoading = true
            tab.canGoBack = true
        }
        query = SearchRouting.displayAddress(for: url)
        session(for: selectedTabID).load(url)
    }

    func goBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard selectedTab.canGoBack || !selectedTab.showsHome else { return }
        session(for: selectedTabID).goBack()
    }

    func returnHome(tabID: UUID) {
        update(tabID: tabID) { tab in
            tab.showsHome = true
            tab.url = nil
            tab.address = ""
            tab.title = "New Tab"
            tab.isLoading = false
            tab.progress = 0
            tab.canGoBack = false
        }
        if tabID == selectedTabID {
            query = ""
            chipPrompt = .none
        }
        session(for: tabID).webView.stopLoading()
        session(for: tabID).webView.load(URLRequest(url: URL(string: "about:blank")!))
    }

    func newTab(load url: URL? = nil) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let tab = BrowserTab()
        tabs.append(tab)
        selectedTabID = tab.id
        query = ""
        chipPrompt = .none
        showingTabs = false
        if let url {
            open(url)
        }
    }

    func closeTab(id: UUID) {
        guard tabs.count > 1, let index = tabs.firstIndex(where: { $0.id == id }) else {
            returnHome(tabID: id)
            showingTabs = false
            return
        }
        sessions[id]?.webView.stopLoading()
        sessions[id] = nil
        tabs.remove(at: index)
        if selectedTabID == id {
            let next = tabs[min(index, tabs.count - 1)]
            selectedTabID = next.id
            query = next.showsHome ? "" : next.address
        }
    }

    func selectTab(id: UUID) {
        selectedTabID = id
        let tab = selectedTab
        query = tab.showsHome ? "" : tab.address
        chipPrompt = .none
        showingTabs = false
    }

    func toggleVoice() {
        voice.toggle { [weak self] text in
            self?.query = text
        }
    }

    func reloadOrStop() {
        session(for: selectedTabID).reloadOrStop()
    }

    func loadToday() async {
        articles = await WikipediaTodayService.load()
    }
}
