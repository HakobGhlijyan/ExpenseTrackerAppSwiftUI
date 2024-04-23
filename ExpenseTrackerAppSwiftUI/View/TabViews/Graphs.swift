//
//  Graphs.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 16.04.2024.
//

import SwiftUI
import SwiftData
import Charts

struct Graphs: View {
    //View Properties
    @Query(animation: .snappy) private var transactions: [Transaction]
    @State private var chartGroups: [ChartGroup] = []
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 10) {
                    // Charts View
                    ChartView()
                        .frame(height: 200)
                        .padding(10)
                        .padding(.top, 10)
                        .background(.background, in: .rect(cornerRadius: 10))
                    
                    //
                    ForEach(chartGroups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(format(date: group.date, format: "MMM yy"))
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .hSpacing(.leading)
                            
                            NavigationLink {
                                ListOfExpense(month: group.date)
                            } label: {
                                CardView(income: group.totalIncome, expense: group.totalExpense)
                            }
                            .buttonStyle(.plain)

                        }
                    }
                    
                }
                .padding(15)
            }
            .navigationTitle("Graphs")
            .background(.gray.opacity(0.15))
            .onAppear {
                // Creating Chart Groupe
                creatingChartGroupe()
            }
        }
        
    }
    
    func creatingChartGroupe() {
        Task.detached(priority: .high) {
            let calendar = Calendar.current
            
            let groupedByDate = Dictionary(grouping: transactions) { transaction in
                let components = calendar.dateComponents([.month, .year], from: transaction.dateAdded)
                return components
            }
            
            // Sorting Groupe by Date
            let sortedGroups = groupedByDate.sorted {
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }

            let chartGroups = sortedGroups.compactMap { dict -> ChartGroup? in
                let date = calendar.date(from: dict.key) ?? .init()
                let income = dict.value.filter({ $0.category == Category.income.rawValue })
                let expense = dict.value.filter({ $0.category == Category.expense.rawValue })
                
                let incomeTotalValue = total(income, category: .income)
                let expenseTotalValue = total(expense, category: .expense)
                
                return .init(
                    date: date,
                    categories: [
                        .init(totalValue: incomeTotalValue, category: .income),
                        .init(totalValue: expenseTotalValue, category: .expense)
                    ],
                    totalIncome: incomeTotalValue,
                    totalExpense: expenseTotalValue
                )
            }
            
            //UI Update ... Be Main threads
            await MainActor.run {
                self.chartGroups = chartGroups
            }
            
        }
    }
    
    //Chart View
    @ViewBuilder
    func ChartView() -> some View {
        Chart {
            ForEach(chartGroups) { group in
                ForEach(group.categories) { chart in
                    BarMark(
                        x: .value("Month", format(date: group.date, format: "MMM yy")),
                        y: .value(chart.category.rawValue, chart.totalValue),
                        width: 20
                    )
                    .position(by: .value("Categoty", chart.category.rawValue), axis: .horizontal)
                    .foregroundStyle(by: .value("Categoty", chart.category.rawValue))
                }
            }
        }
        // Making Chart Scrollable
        .chartScrollableAxes(.horizontal)
        //dlina gde pokazina grafic
        .chartXVisibleDomain(length: 4)
        // Chart  category ..
        .chartLegend(position: .bottom, alignment: .trailing)
        // Cifri vozle znacheniya
        .chartYAxis(content: {
            AxisMarks(position: .leading) { value in
                let doubleValue = value.as(Double.self) ?? 0
                
                AxisGridLine()
                AxisTick()
                
                AxisValueLabel {
//                    Text("\(doubleValue)")
                    Text(axisLabel(doubleValue))
                }
            }
        })
        // ForeGround color
        .chartForegroundStyleScale(range: [Color.green.gradient, Color.red.gradient])
    }
    
    //Convert on string Doble value in chart
    func axisLabel(_ value: Double) -> String {
        let intValue = Int(value)        // cislo menche 1000 ...
        let kValue = Int(value) / 1000   // bolche 1000
        
        return intValue < 1000 ? "\(intValue)" : "\(kValue)K" //esli budet menche 1000 to pokajet intvalue
    }
    
}

// List of Transactions for the Selected Month
struct ListOfExpense: View {
    let month: Date
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15) {
                // .income
                Section {
                    FilterTransactionsView(startDate: month.startOfMonth, endDate: month.endOfMonth, category: .income) { transactions in
                        ForEach(transactions) { transaction in
                            NavigationLink {
                                TransactionView(editTransaction: transaction)
                            } label: {
                                TransactionCardView(transaction: transaction)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Income")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                }
                // .expense
                Section {
                    FilterTransactionsView(startDate: month.startOfMonth, endDate: month.endOfMonth, category: .expense) { transactions in
                        ForEach(transactions) { transaction in
                            NavigationLink {
                                TransactionView(editTransaction: transaction)
                            } label: {
                                TransactionCardView(transaction: transaction)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Expense")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                }

            }
            .padding(15)
        }
        .background(.gray.opacity(0.15))
        .navigationTitle(format(date: month, format: "MMM yy"))
    }
}

#Preview {
    Graphs()
}
