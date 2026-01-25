//
//  OnboardingView.swift
//  FinTrendz
//
//  Created on 2026
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "💰",
                        title: "Welcome to FinTrendz",
                        description: "Your ultimate finance tracking companion with gamification and insights to help you achieve your financial goals.",
                        pageNumber: 0
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        icon: "📊",
                        title: "Track Your Expenses",
                        description: "Easily categorize and monitor your spending. See where your money goes with beautiful charts and insights.",
                        pageNumber: 1
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        icon: "📈",
                        title: "Manage Investments",
                        description: "Keep track of your investment portfolio, monitor performance, and see your wealth grow over time.",
                        pageNumber: 2
                    )
                    .tag(2)
                    
                    OnboardingPage(
                        icon: "🎯",
                        title: "Set Budgets & Goals",
                        description: "Create personalized budgets and achieve your financial goals with our interactive coaching system.",
                        pageNumber: 3
                    )
                    .tag(3)
                    
                    OnboardingPage(
                        icon: "🏆",
                        title: "Earn Achievements",
                        description: "Stay motivated by unlocking achievements as you build better financial habits and reach milestones.",
                        pageNumber: 4
                    )
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(currentPage == index ? Color.appYellow : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                if currentPage == 4 {
                    Button(action: {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let pageNumber: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(icon)
                .font(.system(size: 100))
                .padding(.bottom, 20)
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text(description)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
