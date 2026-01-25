//
//  Budget.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation

struct Budget: Identifiable, Codable {
    var id: UUID
    var category: ExpenseCategory
    var limit: Double
    var period: BudgetPeriod
    var startDate: Date
    var isActive: Bool
    
    init(id: UUID = UUID(), category: ExpenseCategory, limit: Double, period: BudgetPeriod, startDate: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.category = category
        self.limit = limit
        self.period = period
        self.startDate = startDate
        self.isActive = isActive
    }
}

enum BudgetPeriod: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct Achievement: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var icon: String
    var dateEarned: Date
    var isUnlocked: Bool
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, dateEarned: Date = Date(), isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.dateEarned = dateEarned
        self.isUnlocked = isUnlocked
    }
}
