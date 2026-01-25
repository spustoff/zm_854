//
//  InvestmentsView.swift
//  FinTrendz
//
//  Created on 2026
//

import SwiftUI

struct InvestmentsView: View {
    @StateObject private var viewModel = InvestmentsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Investments")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Track your portfolio performance")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Summary Stats
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    InvestmentStatCard(
                                        title: "Total Value",
                                        value: viewModel.totalValue.toCurrency(),
                                        color: .appYellow
                                    )
                                    
                                    InvestmentStatCard(
                                        title: "Total Cost",
                                        value: viewModel.totalCost.toCurrency(),
                                        color: .blue
                                    )
                                }
                                
                                HStack(spacing: 16) {
                                    InvestmentStatCard(
                                        title: "Profit/Loss",
                                        value: viewModel.totalProfitLoss.toCurrency(),
                                        color: viewModel.totalProfitLoss >= 0 ? .green : .red
                                    )
                                    
                                    InvestmentStatCard(
                                        title: "Avg Return",
                                        value: viewModel.averageReturn.toPercentage(),
                                        color: viewModel.averageReturn >= 0 ? .green : .red
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            // Portfolio Distribution
                            if !viewModel.investmentsByType.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Portfolio Distribution")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(Array(viewModel.investmentsByType.keys.sorted(by: { 
                                            (viewModel.investmentsByType[$0] ?? 0) > (viewModel.investmentsByType[$1] ?? 0) 
                                        })), id: \.self) { type in
                                            HStack {
                                                Text("\(type.icon) \(type.rawValue)")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Text((viewModel.investmentsByType[type] ?? 0).toCurrency())
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.appYellow)
                                            }
                                            .padding(.horizontal)
                                            
                                            GeometryReader { geometry in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.white.opacity(0.1))
                                                        .frame(height: 8)
                                                    
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.appYellow)
                                                        .frame(width: geometry.size.width * CGFloat(min((viewModel.investmentsByType[type] ?? 0) / viewModel.totalValue, 1.0)), height: 8)
                                                }
                                            }
                                            .frame(height: 8)
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding()
                                .neumorphic()
                                .padding(.horizontal)
                            }
                            
                            // Best & Worst Performers
                            if viewModel.bestPerformer != nil || viewModel.worstPerformer != nil {
                                VStack(spacing: 12) {
                                    if let best = viewModel.bestPerformer {
                                        PerformerCard(
                                            title: "📈 Best Performer",
                                            investment: best,
                                            color: .green
                                        )
                                    }
                                    
                                    if let worst = viewModel.worstPerformer {
                                        PerformerCard(
                                            title: "📉 Needs Attention",
                                            investment: worst,
                                            color: .red
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Investments List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("All Investments")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                if viewModel.filteredInvestments.isEmpty {
                                    VStack(spacing: 16) {
                                        Text("💼")
                                            .font(.system(size: 60))
                                        Text("No investments yet")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("Tap + to add your first investment")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                } else {
                                    ForEach(viewModel.filteredInvestments) { investment in
                                        InvestmentRow(investment: investment, onDelete: {
                                            viewModel.deleteInvestment(investment)
                                        })
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
                            viewModel.showingAddInvestment = true
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
            .sheet(isPresented: $viewModel.showingAddInvestment) {
                AddInvestmentView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InvestmentStatCard: View {
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

struct PerformerCard: View {
    let title: String
    let investment: Investment
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(investment.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(investment.symbol)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(investment.profitLoss.toCurrency())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                    
                    Text(investment.profitLossPercentage.toPercentage())
                        .font(.system(size: 14))
                        .foregroundColor(color.opacity(0.8))
                }
            }
        }
        .padding()
        .neumorphic()
    }
}

struct InvestmentRow: View {
    let investment: Investment
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(investment.type.icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(investment.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(investment.symbol)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Purchased: \(investment.purchaseDate.toString())")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(investment.currentAmount.toCurrency())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text(investment.profitLoss.toCurrency())
                    .font(.system(size: 14))
                    .foregroundColor(investment.profitLoss >= 0 ? .green : .red)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct AddInvestmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: InvestmentsViewModel
    
    @State private var name = ""
    @State private var symbol = ""
    @State private var initialAmount = ""
    @State private var currentAmount = ""
    @State private var selectedType = InvestmentType.stocks
    @State private var purchaseDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("e.g., Apple Inc.", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Symbol")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("e.g., AAPL", text: $symbol)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Initial Amount")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $initialAmount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Value")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $currentAmount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("Type", selection: $selectedType) {
                                ForEach(InvestmentType.allCases, id: \.self) { type in
                                    Text("\(type.icon) \(type.rawValue)").tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Date")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            if let initial = Double(initialAmount),
                               let current = Double(currentAmount),
                               !name.isEmpty, !symbol.isEmpty {
                                viewModel.addInvestment(
                                    name: name,
                                    symbol: symbol,
                                    initialAmount: initial,
                                    currentAmount: current,
                                    purchaseDate: purchaseDate,
                                    type: selectedType
                                )
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Add Investment")
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
            .navigationTitle("Add Investment")
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
