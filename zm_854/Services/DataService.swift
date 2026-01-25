//
//  DataService.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @AppStorage("expenses") private var expensesData: Data = Data()
    @AppStorage("investments") private var investmentsData: Data = Data()
    @AppStorage("budgets") private var budgetsData: Data = Data()
    @AppStorage("achievements") private var achievementsData: Data = Data()
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    @Published var expenses: [Expense] = []
    @Published var investments: [Investment] = []
    @Published var budgets: [Budget] = []
    @Published var achievements: [Achievement] = []
    
    private init() {
        loadData()
        initializeDefaultAchievements()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        loadExpenses()
        loadInvestments()
        loadBudgets()
        loadAchievements()
    }
    
    private func loadExpenses() {
        if let decoded = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            expenses = decoded
        }
    }
    
    private func loadInvestments() {
        if let decoded = try? JSONDecoder().decode([Investment].self, from: investmentsData) {
            investments = decoded
        }
    }
    
    private func loadBudgets() {
        if let decoded = try? JSONDecoder().decode([Budget].self, from: budgetsData) {
            budgets = decoded
        }
    }
    
    private func loadAchievements() {
        if let decoded = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
            achievements = decoded
        }
    }
    
    // MARK: - Data Saving
    
    func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            expensesData = encoded
        }
    }
    
    func saveInvestments() {
        if let encoded = try? JSONEncoder().encode(investments) {
            investmentsData = encoded
        }
    }
    
    func saveBudgets() {
        if let encoded = try? JSONEncoder().encode(budgets) {
            budgetsData = encoded
        }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            achievementsData = encoded
        }
    }
    
    // MARK: - CRUD Operations
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
        checkAchievements()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpenses()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
    }
    
    func addInvestment(_ investment: Investment) {
        investments.append(investment)
        saveInvestments()
        checkAchievements()
    }
    
    func updateInvestment(_ investment: Investment) {
        if let index = investments.firstIndex(where: { $0.id == investment.id }) {
            investments[index] = investment
            saveInvestments()
        }
    }
    
    func deleteInvestment(_ investment: Investment) {
        investments.removeAll { $0.id == investment.id }
        saveInvestments()
    }
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    // MARK: - Delete All Data
    
    func deleteAllData() {
        expenses = []
        investments = []
        budgets = []
        achievements = []
        hasCompletedOnboarding = false
        
        saveExpenses()
        saveInvestments()
        saveBudgets()
        saveAchievements()
        
        initializeDefaultAchievements()
    }
    
    // MARK: - Achievements
    
    private func initializeDefaultAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(title: "First Step", description: "Add your first expense", icon: "🎯", isUnlocked: false),
                Achievement(title: "Investor", description: "Add your first investment", icon: "💼", isUnlocked: false),
                Achievement(title: "Budget Master", description: "Create your first budget", icon: "📊", isUnlocked: false),
                Achievement(title: "Week Warrior", description: "Track expenses for 7 days", icon: "⭐", isUnlocked: false),
                Achievement(title: "Budget Champion", description: "Stay within budget for a month", icon: "🏆", isUnlocked: false),
                Achievement(title: "Savings Pro", description: "Save 20% of your income", icon: "💰", isUnlocked: false),
                Achievement(title: "Investment Guru", description: "Achieve 10% return on investment", icon: "📈", isUnlocked: false),
                Achievement(title: "Consistency King", description: "Track finances for 30 days", icon: "👑", isUnlocked: false)
            ]
            saveAchievements()
        }
    }
    
    private func checkAchievements() {
        var updated = false
        
        // First Step - Add first expense
        if expenses.count >= 1 && !achievements[0].isUnlocked {
            achievements[0].isUnlocked = true
            achievements[0].dateEarned = Date()
            updated = true
        }
        
        // Investor - Add first investment
        if investments.count >= 1 && !achievements[1].isUnlocked {
            achievements[1].isUnlocked = true
            achievements[1].dateEarned = Date()
            updated = true
        }
        
        // Budget Master - Create first budget
        if budgets.count >= 1 && !achievements[2].isUnlocked {
            achievements[2].isUnlocked = true
            achievements[2].dateEarned = Date()
            updated = true
        }
        
        if updated {
            saveAchievements()
        }
    }
    
    func unlockAchievement(at index: Int) {
        guard index < achievements.count else { return }
        achievements[index].isUnlocked = true
        achievements[index].dateEarned = Date()
        saveAchievements()
    }
}
