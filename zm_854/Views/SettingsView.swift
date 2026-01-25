//
//  SettingsView.swift
//  FinTrendz
//
//  Created on 2026
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataService = DataService.shared
    @State private var showingDeleteConfirmation = false
    @State private var showingAchievements = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Settings")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Manage your app preferences")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Achievements Section
                        VStack(spacing: 16) {
                            Button(action: {
                                showingAchievements = true
                            }) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.appYellow)
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Achievements")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("\(dataService.achievements.filter { $0.isUnlocked }.count) of \(dataService.achievements.count) unlocked")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding()
                                .neumorphic()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Data Management Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Data Management")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                // Statistics
                                SettingsInfoRow(
                                    icon: "chart.bar.fill",
                                    title: "Total Expenses",
                                    value: "\(dataService.expenses.count)"
                                )
                                
                                SettingsInfoRow(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Total Investments",
                                    value: "\(dataService.investments.count)"
                                )
                                
                                SettingsInfoRow(
                                    icon: "target",
                                    title: "Active Budgets",
                                    value: "\(dataService.budgets.filter { $0.isActive }.count)"
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal)
                            
                            Button(action: {
                                showingAbout = true
                            }) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.appYellow)
                                        .frame(width: 40)
                                    
                                    Text("About FinTrendz")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding()
                                .neumorphic()
                            }
                            .padding(.horizontal)
                        }
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Danger Zone")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.horizontal)
                            
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.red)
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Delete All Data")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.red)
                                        
                                        Text("This action cannot be undone")
                                            .font(.system(size: 13))
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.appBackground)
                                        .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 0)
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // App Version
                        Text("FinTrendz v1.0.0")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete All Data"),
                    message: Text("Are you absolutely sure? This will permanently delete all your expenses, investments, budgets, and achievements. This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete Everything")) {
                        dataService.deleteAllData()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.appYellow)
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appYellow)
        }
        .padding()
        .neumorphic()
    }
}

struct AchievementsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(dataService.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appYellow)
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Text(achievement.icon)
                .font(.system(size: 40))
                .opacity(achievement.isUnlocked ? 1.0 : 0.3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                
                if achievement.isUnlocked {
                    Text("Unlocked: \(achievement.dateEarned.toString())")
                        .font(.system(size: 12))
                        .foregroundColor(.appYellow)
                } else {
                    Text("🔒 Locked")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            Spacer()
        }
        .padding()
        .neumorphic()
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("💰")
                            .font(.system(size: 80))
                            .padding(.top, 40)
                        
                        Text("FinTrendz")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appYellow)
                            
                            Text("FinTrendz is your ultimate finance tracking companion with gamification and insights to help you achieve your financial goals.")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                            
                            Text("Features")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appYellow)
                                .padding(.top, 8)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                FeatureRow(icon: "📊", text: "Track expenses by category")
                                FeatureRow(icon: "📈", text: "Monitor investment performance")
                                FeatureRow(icon: "🎯", text: "Set and manage budgets")
                                FeatureRow(icon: "🏆", text: "Earn achievements")
                                FeatureRow(icon: "💡", text: "Get daily financial tips")
                                FeatureRow(icon: "📱", text: "Beautiful neumorphic design")
                            }
                        }
                        .padding()
                        .neumorphic()
                        .padding(.horizontal)
                        
                        Text("Made with ❤️ for your financial success")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appYellow)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}
