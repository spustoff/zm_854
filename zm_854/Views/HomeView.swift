//
//  HomeView.swift
//  FinTrendz
//
//  Created on 2026
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FinTrendz")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Financial Dashboard")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Financial Summary Cards
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            SummaryCard(
                                title: "Total Expenses",
                                value: viewModel.totalExpenses.toCurrency(),
                                icon: "💸",
                                color: .red
                            )
                            
                            SummaryCard(
                                title: "Investments",
                                value: viewModel.totalInvestments.toCurrency(),
                                icon: "📈",
                                color: .green
                            )
                        }
                        
                        HStack(spacing: 16) {
                            SummaryCard(
                                title: "Monthly Spent",
                                value: viewModel.monthlyExpenses.toCurrency(),
                                icon: "📊",
                                color: .orange
                            )
                            
                            SummaryCard(
                                title: "Profit/Loss",
                                value: viewModel.totalInvestmentProfit.toCurrency(),
                                icon: viewModel.totalInvestmentProfit >= 0 ? "📈" : "📉",
                                color: viewModel.totalInvestmentProfit >= 0 ? .green : .red
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Daily Tip
                    VStack(alignment: .leading, spacing: 12) {
                        Text("💡 Daily Financial Tip")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appYellow)
                        
                        Text(viewModel.dailyTip)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .neumorphic()
                    .padding(.horizontal)
                    
                    // Spending Insight
                    if !viewModel.dataService.expenses.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📊 Spending Insight")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appYellow)
                            
                            Text(viewModel.spendingInsight)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .neumorphic()
                        .padding(.horizontal)
                    }
                    
                    // Recent Expenses
                    if !viewModel.recentExpenses.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Expenses")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(viewModel.recentExpenses) { expense in
                                    HStack {
                                        Text(expense.category.icon)
                                            .font(.system(size: 24))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(expense.title)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text(expense.date.toString())
                                                .font(.system(size: 13))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Text(expense.amount.toCurrency())
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.appYellow)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Achievements Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🏆 Achievements")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.unlockedAchievementsCount) of \(viewModel.dataService.achievements.count) unlocked")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.7))
                        
                        ProgressView(value: Double(viewModel.unlockedAchievementsCount), total: Double(viewModel.dataService.achievements.count))
                            .tint(.appYellow)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .neumorphic()
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.system(size: 24))
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appYellow)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .neumorphic()
    }
}
