//
//  View+Extensions.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 16.04.2024.
//

import SwiftUI

let appTint: Color = Color.blue

//asButton
struct ButtonStyleViewModifier: ButtonStyle {
    let scale: CGFloat
    let opacity: Double
    let brightness: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? opacity : 1)
            .brightness(configuration.isPressed ? brightness : 0)
    }
}

public enum ButtonType {
    case press, opacity, tap
}

extension View {
    /// Wrap a View in a Button and add a custom ButtonStyle.
    func asButton(scale: CGFloat = 0.95, opacity: Double = 1, brightness: Double = 0, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            self
        })
        .buttonStyle(ButtonStyleViewModifier(scale: scale, opacity: opacity, brightness: brightness))
    }
    
    @ViewBuilder
    func asButton(_ type: ButtonType = .tap, action: @escaping () -> Void) -> some View {
        switch type {
        case .press:
            self.asButton(scale: 0.975, action: action)
        case .opacity:
            self.asButton(scale: 1, opacity: 0.85, action: action)
        case .tap:
            self.onTapGesture {
                action()
            }
        }
    }
}

// Orters
extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    @ViewBuilder
    func vSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    @available(iOSApplicationExtension, unavailable)
    var safeArea: UIEdgeInsets {
        if let windowsScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) {
            return windowsScene.keyWindow?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    func format(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    func currentString(_ value: Double, allowedDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = allowedDigits
        
        return formatter.string(from: .init(value: value)) ?? ""
    }
    var currencySymbol: String {
        let locale = Locale.current
        return locale.currencySymbol ?? ""
    }
    func total(_ transactions: [Transaction] , category: Category) -> Double {
        return transactions
            .filter({ $0.category == category.rawValue })
            .reduce(Double.zero) { partialResult, transaction in
                return partialResult + transaction.amount
            }
    }
    
}

extension Date {
    var startOfMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
    var endOfMonth: Date {
        Calendar.current.date(byAdding: .init(month: 1, minute: -1), to: self.startOfMonth) ?? self
    }
}
