//
//  ViewExtensions.swift
//  FinTrendz
//
//  Created on 2026
//

import SwiftUI

// MARK: - Neumorphic Style

extension View {
    func neumorphic(backgroundColor: Color = Color(hex: "470006")) -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.05), radius: 10, x: -5, y: -5)
            )
    }
    
    func neumorphicButton(backgroundColor: Color = Color(hex: "470006")) -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                    .shadow(color: Color.white.opacity(0.05), radius: 5, x: -3, y: -3)
            )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let appBackground = Color(hex: "470006")
    static let appYellow = Color(hex: "F8EA0E")
}

// MARK: - Currency Formatting

extension Double {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    func toPercentage() -> String {
        return String(format: "%.2f%%", self)
    }
}

// MARK: - Date Formatting

extension Date {
    func toString(format: String = "MMM d, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .month], from: self, to: now)
        
        if let month = components.month, month > 0 {
            return "\(month) month\(month == 1 ? "" : "s") ago"
        } else if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Conditional Modifiers

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
