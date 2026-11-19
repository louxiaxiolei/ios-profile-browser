import SwiftUI
import WebKit

final class WebState: ObservableObject {
    @Published var urlText: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    weak var webView: WKWebView?

    func load(_ text: String) {
        guard let webView, let url = Self.normalize(text) else { return }
        webView.load(URLRequest(url: url))
    }

    static func normalize(_ text: String) -> URL? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return nil }
        if let url = URL(string: t), url.scheme != nil, url.host != nil {
            return url
        }
        if !t.contains(" "), t.contains(".") {
            return URL(string: "https://" + t)
        }
        let q = t.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? t
        return URL(string: "https://www.bing.com/search?q=" + q)
    }
}

struct WebView: UIViewRepresentable {
    let profile: BrowserProfile
    @ObservedObject var state: WebState

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // 核心隔离点：每个 profile 一个独立的持久化数据存储（cookie / localStorage / 缓存互不共享）
        config.websiteDataStore = WKWebsiteDataStore(forIdentifier: profile.id)
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let controller = WKUserContentController()
        let script = WKUserScript(source: FingerprintScript.make(for: profile),
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: false)
        controller.addUserScript(script)
        config.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = profile.userAgent
        context.coordinator.state.webView = webView

        if let home = URL(string: profile.homePage) {
            webView.load(URLRequest(url: home))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // profile 变化时父视图用 .id(profile.id) 整体重建，这里不需要原地更新
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let state: WebState

        init(state: WebState) {
            self.state = state
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            state.isLoading = true
            sync(webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            state.isLoading = false
            sync(webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            state.isLoading = false
            sync(webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            state.isLoading = false
            sync(webView)
        }

        private func sync(_ webView: WKWebView) {
            state.canGoBack = webView.canGoBack
            state.canGoForward = webView.canGoForward
            if let url = webView.url {
                state.urlText = url.absoluteString
            }
        }
    }
}
