//
//  HomeViewModel.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    
    var totalExpenses: Double {
        analyticsService.getTotalExpenses(for: dataService.expenses)
    }
    
    var totalInvestments: Double {
        analyticsService.getTotalInvestmentValue(for: dataService.investments)
    }
    
    var totalInvestmentProfit: Double {
        analyticsService.getTotalProfitLoss(for: dataService.investments)
    }
    
    var monthlyExpenses: Double {
        let monthlyExpensesList = analyticsService.getExpensesForPeriod(.monthly, expenses: dataService.expenses)
        return analyticsService.getTotalExpenses(for: monthlyExpensesList)
    }
    
    var dailyTip: String {
        analyticsService.getDailyFinancialTip()
    }
    
    var spendingInsight: String {
        analyticsService.getSpendingInsight(for: dataService.expenses)
    }
    
    var recentExpenses: [Expense] {
        Array(dataService.expenses.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    var topPerformingInvestment: Investment? {
        dataService.investments.max(by: { $0.profitLossPercentage < $1.profitLossPercentage })
    }
    
    var activeBudgetsCount: Int {
        dataService.budgets.filter { $0.isActive }.count
    }
    
    var overBudgetCount: Int {
        dataService.budgets.filter { budget in
            analyticsService.isOverBudget(budget: budget, expenses: dataService.expenses)
        }.count
    }
    
    var unlockedAchievementsCount: Int {
        dataService.achievements.filter { $0.isUnlocked }.count
    }
}
