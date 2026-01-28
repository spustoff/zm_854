//
//  Wkgd.swift
//  dafoma_57
//
//  Created by Вячеслав on 10/6/25.
//


import SwiftUI
import Combine
import WebKit

struct WebSystem: View {
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea(.all)
            
            WControllerRepresentable()
        }
    }
}

// MARK: - WebSystem с кастомным URL
struct WebSystemWithURL: View {
    let initialURL: String
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            WControllerRepresentableWithURL(initialURL: initialURL)
        }
    }
}

#Preview {
    
    WebSystem()
}

class WController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @AppStorage("first_open") var firstOpen: Bool = true
    @AppStorage("silka") var silka: String = ""
    
    @Published var url_link: URL = URL(string: "https://google.com")!
    
    var webView = WKWebView()
    var loadCheckTimer: Timer?
    var isPageLoadedSuccessfully = false
    var popupWebView: WKWebView?
    var popupVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        getRequest()
    }
    
    private func setupKeyboardObservers() {
        // Подписываемся на уведомления о клавиатуре
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Ничего не делаем - позволяем клавиатуре просто появиться поверх WebView
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // Ничего не делаем - позволяем клавиатуре просто исчезнуть
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func getRequest() {
        
//        guard let url = URL(string: DataManagers().server) else { return }
        guard let url = URL(string: "https://apptest4.click/") else { return }
        self.url_link = url
        print(self.url_link)
        self.getInfo()
    }
    
    func getInfo() {
        var request: URLRequest?
        
        if silka == "about:blank" || silka.isEmpty {
            request = URLRequest(url: self.url_link)
        } else {
            if let currentURL = URL(string: silka) {
                request = URLRequest(url: currentURL)
            }
        }
        
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        request?.allHTTPHeaderFields = headers
        
        DispatchQueue.main.async {
            self.setupWebView()
        }
    }
    
    private func setupWebView() {
        let urlString = silka.isEmpty ? url_link.absoluteString : silka
        
        // Создаем конфигурацию WebView с настройками для обхода детекции
        let config = WKWebViewConfiguration()
        
        // ===== JavaScript =====
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // ===== Мультимедиа (для слотов, видео, аудио) =====
        config.allowsInlineMediaPlayback = true // Inline воспроизведение видео
        config.mediaTypesRequiringUserActionForPlayback = [] // Autoplay без клика
        config.allowsPictureInPictureMediaPlayback = true // Picture-in-Picture для видео
        
        // ===== HTML5 Storage (localStorage, sessionStorage, IndexedDB) =====
        if #available(iOS 14.0, *) {
            config.limitsNavigationsToAppBoundDomains = false // Разрешаем навигацию везде
        }
        
        // ===== WebRTC и мультимедиа capture =====
        if #available(iOS 14.3, *) {
            // Разрешаем WebRTC (getUserMedia для камеры/микрофона)
            config.allowsInlineMediaPlayback = true
        }
        
        // ===== Веб-контент настройки =====
        config.suppressesIncrementalRendering = false
        if #available(iOS 13.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
            
            // Разрешаем все типы контента
            if #available(iOS 14.0, *) {
                config.defaultWebpagePreferences.preferredContentMode = .mobile
            }
        }
        
        // ===== WebGL, Canvas, Audio API =====
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        // ===== Для OAuth (Google, Facebook и т.д.) =====
        // Разрешаем третьи стороны cookies
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        // ===== JavaScript для маскировки WebView (обход детекции OAuth) =====
        let antiDetectionScript = """
        (function() {
            // Скрываем признаки WebView
            if (window.webkit && window.webkit.messageHandlers) {
                // Сохраняем оригинальные обработчики
                window._original_webkit = window.webkit;
            }
            
            // Переопределяем navigator для маскировки под Safari
            Object.defineProperty(navigator, 'vendor', {
                get: () => 'Apple Computer, Inc.'
            });
            
            Object.defineProperty(navigator, 'platform', {
                get: () => 'iPhone'
            });
            
            // Удаляем признаки automation
            delete navigator.__proto__.webdriver;
            Object.defineProperty(navigator, 'webdriver', {
                get: () => false
            });
            
            // Маскируем под настоящий Safari
            Object.defineProperty(navigator, 'appVersion', {
                get: () => '5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1'
            });
            
            // Добавляем chrome для совместимости с некоторыми сайтами
            if (!window.chrome) {
                window.chrome = {
                    runtime: {}
                };
            }
            
            console.log('✅ Anti-detection script loaded');
        })();
        """
        
        let userScript = WKUserScript(
            source: antiDetectionScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        config.userContentController = contentController
        
        // Создаем новый WebView с правильной конфигурацией
        webView = WKWebView(frame: .zero, configuration: config)
        
        // ===== Дополнительные настройки WebView =====
        if #available(iOS 16.4, *) {
            webView.isInspectable = true // Разрешаем Web Inspector для отладки
        }
        
        // Включаем cookies для OAuth
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            print("📝 Всего cookies: \(cookies.count)")
        }
        
        view.backgroundColor = .black
        view.addSubview(webView)
        
        // scrollview settings
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.contentInset = .zero
        webView.scrollView.scrollIndicatorInsets = .zero
        
        // Отключаем автоматическое изменение contentInset при появлении клавиатуры
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // remove space at bottom when scrolldown
        if #available(iOS 11.0, *) {
            let insets = view.safeAreaInsets
            webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -insets.bottom, right: 0)
            webView.scrollView.scrollIndicatorInsets = webView.scrollView.contentInset
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        // Настройка User-Agent как у реального iPhone Safari
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        loadCookie()
        
        // Check if the current URL matches the landing_request URL
        if urlString == url_link.absoluteString {
            
            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "GET"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            // Добавляем заголовки для обхода anti-bot защиты
            addBrowserHeaders(to: &request)

            webView.load(request)
        } else {
            print("DEFAULT TO: \(urlString)")
            // Load the web view without the POST request if the URL does not match
            if let requestURL = URL(string: urlString) {
                var request = URLRequest(url: requestURL)
                
                // Добавляем заголовки для обхода anti-bot защиты
                addBrowserHeaders(to: &request)
                
                webView.load(request)
            }
        }
    }
    
    // Функция для добавления заголовков браузера
    private func addBrowserHeaders(to request: inout URLRequest) {
        
        // Заголовки как у реального Safari на iPhone
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("1", forHTTPHeaderField: "DNT")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("?1", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("?1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        // Добавляем Referer если есть предыдущая страница
        if let currentURL = webView.url {
            request.setValue(currentURL.absoluteString, forHTTPHeaderField: "Referer")
        }
    }
    
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        completionHandler(nil)
    }
    
    // MARK: - WebRTC и Media Permissions
    
    // Обработка запросов на доступ к камере/микрофону (WebRTC)
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // Автоматически разрешаем доступ к камере/микрофону для WebRTC
        decisionHandler(.grant)
    }
    
    // Обработка Device Orientation (для слотов с анимацией)
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // Разрешаем доступ к акселерометру и гироскопу
        decisionHandler(.grant)
    }
    
    // MARK: - Мультимедиа
    
    // Создание новых окон (для popup, OAuth, казино, платежи)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Если это popup или новое окно (target="_blank", window.open())
        if let url = navigationAction.request.url {
            print("🔵 Popup/New Window запрос: \(url.absoluteString)")
            print("   windowFeatures - width: \(String(describing: windowFeatures.width)), height: \(String(describing: windowFeatures.height))")
            print("   targetFrame: \(String(describing: navigationAction.targetFrame))")
            
            // Проверяем, это реальный popup (с размерами)
            let hasSize = windowFeatures.width != nil || windowFeatures.height != nil
            
            if hasSize {
                // Это реальный popup с размерами (OAuth и т.д.)
                print("   → Создаем popup с размерами: \(windowFeatures.width ?? 0)x\(windowFeatures.height ?? 0)")
                return createChildWebView(configuration: configuration, url: url)
            } else {
                // Нет размеров - это может быть:
                // 1. iframe платежной системы
                // 2. Обычная навигация target="_blank"
                
                // Проверяем источник навигации
                let currentHost = webView.url?.host ?? ""
                let targetHost = url.host ?? ""
                let urlString = url.absoluteString
                let isFromMainFrame = navigationAction.sourceFrame.isMainFrame
                let isDifferentDomain = currentHost != targetHost && !targetHost.isEmpty
                
                print("   currentHost: \(currentHost)")
                print("   targetHost: \(targetHost)")
                print("   URL: \(urlString)")
                print("   navigationType: \(navigationAction.navigationType.rawValue)")
                print("   sourceFrame.isMainFrame: \(isFromMainFrame)")
                print("   isDifferentDomain: \(isDifferentDomain)")
                
                // Если targetHost пустой или это about:blank - это iframe, НЕ перехватываем
                if targetHost.isEmpty || urlString.hasPrefix("about:") {
                    print("   → Пустой URL или about:blank (iframe), НЕ перехватываем")
                    return nil
                }
                
                // Проверяем наличие известных платежных систем в URL
                let paymentDomains = ["stripe", "paypal", "payment", "checkout", "gateway", "pay.", "securepay", 
                                    "revolut", "visa", "mastercard", "banks", "banking", "bank", "wallet",
                                    "auth", "login", "oauth", "sso", "identity", "secure", "verify"]
                let isPaymentURL = paymentDomains.contains { targetHost.lowercased().contains($0) }
                
                if isPaymentURL {
                    // Это платежная система - СОЗДАЕМ popup для корректной работы
                    print("   → Платежная система обнаружена, создаем popup окно")
                    return createChildWebView(configuration: configuration, url: url)
                }
                
                // Если запрос исходит от основного фрейма - это обычная навигация
                // (клик по ссылке, window.open, target="_blank" и т.д.)
                if isFromMainFrame {
                    print("   → Обычная навигация (от основного фрейма), загружаем в текущем WebView")
                    webView.load(navigationAction.request)
                    return nil
                } else {
                    // Запрос от iframe - НЕ перехватываем
                    print("   → Запрос от iframe, НЕ перехватываем")
                    return nil
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Child WebView Creation
    private func createChildWebView(configuration: WKWebViewConfiguration, url: URL) -> WKWebView {
        print("   → Создаем дочернее окно для: \(url.absoluteString)")
        
        // Создаем новый WebView для дочернего окна
        let childWebView = WKWebView(frame: .zero, configuration: configuration)
        childWebView.navigationDelegate = self
        childWebView.uiDelegate = self
        
        // Применяем те же настройки что и для основного WebView
        childWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        childWebView.allowsBackForwardNavigationGestures = true
        
        // Добавляем кастомный обработчик свайпов
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        childWebView.addGestureRecognizer(swipeGestureRecognizer)
        
        // Создаем view controller для дочернего окна
        let childViewController = UIViewController()
        childViewController.view.backgroundColor = .systemBackground
        
        // Создаем нижнюю панель навигации в стиле Safari
        let bottomNavBar = createSafariStyleBottomBar(childWebView: childWebView)
        
        // Добавляем WebView на всю высоту экрана
        childViewController.view.addSubview(childWebView)
        childWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childWebView.topAnchor.constraint(equalTo: childViewController.view.safeAreaLayoutGuide.topAnchor),
            childWebView.bottomAnchor.constraint(equalTo: childViewController.view.safeAreaLayoutGuide.bottomAnchor),
            childWebView.leftAnchor.constraint(equalTo: childViewController.view.leftAnchor),
            childWebView.rightAnchor.constraint(equalTo: childViewController.view.rightAnchor)
        ])
        
        // Добавляем нижнюю панель поверх WebView (до самого низа экрана)
        childViewController.view.addSubview(bottomNavBar)
        NSLayoutConstraint.activate([
            bottomNavBar.bottomAnchor.constraint(equalTo: childViewController.view.bottomAnchor),
            bottomNavBar.leftAnchor.constraint(equalTo: childViewController.view.leftAnchor),
            bottomNavBar.rightAnchor.constraint(equalTo: childViewController.view.rightAnchor),
            bottomNavBar.heightAnchor.constraint(equalToConstant: 84) // Увеличенная высота для safe area
        ])
        
        // Сохраняем ссылки
        popupWebView = childWebView
        popupVC = childViewController
        
        // Показываем модально
        childViewController.modalPresentationStyle = .fullScreen
        present(childViewController, animated: true)
        
        return childWebView
    }
    
    // MARK: - Safari Style Bottom Bar
    private func createSafariStyleBottomBar(childWebView: WKWebView) -> UIView {
        let bottomBar = UIView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Адаптивный фон под разные темы
        bottomBar.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        bottomBar.layer.borderColor = UIColor.separator.cgColor
        bottomBar.layer.borderWidth = 0.5
        
        // Размытый фон эффект
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            blurView.leftAnchor.constraint(equalTo: bottomBar.leftAnchor),
            blurView.rightAnchor.constraint(equalTo: bottomBar.rightAnchor)
        ])
        
        // Создаем кнопки навигации (только стрелочки)
        let backButton = createNavButton(systemName: "chevron.left", action: #selector(handleChildWebViewBack))
        let forwardButton = createNavButton(systemName: "chevron.right", action: #selector(handleChildWebViewForward))
        
        // Контейнер для кнопок (только стрелочки по бокам)
        let buttonContainer = UIStackView(arrangedSubviews: [backButton, UIView(), forwardButton])
        buttonContainer.axis = .horizontal
        buttonContainer.distribution = .equalSpacing
        buttonContainer.alignment = .center
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.addSubview(buttonContainer)
        NSLayoutConstraint.activate([
            buttonContainer.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 8),
            buttonContainer.leftAnchor.constraint(equalTo: bottomBar.leftAnchor, constant: 20),
            buttonContainer.rightAnchor.constraint(equalTo: bottomBar.rightAnchor, constant: -20),
            buttonContainer.heightAnchor.constraint(equalToConstant: 40) // Фиксированная высота для кнопок
        ])
        
        return bottomBar
    }
    
    private func createNavButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .label // Адаптивный цвет под тему
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Стилизация кнопки
        button.backgroundColor = UIColor.secondarySystemBackground
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        // Размер кнопки
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return button
    }
    
    // MARK: - Swipe Gesture Handler
    @objc private func handleSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        let velocity = gesture.velocity(in: gesture.view)
        let translation = gesture.translation(in: gesture.view)
        
        // Проверяем горизонтальный свайп
        if abs(velocity.x) > abs(velocity.y) && abs(translation.x) > 50 {
            if velocity.x > 0 { // Свайп вправо (назад)
                handleChildWebViewBack()
            }
            // Свайп влево можно добавить для "вперед" если нужно
        }
    }
    
    // MARK: - Navigation Handling
    @objc private func handleChildWebViewBack() {
        print("🔙 Back button/swipe pressed")
        guard let childWebView = popupWebView else { 
            print("❌ popupWebView is nil")
            return 
        }
        
        if childWebView.canGoBack {
            print("🔙 Child window: going back in history")
            childWebView.goBack()
        } else {
            print("🔙 Child window: history is empty, closing window")
            closePopup()
        }
    }
    
    @objc private func handleChildWebViewForward() {
        print("🔜 Forward button pressed")
        guard let childWebView = popupWebView else { 
            print("❌ popupWebView is nil")
            return 
        }
        
        if childWebView.canGoForward {
            print("🔜 Child window: going forward in history")
            childWebView.goForward()
        } else {
            print("⚠️ Child window: no forward history available")
        }
    }
    
    @objc private func closePopup() {
        print("🔴 Close button pressed - dismissing child window")
        
        guard let popupVC = popupVC else {
            print("❌ popupVC is nil")
            return
        }
        
        popupVC.dismiss(animated: true) {
            print("✅ Child window dismissed successfully")
            self.popupWebView = nil
            self.popupVC = nil
        }
    }
    
    // JavaScript Alert/Confirm/Prompt поддержка
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        present(alert, animated: true)
    }
    
    // MARK: - DecidePolicy
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let scheme = (url.scheme ?? "").lowercased()
            let internalSchemes: Set<String> = ["http", "https", "about", "srcdoc", "blob", "data", "javascript", "file"]
            
            if internalSchemes.contains(scheme) {
                decisionHandler(.allow)
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    // Обработка ответов сервера (для OAuth redirects)
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("📥 Response от: \(navigationResponse.response.url?.absoluteString ?? "unknown")")
        // Разрешаем все ответы
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        loadCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            if let strongSelf = self, !strongSelf.isPageLoadedSuccessfully {
                print("Страница не загрузилась в течение 5 секунд.")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isPageLoadedSuccessfully = true
        loadCheckTimer?.invalidate()
        
        // НЕ сохраняем текущий URL - всегда открываем стартовый URL из клоаки
        // Удалена строка: silka = currentURL
        
        print("✅ Страница загружена: \(webView.url?.absoluteString ?? "unknown")")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            print("❌ Ошибка навигации: \(error.localizedDescription)")
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            print("❌ Ошибка загрузки: \(error.localizedDescription)")
            
            // Если это не отмена пользователем - возвращаемся на предыдущую страницу
            if webView.canGoBack {
                print("⬅️ Возвращаемся на предыдущую страницу")
                webView.goBack()
            }
        }
    }
    
    func saveCookie() {
        let cookieJar = HTTPCookieStorage.shared
        
        if let cookies = cookieJar.cookies {
            let data = NSKeyedArchiver.archivedData(withRootObject: cookies)
            UserDefaults.standard.set(data, forKey: "cookie")
        }
    }
    
    func loadCookie() {
        let ud = UserDefaults.standard
        
        if let data = ud.object(forKey: "cookie") as? Data, let cookies = NSKeyedUnarchiver.unarchiveObject(with: data) as? [HTTPCookie] {
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

struct WControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = WController
    
    func makeUIViewController(context: Context) -> WController {
        return WController()
    }
    
    func updateUIViewController(_ uiViewController: WController, context: Context) {}
}

// MARK: - WController Representable с кастомным URL
struct WControllerRepresentableWithURL: UIViewControllerRepresentable {
    
    let initialURL: String
    
    typealias UIViewControllerType = WControllerWithURL
    
    func makeUIViewController(context: Context) -> WControllerWithURL {
        return WControllerWithURL(customURL: initialURL)
    }
    
    func updateUIViewController(_ uiViewController: WControllerWithURL, context: Context) {}
}

// MARK: - WController с кастомным URL
class WControllerWithURL: WController {
    
    private let customURL: String
    
    init(customURL: String) {
        self.customURL = customURL
        super.init(nibName: nil, bundle: nil)
        
        // Очищаем сохраненный silka чтобы всегда использовать URL из клоаки
        self.silka = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Переопределяем метод getRequest чтобы использовать кастомный URL
    override func getRequest() {
        guard let url = URL(string: customURL) else { return }
        self.url_link = url
        print("🔗 Using custom URL from cloak: \(self.url_link)")
        print("🔄 Always loading start URL, ignoring navigation history")
        self.getInfo()
    }
}

// SSL Delegate для обработки сертификатов
class SSLDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Принимаем любые сертификаты (только для разработки!)
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

// Класс для отключения автоматических редиректов
class RedirectHandler: NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        print("🔄 Redirect blocked: \(response.statusCode) -> \(request.url?.absoluteString ?? "unknown")")
        
        // Возвращаем nil, чтобы НЕ следовать редиректу
        completionHandler(nil)
    }
}

// MARK: - WebSystem Wrapper
struct WebSystemWrapper: View {
    let url: String
    
    var body: some View {
        WebSystemWithURL(initialURL: url)
    }
}
