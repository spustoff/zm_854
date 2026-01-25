//
//  ExpensesViewModel.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine

class ExpensesViewModel: ObservableObject {
    @Published var dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    
    @Published var showingAddExpense = false
    @Published var selectedCategory: ExpenseCategory?
    @Published var searchText = ""
    
    var filteredExpenses: [Expense] {
        var filtered = dataService.expenses
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted(by: { $0.date > $1.date })
    }
    
    var totalExpenses: Double {
        analyticsService.getTotalExpenses(for: filteredExpenses)
    }
    
    var expensesByCategory: [ExpenseCategory: Double] {
        analyticsService.getExpensesByCategory(for: filteredExpenses)
    }
    
    var monthlyExpenses: Double {
        let monthly = analyticsService.getExpensesForPeriod(.monthly, expenses: dataService.expenses)
        return analyticsService.getTotalExpenses(for: monthly)
    }
    
    var weeklyExpenses: Double {
        let weekly = analyticsService.getExpensesForPeriod(.weekly, expenses: dataService.expenses)
        return analyticsService.getTotalExpenses(for: weekly)
    }
    
    func addExpense(title: String, amount: Double, category: ExpenseCategory, date: Date, notes: String) {
        let expense = Expense(title: title, amount: amount, category: category, date: date, notes: notes)
        dataService.addExpense(expense)
    }
    
    func deleteExpense(_ expense: Expense) {
        dataService.deleteExpense(expense)
    }
    
    func updateExpense(_ expense: Expense) {
        dataService.updateExpense(expense)
    }
}
