//
//  AnalyticsService.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Expense Analytics
    
    func getTotalExpenses(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func getExpensesByCategory(for expenses: [Expense]) -> [ExpenseCategory: Double] {
        var result: [ExpenseCategory: Double] = [:]
        
        for expense in expenses {
            result[expense.category, default: 0] += expense.amount
        }
        
        return result
    }
    
    func getExpensesForPeriod(_ period: BudgetPeriod, expenses: [Expense], startDate: Date = Date()) -> [Expense] {
        let calendar = Calendar.current
        let now = startDate
        
        let filtered = expenses.filter { expense in
            switch period {
            case .daily:
                return calendar.isDate(expense.date, inSameDayAs: now)
            case .weekly:
                guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
                return expense.date >= weekAgo && expense.date <= now
            case .monthly:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            case .yearly:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
            }
        }
        
        return filtered
    }
    
    func getAverageExpensePerDay(for expenses: [Expense]) -> Double {
        guard !expenses.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let dates = expenses.map { calendar.startOfDay(for: $0.date) }
        let uniqueDates = Set(dates)
        
        guard uniqueDates.count > 0 else { return 0 }
        
        let total = getTotalExpenses(for: expenses)
        return total / Double(uniqueDates.count)
    }
    
    // MARK: - Budget Analytics
    
    func getBudgetProgress(budget: Budget, expenses: [Expense]) -> Double {
        let relevantExpenses = getExpensesForPeriod(budget.period, expenses: expenses, startDate: budget.startDate)
            .filter { $0.category == budget.category }
        
        let spent = getTotalExpenses(for: relevantExpenses)
        
        guard budget.limit > 0 else { return 0 }
        return (spent / budget.limit) * 100
    }
    
    func getRemainingBudget(budget: Budget, expenses: [Expense]) -> Double {
        let relevantExpenses = getExpensesForPeriod(budget.period, expenses: expenses, startDate: budget.startDate)
            .filter { $0.category == budget.category }
        
        let spent = getTotalExpenses(for: relevantExpenses)
        return max(0, budget.limit - spent)
    }
    
    func isOverBudget(budget: Budget, expenses: [Expense]) -> Bool {
        let progress = getBudgetProgress(budget: budget, expenses: expenses)
        return progress > 100
    }
    
    // MARK: - Investment Analytics
    
    func getTotalInvestmentValue(for investments: [Investment]) -> Double {
        investments.reduce(0) { $0 + $1.currentAmount }
    }
    
    func getTotalInvestmentCost(for investments: [Investment]) -> Double {
        investments.reduce(0) { $0 + $1.initialAmount }
    }
    
    func getTotalProfitLoss(for investments: [Investment]) -> Double {
        investments.reduce(0) { $0 + $1.profitLoss }
    }
    
    func getAverageProfitLossPercentage(for investments: [Investment]) -> Double {
        guard !investments.isEmpty else { return 0 }
        
        let total = investments.reduce(0.0) { $0 + $1.profitLossPercentage }
        return total / Double(investments.count)
    }
    
    func getInvestmentsByType(for investments: [Investment]) -> [InvestmentType: Double] {
        var result: [InvestmentType: Double] = [:]
        
        for investment in investments {
            result[investment.type, default: 0] += investment.currentAmount
        }
        
        return result
    }
    
    // MARK: - Financial Tips
    
    func getDailyFinancialTip() -> String {
        let tips = [
            "💡 Track every expense, no matter how small. Small purchases add up!",
            "🎯 Set realistic budget goals. Start small and increase gradually.",
            "📊 Review your spending weekly to stay on track.",
            "💰 Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings.",
            "🏦 Automate your savings - pay yourself first!",
            "📈 Diversify your investments to reduce risk.",
            "🎓 Invest in yourself - education pays the best interest.",
            "🔍 Compare prices before making big purchases.",
            "💳 Avoid impulse buying - wait 24 hours before purchasing.",
            "🎁 Use cashback and rewards programs wisely.",
            "📱 Review and cancel unused subscriptions.",
            "🍽️ Meal planning can save hundreds monthly.",
            "🚗 Consider carpooling or public transport to save on gas.",
            "💡 Energy-efficient habits reduce utility bills.",
            "📖 Read financial books to improve money management skills."
        ]
        
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return tips[dayOfYear % tips.count]
    }
    
    func getSpendingInsight(for expenses: [Expense]) -> String {
        let categoryTotals = getExpensesByCategory(for: expenses)
        
        guard let topCategory = categoryTotals.max(by: { $0.value < $1.value }) else {
            return "Start tracking expenses to see insights!"
        }
        
        let total = getTotalExpenses(for: expenses)
        let percentage = (topCategory.value / total) * 100
        
        return "Your top spending category is \(topCategory.key.icon) \(topCategory.key.rawValue) at \(String(format: "%.1f", percentage))%"
    }
}
