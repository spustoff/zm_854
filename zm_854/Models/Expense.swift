//
//  Expense.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), title: String, amount: Double, category: ExpenseCategory, date: Date = Date(), notes: String = "") {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
    }
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case food = "Food"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case bills = "Bills"
    case health = "Health"
    case education = "Education"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "🍔"
        case .transportation: return "🚗"
        case .entertainment: return "🎬"
        case .shopping: return "🛍️"
        case .bills: return "📄"
        case .health: return "💊"
        case .education: return "📚"
        case .other: return "📦"
        }
    }
}
