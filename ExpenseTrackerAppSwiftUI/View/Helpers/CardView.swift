//
//  CardView.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 16.04.2024.
//

import SwiftUI

struct CardView: View {
    // Properties
    var income: Double
    var expense: Double
    
    var body: some View {
        ZStack {
            //1
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.background)
            //2
            VStack(spacing: 0) {
                HStack(spacing: 12.0) {
                    Text("\(currentString(income - expense))")
                        .font(.title).bold()
                        .foregroundStyle(.primary)
                    
                    Image(systemName: expense > income ? "chart.line.downtrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundStyle(expense > income ? .red : .green)
                }
                .padding(.bottom, 25)
                
                HStack(spacing: 0) {
                    ForEach(Category.allCases, id: \.rawValue) { category in
                        // Property
                        let symbolImage = category == .income ? "arrow.down" : "arrow.up"
                        let tint = category == .income ? Color.green : Color.red
                        
                        HStack(spacing: 10) {
                            //1
                            Image(systemName: symbolImage)
                                .font(.callout.bold())
                                .foregroundStyle(tint)
                                .frame(width: 35, height: 35)
                                .background(
                                    Circle()
                                        .fill(tint.opacity(0.25).gradient)
                                )
                            //2
                            VStack(alignment: .leading, spacing: 4.0) {
                                Text(category.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                                
                                Text(currentString(category == .income ? income : expense, allowedDigits: 0))
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                            //3
                            if category == .income {
                                Spacer(minLength: 10)
                            }
                            
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom], 25)
            .padding(.top, 15)
        }
    }
}

#Preview {
    CardView(income: 4590, expense: 2389)
}
