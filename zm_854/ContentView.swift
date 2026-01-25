//
//  ContentView.swift
//  FinTrendz
//
//  Created by Вячеслав on 1/25/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        // Customize TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: "470006"))
        
        // Customize unselected item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
        
        // Customize selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "F8EA0E"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "F8EA0E"))
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ExpensesView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Expenses")
                }
                .tag(1)
            
            InvestmentsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Investments")
                }
                .tag(2)
            
            BudgetView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Budget")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(Color.appYellow)
    }
}

#Preview {
    ContentView()
}
