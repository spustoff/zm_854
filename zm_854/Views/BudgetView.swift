//
//  BudgetView.swift
//  FinTrendz
//
//  Created on 2026
//

import SwiftUI

struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budgets")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Manage your spending limits")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Budget Summary
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    BudgetSummaryCard(
                                        title: "Total Limit",
                                        value: viewModel.totalBudgetLimit.toCurrency(),
                                        color: .appYellow
                                    )
                                    
                                    BudgetSummaryCard(
                                        title: "Total Spent",
                                        value: viewModel.totalSpent.toCurrency(),
                                        color: .orange
                                    )
                                }
                                
                                HStack(spacing: 16) {
                                    BudgetSummaryCard(
                                        title: "Remaining",
                                        value: (viewModel.totalBudgetLimit - viewModel.totalSpent).toCurrency(),
                                        color: .green
                                    )
                                    
                                    BudgetSummaryCard(
                                        title: "Over Budget",
                                        value: "\(viewModel.overBudgetCount)",
                                        color: .red
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            // Interactive Budget Coaching
                            if !viewModel.activeBudgets.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("🎯 Budget Coach")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.appYellow)
                                    
                                    Text(getBudgetCoachingMessage())
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineSpacing(4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .neumorphic()
                                .padding(.horizontal)
                            }
                            
                            // Budget List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Budgets")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                if viewModel.activeBudgets.isEmpty {
                                    VStack(spacing: 16) {
                                        Text("🎯")
                                            .font(.system(size: 60))
                                        Text("No budgets yet")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("Tap + to create your first budget")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                } else {
                                    ForEach(viewModel.activeBudgets) { budget in
                                        BudgetCard(
                                            budget: budget,
                                            progress: viewModel.getBudgetProgress(budget),
                                            spent: viewModel.getSpentAmount(budget),
                                            remaining: viewModel.getRemainingAmount(budget),
                                            isOver: viewModel.isOverBudget(budget),
                                            onDelete: {
                                                viewModel.deleteBudget(budget)
                                            }
                                        )
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.top, 8)
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showingAddBudget = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.appBackground)
                                .frame(width: 60, height: 60)
                                .background(Color.appYellow)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingAddBudget) {
                AddBudgetView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func getBudgetCoachingMessage() -> String {
        let overBudget = viewModel.overBudgetCount
        
        if overBudget > 0 {
            return "⚠️ You're over budget in \(overBudget) categor\(overBudget == 1 ? "y" : "ies")! Time to review your spending. Small changes can make a big difference. Consider cutting back on non-essential expenses this period."
        } else if viewModel.totalSpent >= viewModel.totalBudgetLimit * 0.8 {
            return "⚡ You've used 80% of your budget! You're doing well, but be mindful of your remaining spending to finish strong this period."
        } else if viewModel.totalSpent >= viewModel.totalBudgetLimit * 0.5 {
            return "🎉 Great job! You're halfway through your budget. Keep tracking your expenses and you'll meet your goals!"
        } else {
            return "💪 Excellent start! You're well within your budget limits. Keep up the good work and maintain this discipline!"
        }
    }
}

struct BudgetSummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .neumorphic()
    }
}

struct BudgetCard: View {
    let budget: Budget
    let progress: Double
    let spent: Double
    let remaining: Double
    let isOver: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(budget.category.icon)
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(budget.period.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(spent.toCurrency())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isOver ? .red : .appYellow)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Limit")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(budget.limit.toCurrency())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(remaining.toCurrency())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isOver ? .red : .green)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(Int(min(progress, 100)))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isOver ? .red : .appYellow)
                    
                    Spacer()
                    
                    if isOver {
                        Text("Over Budget!")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                
                ProgressView(value: min(progress, 100), total: 100)
                    .tint(isOver ? .red : .appYellow)
            }
        }
        .padding()
        .neumorphic()
    }
}

struct AddBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    
    @State private var selectedCategory = ExpenseCategory.food
    @State private var limit = ""
    @State private var selectedPeriod = BudgetPeriod.monthly
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                    Text("\(category.icon) \(category.rawValue)").tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Budget Limit")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $limit)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Period")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("Period", selection: $selectedPeriod) {
                                ForEach(BudgetPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if let limitValue = Double(limit) {
                                viewModel.addBudget(
                                    category: selectedCategory,
                                    limit: limitValue,
                                    period: selectedPeriod
                                )
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Create Budget")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appBackground)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.appYellow)
                                .cornerRadius(16)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appYellow)
                }
            }
        }
    }
}
