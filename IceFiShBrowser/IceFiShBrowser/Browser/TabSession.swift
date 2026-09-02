import Foundation
import WebKit

@MainActor
final class TabSession: NSObject, WKNavigationDelegate, WKUIDelegate {
    let tabID: UUID
    let webView: WKWebView
    private weak var store: BrowserStore?
    private var observations: [NSKeyValueObservation] = []

    init(tabID: UUID, store: BrowserStore) {
        self.tabID = tabID
        self.store = store

        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .clear
        webView.isOpaque = false
        self.webView = webView

        super.init()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        observeWebView()
    }

    deinit {
        observations.removeAll()
    }

    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    func goBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            store?.returnHome(tabID: tabID)
        }
    }

    func reloadOrStop() {
        if webView.isLoading {
            webView.stopLoading()
        } else {
            webView.reload()
        }
    }

    private func observeWebView() {
        let tabID = self.tabID

        observations.append(webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            let progress = webView.estimatedProgress
            Task { @MainActor in
                self?.store?.update(tabID: tabID) { tab in
                    guard !tab.showsHome else { return }
                    tab.progress = progress
                }
            }
        })

        observations.append(webView.observe(\.title, options: .new) { [weak self] webView, _ in
            let title = webView.title
            Task { @MainActor in
                self?.store?.update(tabID: tabID) { tab in
                    if let title, !title.isEmpty, !tab.showsHome {
                        tab.title = title
                    }
                }
            }
        })

        observations.append(webView.observe(\.url, options: .new) { [weak self] webView, _ in
            let url = webView.url
            Task { @MainActor in
                guard let url, url.scheme != "about" else { return }
                self?.store?.update(tabID: tabID) { tab in
                    guard !tab.showsHome else { return }
                    tab.url = url
                    tab.address = SearchRouting.displayAddress(for: url)
                }
            }
        })

        observations.append(webView.observe(\.canGoBack, options: .new) { [weak self] webView, _ in
            let canGoBack = webView.canGoBack
            Task { @MainActor in
                self?.store?.update(tabID: tabID) { tab in
                    tab.canGoBack = canGoBack || (!tab.showsHome && tab.url != nil)
                }
            }
        })

        observations.append(webView.observe(\.isLoading, options: .new) { [weak self] webView, _ in
            let loading = webView.isLoading
            Task { @MainActor in
                self?.store?.update(tabID: tabID) { tab in
                    guard !tab.showsHome else { return }
                    tab.isLoading = loading
                    if !loading { tab.progress = 0 }
                }
            }
        })
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard !isBlank(webView.url) else { return }
        store?.update(tabID: tabID) { tab in
            guard !tab.showsHome else { return }
            tab.isLoading = true
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !isBlank(webView.url) else { return }
        store?.update(tabID: tabID) { tab in
            guard !tab.showsHome else { return }
            tab.isLoading = false
            tab.progress = 0
            tab.url = webView.url
            tab.title = webView.title?.isEmpty == false ? (webView.title ?? "Tab") : (webView.url?.host ?? "Tab")
            tab.address = SearchRouting.displayAddress(for: webView.url)
            tab.canGoBack = webView.canGoBack || webView.url != nil
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        store?.update(tabID: tabID) { tab in
            tab.isLoading = false
            tab.progress = 0
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        store?.update(tabID: tabID) { tab in
            tab.isLoading = false
            tab.progress = 0
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else { return .allow }
        if let scheme = url.scheme?.lowercased(), !["http", "https", "about", "blob", "data"].contains(scheme) {
            return .cancel
        }
        return .allow
    }

    private func isBlank(_ url: URL?) -> Bool {
        guard let url else { return true }
        return url.scheme == "about"
    }
}
