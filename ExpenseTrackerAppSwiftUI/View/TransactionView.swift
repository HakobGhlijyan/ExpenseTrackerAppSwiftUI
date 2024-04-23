//
//  TransactionView.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 19.04.2024.
//

import SwiftUI
import WidgetKit

struct TransactionView: View {
    //Model Context
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var editTransaction: Transaction?
    //View Properties
    @State private var title: String = ""
    @State private var remarks: String = ""
    @State private var amount: Double = .zero
    @State private var dateAdded: Date = .now
    @State private var category: Category = .expense
    //Random Tint
    @State var tint: TintColor = tints.randomElement()!
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 15) {
                Text("Preview")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .hSpacing(.leading)
                //Preview transaction card view
                TransactionCardView(
                    transaction: .init(
                        title: title.isEmpty ? "Title" : title,
                        remarks: remarks.isEmpty ? "Remarks" : remarks,
                        amount: amount,
                        dateAdded: dateAdded,
                        category: category,
                        tintColor: tint
                    )
                )
                CustomSection("Title", "MagicKeyboard", value: $title)
                CustomSection("Remarks", "Apple Products", value: $remarks)
                
                // Amount and category
                VStack(alignment: .leading, spacing: 10, content: {
                    Text("Amount and Category")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                    HStack(spacing: 15) {
                        HStack(spacing: 4) {
                            Text(currencySymbol)
                                .font(.callout.bold())
                            
                            TextField("0.0", value: $amount, formatter: numberFormatter)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .background(.background, in: .rect(cornerRadius: 10))
                        .frame(maxWidth: 130)
                        
                        
                        CategoryCheckBox()
                    }
                })
                
                //Data Picker
                VStack(alignment: .leading, spacing: 10, content: {
                    Text("Data")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                    
                    DatePicker("", selection: $dateAdded, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .background(.background, in: .rect(cornerRadius: 10))
                })
                
            }
            .padding(15)
        }
        .navigationTitle("\(editTransaction == nil ? "Add" : "Edit") Transaction")
        .background(.gray.opacity(0.15))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .buttonStyle(.bordered)
                    .bold()
            }
        }
        .onAppear {
            // Load All Tansaction info load is orter view
            if let editTransaction {
                title = editTransaction.title
                remarks = editTransaction.remarks
                amount = editTransaction.amount
                dateAdded = editTransaction.dateAdded
                if let category = editTransaction.rawCategory {
                    self.category = category
                }
                if let tint = editTransaction.tint {
                    self.tint = tint
                }
            }
        }
    }
    
    //Save
    func save() {
        //Saving in SwiftData
        if editTransaction != nil {
            editTransaction?.title = title
            editTransaction?.remarks = remarks
            editTransaction?.amount = amount
            editTransaction?.category = category.rawValue
            editTransaction?.dateAdded = dateAdded
        } else {
            let transaction = Transaction(title: title, remarks: remarks, amount: amount, dateAdded: dateAdded, category: category, tintColor: tint)
            modelContext.insert(transaction)
        }
        // Dismiss Close View
        dismiss()
        //UPDATING WIDGET INFO
        WidgetCenter.shared.reloadAllTimelines()
    }
 
    @ViewBuilder
    func CustomSection(_ title: String, _ hint: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
                .hSpacing(.leading)
            TextField(hint, text: value)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(.background, in: .rect(cornerRadius: 10))
        })
    }
    
    @ViewBuilder
    func CategoryCheckBox() -> some View {
        HStack(spacing: 10) {
            ForEach(Category.allCases, id: \.rawValue) { category in
                HStack(spacing: 5.0) {
                    ZStack {
                        Image(systemName: "circle")
                            .font(.title3)
                            .foregroundStyle(appTint)
                        if self.category == category {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(appTint)
                        }
                    }
                    Text(category.rawValue)
                        .font(.caption)
                }
                .contentShape(.rect)
                .onTapGesture {
                    self.category = category
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .hSpacing(.leading)
        .background(.background, in: .rect(cornerRadius: 10))
    }
    
    // Formater
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
}

#Preview {
    NavigationStack {
        TransactionView()
    }
}
