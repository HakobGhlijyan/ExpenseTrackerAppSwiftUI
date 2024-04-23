//
//  TransactionCardView.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 16.04.2024.
//

import SwiftUI

struct TransactionCardView: View {
    @Environment(\.modelContext) private var modelContext
    var transaction: Transaction
    var showCategory: Bool = false
    
    var body: some View {
        SwipeAction(cornerRadius: 10, direction: .trailing) {
            HStack {
                Text("\(String(transaction.title.prefix(1)))")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(transaction.color.gradient, in: .circle)
                
                VStack(alignment: .leading, spacing: 4, content: {
                    Text("\(transaction.title)")
                        .foregroundStyle(.primary)
                    
                    Text("\(transaction.remarks)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(format(date: transaction.dateAdded, format: "dd MMM yyyy"))
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    if showCategory {
                        Text(transaction.category)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .foregroundStyle(.white)
                            .background(transaction.category == Category.income.rawValue ? Color.green.gradient : Color.red.gradient, in: .capsule)
                    }
                    
                })
                .lineLimit(1)
                .hSpacing(.leading)

                Text(currentString(transaction.amount, allowedDigits: 2))
                    .fontWeight(.semibold)
              
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(.background, in: .rect(cornerRadius: 10))
        } actions: {
            Action(tint: .red, icon: "trash") {
                modelContext.delete(transaction) 
            }
        }
    }
}

#Preview {
    ContentView()
}
