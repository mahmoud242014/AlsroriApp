import SwiftUI
import WebKit
import UserNotifications
import OneSignalFramework

struct ContentView: View {
    let urlString: String = "https://alsrori.com/"
    
    @State private var isLoading: Bool = true
    @State private var progress: Double = 0.15
    @State private var pulseScale: CGFloat = 0.95
    @State private var pulseOpacity: Double = 0.5
    @State private var logoOffsetY: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // Dark theme background matching alsrori.com (#0b0f19)
            // Extends seamlessly into the status bar area to provide a unified, premium native header bar
            Color(red: 11/255, green: 15/255, blue: 25/255)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            // Main Webview starting safely below the Status Bar / Dynamic Island / Notch
            // Extends seamlessly to the bottom edge for the home indicator
            WebView(url: URL(string: urlString)!, isLoading: $isLoading)
                .ignoresSafeArea(edges: .bottom)
            
            // Custom Native Splash Screen with Official Alsrori Logo
            if isLoading {
                ZStack {
                    // Dark theme background matching alsrori.com (#0b0f19)
                    Color(red: 11/255, green: 15/255, blue: 25/255)
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Brand Wrap with Animated Glow Ring & Floating Logo
                        ZStack {
                            // Radial Glow Ring
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.45),
                                            Color(red: 37/255, green: 99/255, blue: 235/255).opacity(0.15),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 75
                                    )
                                )
                                .frame(width: 140, height: 140)
                                .scaleEffect(pulseScale)
                                .opacity(pulseOpacity)
                                .blur(radius: 12)
                            
                            // Official Alsrori Logo Image
                            if let uiLogo = UIImage(named: "LaunchLogo") ?? UIImage(named: "LaunchLogo.png") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "LaunchLogo", ofType: "png") ?? "") ?? UIImage(named: "180.png") {
                                Image(uiImage: uiLogo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 96, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 10)
                                    .offset(y: logoOffsetY)
                            } else {
                                Image("LaunchLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 96, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 10)
                                    .offset(y: logoOffsetY)
                            }
                        }
                        .frame(width: 130, height: 130)
                        .padding(.bottom, 28)
                        
                        // Smooth Progress Track & Animated Glow Bar
                        ZStack(alignment: .leading) {
                            // Track
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 180, height: 4)
                            
                            // Fill
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 59/255, green: 130/255, blue: 246/255),
                                            Color(red: 96/255, green: 165/255, blue: 250/255),
                                            Color(red: 147/255, green: 197/255, blue: 253/255)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(20, 180 * progress), height: 4)
                                .shadow(color: Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.9), radius: 6, x: 0, y: 0)
                        }
                        .padding(.bottom, 18)
                        
                        // Brand Title & Animated Dots
                        HStack(spacing: 6) {
                            Text("Alsrori")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 241/255, green: 245/255, blue: 249/255))
                                .tracking(0.5)
                            
                            HStack(spacing: 4) {
                                Circle().fill(Color(red: 59/255, green: 130/255, blue: 246/255)).frame(width: 4, height: 4)
                                Circle().fill(Color(red: 59/255, green: 130/255, blue: 246/255)).frame(width: 4, height: 4)
                                Circle().fill(Color(red: 59/255, green: 130/255, blue: 246/255)).frame(width: 4, height: 4)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 1.03)).animation(.easeInOut(duration: 0.35)))
                .zIndex(10)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.18
                pulseOpacity = 0.95
            }
            withAnimation(Animation.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                logoOffsetY = -6
            }
            Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
                if progress < 0.88 {
                    progress += 0.06
                } else if !isLoading {
                    progress = 1.0
                    timer.invalidate()
                }
            }
        }
    }
}

// WKWebView True Adaptive Edge-to-Edge with Protected Top Safe Area
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        
        // Persistent Website Data Store for Cookies & Sessions
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        // Native JavaScript Bridge
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "AlsroriNotification")
        contentController.add(context.coordinator, name: "AlsroriSyncPush")
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.webView = webView
        
        // Gesture Navigation (Swipe to go back/forward)
        webView.allowsBackForwardNavigationGestures = true
        
        // Scroll view adjustment - Top is handled cleanly by SwiftUI safe area
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 11/255, green: 15/255, blue: 25/255, alpha: 1.0)
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1 AlsroriApp"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url == nil {
            var request = URLRequest(url: url)
            request.cachePolicy = .useProtocolCachePolicy
            uiView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebView
        weak var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            
            // Listen for notification deep link clicks outside the app
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNavigateToURL(_:)),
                name: NSNotification.Name("AlsroriNavigateToURL"),
                object: nil
            )
            
            // Listen for OneSignal subscription ID updates
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleOneSignalSubscribed(_:)),
                name: NSNotification.Name("AlsroriOneSignalSubscribed"),
                object: nil
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func handleNavigateToURL(_ notification: Notification) {
            guard let urlString = notification.object as? String,
                  let targetUrl = URL(string: urlString) else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let webView = self?.webView else { return }
                var request = URLRequest(url: targetUrl)
                request.cachePolicy = .reloadIgnoringLocalCacheData
                webView.load(request)
            }
        }
        
        @objc func handleOneSignalSubscribed(_ notification: Notification) {
            DispatchQueue.main.async { [weak self] in
                guard let webView = self?.webView else { return }
                self?.syncOneSignal(with: webView)
            }
        }
        
        // Sync OneSignal Device Subscription with Sngine backend
        func syncOneSignal(with webView: WKWebView) {
            let subId = OneSignal.User.pushSubscription.id ?? ""
            let syncJs = """
            (function() {
                var subId = '\(subId)';
                if (!subId) {
                    try { subId = window.localStorage.getItem('alsrori_ios_onesignal_id') || ''; } catch(e) {}
                }
                if (subId) {
                    try { window.localStorage.setItem('alsrori_ios_onesignal_id', subId); } catch(e) {}
                    if (window.$ && window.api && window.api['users/push_notifications']) {
                        $.post(api['users/push_notifications'], { handle: 'update_ios', id: subId });
                    }
                }
            })();
            """
            webView.evaluateJavaScript(syncJs, completionHandler: nil)
        }
        
        // Message handler from JavaScript bridge
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "AlsroriNotification", let body = message.body as? [String: Any] {
                let title = body["title"] as? String ?? "Alsrori"
                let msg = body["message"] as? String ?? ""
                triggerNativeNotification(title: title, body: msg)
            } else if message.name == "AlsroriSyncPush" {
                if let wv = self.webView {
                    self.syncOneSignal(with: wv)
                }
            }
        }
        
        func triggerNativeNotification(title: String, body: String) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
        
        @objc func handleRefreshControl(_ refreshControl: UIRefreshControl) {
            if let webView = refreshControl.superview?.superview as? WKWebView {
                webView.reload()
            }
            refreshControl.endRefreshing()
        }
        
        // Navigation Policy: Open external URLs (tel, mailto, whatsapp, maps) in native system apps
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let scheme = url.scheme?.lowercased() ?? ""
            if scheme == "tel" || scheme == "mailto" || scheme == "sms" || scheme == "whatsapp" || scheme == "tg" || scheme == "itms-apps" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation {
                    self.parent.isLoading = false
                }
            }
            
            // Sync OneSignal push subscription with Sngine
            self.syncOneSignal(with: webView)
            
            // JavaScript Bridge Injection for Notifications & Fullscreen Optimization
            let jsBridge = """
            (function() {
                window.AlsroriNative = {
                    notify: function(title, message) {
                        try {
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.AlsroriNotification) {
                                window.webkit.messageHandlers.AlsroriNotification.postMessage({title: title, message: message});
                            }
                        } catch(e) {}
                    },
                    syncPushToken: function() {
                        try {
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.AlsroriSyncPush) {
                                window.webkit.messageHandlers.AlsroriSyncPush.postMessage({});
                            }
                        } catch(e) {}
                    }
                };
                if (!window.Notification || window.Notification.permission !== "granted") {
                    window.Notification = function(title, options) {
                        var body = options ? (options.body || "") : "";
                        window.AlsroriNative.notify(title, body);
                    };
                    window.Notification.permission = "granted";
                    window.Notification.requestPermission = function(cb) {
                        if (cb) cb("granted");
                        return Promise.resolve("granted");
                    };
                }
                
                // Auto sync push token when user signs in or AJAX finishes
                if (window.$) {
                    $(document).ajaxComplete(function(e, xhr, settings) {
                        if (settings && settings.url && (settings.url.indexOf('signin') !== -1 || settings.url.indexOf('signup') !== -1 || settings.url.indexOf('notifications') !== -1)) {
                            setTimeout(function() {
                                if (window.AlsroriNative && window.AlsroriNative.syncPushToken) {
                                    window.AlsroriNative.syncPushToken();
                                }
                            }, 800);
                        }
                    });
                }
                
                document.documentElement.classList.add("alsrori-native-app", "alsrori-fullscreen");
                document.body.classList.add("alsrori-native-app", "alsrori-fullscreen");
            })();
            """
            webView.evaluateJavaScript(jsBridge, completionHandler: nil)
        }
        
        // JavaScript Dialogs Support (Alert / Confirm / Prompt)
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: "Alsrori", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "حسناً", style: .default, handler: { _ in completionHandler() }))
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            } else {
                completionHandler()
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: "Alsrori", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "موافق", style: .default, handler: { _ in completionHandler(true) }))
            alert.addAction(UIAlertAction(title: "إلغاء", style: .cancel, handler: { _ in completionHandler(false) }))
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            } else {
                completionHandler(false)
            }
        }
    }
}
