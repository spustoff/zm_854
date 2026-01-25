//
//  zm_854App.swift
//  FinTrendz
//
//  Created by Вячеслав on 1/25/26.
//

import SwiftUI

@main
struct zm_854App: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
