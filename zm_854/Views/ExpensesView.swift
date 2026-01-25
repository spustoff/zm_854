//
//  ExpensesView.swift
//  FinTrendz
//
//  Created on 2026
//

import SwiftUI

struct ExpensesView: View {
    @StateObject private var viewModel = ExpensesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expenses")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Track and manage your spending")
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
                            HStack(spacing: 16) {
                                StatCard(title: "Total", value: viewModel.totalExpenses.toCurrency(), color: .appYellow)
                                StatCard(title: "Monthly", value: viewModel.monthlyExpenses.toCurrency(), color: .orange)
                                StatCard(title: "Weekly", value: viewModel.weeklyExpenses.toCurrency(), color: .blue)
                            }
                            .padding(.horizontal)
                            
                            // Category Filter
                            if !viewModel.dataService.expenses.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        CategoryFilterButton(
                                            title: "All",
                                            isSelected: viewModel.selectedCategory == nil,
                                            action: { viewModel.selectedCategory = nil }
                                        )
                                        
                                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                            CategoryFilterButton(
                                                title: "\(category.icon) \(category.rawValue)",
                                                isSelected: viewModel.selectedCategory == category,
                                                action: { viewModel.selectedCategory = category }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Expenses by Category
                            if !viewModel.expensesByCategory.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Expenses by Category")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(Array(viewModel.expensesByCategory.keys.sorted(by: { 
                                            (viewModel.expensesByCategory[$0] ?? 0) > (viewModel.expensesByCategory[$1] ?? 0) 
                                        })), id: \.self) { category in
                                            HStack {
                                                Text("\(category.icon) \(category.rawValue)")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Text((viewModel.expensesByCategory[category] ?? 0).toCurrency())
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
                                                        .frame(width: geometry.size.width * CGFloat(min((viewModel.expensesByCategory[category] ?? 0) / viewModel.totalExpenses, 1.0)), height: 8)
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
                            
                            // Expenses List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("All Expenses")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                if viewModel.filteredExpenses.isEmpty {
                                    VStack(spacing: 16) {
                                        Text("📝")
                                            .font(.system(size: 60))
                                        Text("No expenses yet")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("Tap + to add your first expense")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                } else {
                                    ForEach(viewModel.filteredExpenses) { expense in
                                        ExpenseRow(expense: expense, onDelete: {
                                            viewModel.deleteExpense(expense)
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
                            viewModel.showingAddExpense = true
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
            .sheet(isPresented: $viewModel.showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatCard: View {
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

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .appBackground : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appYellow : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(expense.category.icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(expense.date.toString())
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                
                if !expense.notes.isEmpty {
                    Text(expense.notes)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount.toCurrency())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appYellow)
                
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

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ExpensesViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.food
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter expense title", text: $title)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                    Text("\(category.icon) \(category.rawValue)").tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter notes", text: $notes)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            if let amountValue = Double(amount), !title.isEmpty {
                                viewModel.addExpense(
                                    title: title,
                                    amount: amountValue,
                                    category: selectedCategory,
                                    date: date,
                                    notes: notes
                                )
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Add Expense")
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
            .navigationTitle("Add Expense")
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
