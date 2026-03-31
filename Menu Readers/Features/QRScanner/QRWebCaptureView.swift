import SwiftUI
import WebKit

struct QRWebCaptureView: View {
    let urlString: String
    let onCapture: (UIImage?) -> Void

    @State private var isLoading = true
    @State private var webView: WKWebView?
    @State private var pageTitle = "Loading..."

    var body: some View {
        NavigationStack {
            ZStack {
                WebViewRepresentable(
                    urlString: urlString,
                    isLoading: $isLoading,
                    pageTitle: $pageTitle,
                    onWebViewCreated: { webView = $0 }
                )

                if isLoading {
                    ProgressView("Loading menu...")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCapture(nil)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Capture") {
                        captureWebContent()
                    }
                    .disabled(isLoading)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func captureWebContent() {
        guard let webView else { return }

        let config = WKSnapshotConfiguration()
        config.snapshotWidth = NSNumber(value: 1170)

        webView.takeSnapshot(with: config) { image, error in
            if let image {
                onCapture(image)
            } else {
                onCapture(nil)
            }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var pageTitle: String
    let onWebViewCreated: (WKWebView) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        onWebViewCreated(webView)

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable

        init(parent: WebViewRepresentable) {
            self.parent = parent
        }

        @MainActor
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        @MainActor
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.pageTitle = webView.title ?? "Menu"
        }

        @MainActor
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}
