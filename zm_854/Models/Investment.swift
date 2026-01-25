//
//  Investment.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation

struct Investment: Identifiable, Codable {
    var id: UUID
    var name: String
    var symbol: String
    var initialAmount: Double
    var currentAmount: Double
    var purchaseDate: Date
    var type: InvestmentType
    
    var profitLoss: Double {
        currentAmount - initialAmount
    }
    
    var profitLossPercentage: Double {
        guard initialAmount > 0 else { return 0 }
        return ((currentAmount - initialAmount) / initialAmount) * 100
    }
    
    init(id: UUID = UUID(), name: String, symbol: String, initialAmount: Double, currentAmount: Double, purchaseDate: Date = Date(), type: InvestmentType) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.initialAmount = initialAmount
        self.currentAmount = currentAmount
        self.purchaseDate = purchaseDate
        self.type = type
    }
}

enum InvestmentType: String, Codable, CaseIterable {
    case stocks = "Stocks"
    case crypto = "Crypto"
    case bonds = "Bonds"
    case realEstate = "Real Estate"
    case commodities = "Commodities"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .stocks: return "📈"
        case .crypto: return "₿"
        case .bonds: return "📊"
        case .realEstate: return "🏠"
        case .commodities: return "💎"
        case .other: return "💰"
        }
    }
}
