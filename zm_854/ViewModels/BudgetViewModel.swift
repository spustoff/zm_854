//
//  BudgetViewModel.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine

class BudgetViewModel: ObservableObject {
    @Published var dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    
    @Published var showingAddBudget = false
    
    var activeBudgets: [Budget] {
        dataService.budgets.filter { $0.isActive }
    }
    
    func getBudgetProgress(_ budget: Budget) -> Double {
        analyticsService.getBudgetProgress(budget: budget, expenses: dataService.expenses)
    }
    
    func getRemainingAmount(_ budget: Budget) -> Double {
        analyticsService.getRemainingBudget(budget: budget, expenses: dataService.expenses)
    }
    
    func getSpentAmount(_ budget: Budget) -> Double {
        let remaining = getRemainingAmount(budget)
        return budget.limit - remaining
    }
    
    func isOverBudget(_ budget: Budget) -> Bool {
        analyticsService.isOverBudget(budget: budget, expenses: dataService.expenses)
    }
    
    func addBudget(category: ExpenseCategory, limit: Double, period: BudgetPeriod) {
        let budget = Budget(category: category, limit: limit, period: period, startDate: Date(), isActive: true)
        dataService.addBudget(budget)
    }
    
    func deleteBudget(_ budget: Budget) {
        dataService.deleteBudget(budget)
    }
    
    func toggleBudgetActive(_ budget: Budget) {
        var updatedBudget = budget
        updatedBudget.isActive.toggle()
        dataService.updateBudget(updatedBudget)
    }
    
    var totalBudgetLimit: Double {
        activeBudgets.reduce(0) { $0 + $1.limit }
    }
    
    var totalSpent: Double {
        activeBudgets.reduce(0) { total, budget in
            total + getSpentAmount(budget)
        }
    }
    
    var overBudgetCount: Int {
        activeBudgets.filter { isOverBudget($0) }.count
    }
}
