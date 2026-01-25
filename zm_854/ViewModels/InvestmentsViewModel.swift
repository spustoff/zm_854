//
//  InvestmentsViewModel.swift
//  FinTrendz
//
//  Created on 2026
//

import Foundation
import SwiftUI
import Combine

class InvestmentsViewModel: ObservableObject {
    @Published var dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    
    @Published var showingAddInvestment = false
    @Published var selectedType: InvestmentType?
    
    var filteredInvestments: [Investment] {
        if let type = selectedType {
            return dataService.investments.filter { $0.type == type }
        }
        return dataService.investments
    }
    
    var totalValue: Double {
        analyticsService.getTotalInvestmentValue(for: filteredInvestments)
    }
    
    var totalCost: Double {
        analyticsService.getTotalInvestmentCost(for: filteredInvestments)
    }
    
    var totalProfitLoss: Double {
        analyticsService.getTotalProfitLoss(for: filteredInvestments)
    }
    
    var averageReturn: Double {
        analyticsService.getAverageProfitLossPercentage(for: filteredInvestments)
    }
    
    var investmentsByType: [InvestmentType: Double] {
        analyticsService.getInvestmentsByType(for: filteredInvestments)
    }
    
    var bestPerformer: Investment? {
        dataService.investments.max(by: { $0.profitLossPercentage < $1.profitLossPercentage })
    }
    
    var worstPerformer: Investment? {
        dataService.investments.min(by: { $0.profitLossPercentage < $1.profitLossPercentage })
    }
    
    func addInvestment(name: String, symbol: String, initialAmount: Double, currentAmount: Double, purchaseDate: Date, type: InvestmentType) {
        let investment = Investment(name: name, symbol: symbol, initialAmount: initialAmount, currentAmount: currentAmount, purchaseDate: purchaseDate, type: type)
        dataService.addInvestment(investment)
    }
    
    func deleteInvestment(_ investment: Investment) {
        dataService.deleteInvestment(investment)
    }
    
    func updateInvestment(_ investment: Investment) {
        dataService.updateInvestment(investment)
    }
}
