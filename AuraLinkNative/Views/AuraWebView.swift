import SwiftUI
import WebKit
import Observation
import UIKit

@Observable
@MainActor
final class AuraWebState {
    var hasRenderedContent = false
    var isLoading = true
    var errorMessage: String?

    fileprivate weak var webView: WKWebView?

    func retry() {
        errorMessage = nil
        isLoading = true
        hasRenderedContent = false

        guard let webView else { return }
        if webView.url == nil {
            webView.load(URLRequest(url: AppEnvironment.productionURL))
        } else {
            webView.reload()
        }
    }
}

struct AuraWebView: UIViewRepresentable {
    let state: AuraWebState

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.applicationNameForUserAgent = AppEnvironment.nativeUserAgentSuffix

        let bridge = WKUserContentController()
        bridge.add(context.coordinator, name: "auraNative")
        bridge.addUserScript(WKUserScript(
            source: Self.nativeBridgeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        ))
        configuration.userContentController = bridge

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(AuraTheme.electricBlue)
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.refresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        state.webView = webView
        context.coordinator.webView = webView

        var request = URLRequest(url: AppEnvironment.productionURL)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 45
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "auraNative")
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }

    private static let nativeBridgeScript = #"""
    (() => {
      document.documentElement.classList.add('aura-native-ios');

      let viewport = document.querySelector('meta[name="viewport"]');
      if (!viewport) {
        viewport = document.createElement('meta');
        viewport.name = 'viewport';
        document.head.appendChild(viewport);
      }
      viewport.content = 'width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover';

      const notify = (type, payload = {}) => {
        try { window.webkit.messageHandlers.auraNative.postMessage({ type, ...payload }); } catch (_) {}
      };

      document.addEventListener('click', (event) => {
        const target = event.target && event.target.closest
          ? event.target.closest('button, a, [role="button"], input[type="submit"]')
          : null;
        if (target && !target.disabled) notify('haptic', { style: 'light' });
      }, true);

      window.addEventListener('offline', () => notify('network', { online: false }));
      window.addEventListener('online', () => notify('network', { online: true }));
      window.__AURA_NATIVE_IOS__ = true;
    })();
    """#

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let state: AuraWebState
        weak var webView: WKWebView?

        init(state: AuraWebState) {
            self.state = state
        }

        @objc func refresh() {
            webView?.reload()
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            state.isLoading = true
            state.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            state.isLoading = false
            state.hasRenderedContent = true
            state.errorMessage = nil
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handle(error, in: webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handle(error, in: webView)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }

        private func handle(_ error: Error, in webView: WKWebView) {
            webView.scrollView.refreshControl?.endRefreshing()
            let code = (error as NSError).code
            guard code != NSURLErrorCancelled else { return }

            state.isLoading = false
            if !state.hasRenderedContent {
                state.errorMessage = "Verifique sua internet e tente abrir novamente."
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            let scheme = url.scheme?.lowercased()
            if scheme != "http" && scheme != "https" && scheme != "about" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }

        @available(iOS 15.0, *)
        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            let trustedHosts = ["auralinkai.com.br", "www.auralinkai.com.br"]
            decisionHandler(trustedHosts.contains(origin.host) ? .grant : .prompt)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let payload = message.body as? [String: Any],
                  let type = payload["type"] as? String else { return }

            switch type {
            case "haptic":
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.72)
            case "network":
                if let online = payload["online"] as? Bool, online {
                    state.errorMessage = nil
                }
            default:
                break
            }
        }
    }
}
