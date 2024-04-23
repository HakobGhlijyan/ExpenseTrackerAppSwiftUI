//
//  FilterTransactionsView.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 20.04.2024.
//

import SwiftUI
import SwiftData

// Custom View
struct FilterTransactionsView<Content: View>: View {
    //Content
    var content: ([Transaction]) -> Content
    //Query
    @Query(animation: .snappy) private var transactions: [Transaction]
    
    // INIT , for search
    init(category: Category?, searchText: String, @ViewBuilder content: @escaping ([Transaction]) -> Content) {
        let rawValue = category?.rawValue ?? ""
        //Custom Predicate
        let predicate = #Predicate<Transaction> { transaction in
            return (transaction.title.localizedStandardContains(searchText) || transaction.remarks.localizedStandardContains(searchText)) && (rawValue.isEmpty ? true : transaction.category == rawValue)
        }
        _transactions = Query(filter: predicate, sort: [SortDescriptor(\Transaction.dateAdded, order: .reverse)], animation: .snappy)
        self.content = content
    }
    
    // INIT , for date
    init(startDate: Date, endDate: Date, @ViewBuilder content: @escaping ([Transaction]) -> Content) {
        //Custom Predicate
        let predicate = #Predicate<Transaction> { transaction in
            return transaction.dateAdded >= startDate && transaction.dateAdded <= endDate
        }
        _transactions = Query(filter: predicate, sort: [SortDescriptor(\Transaction.dateAdded, order: .reverse)], animation: .snappy)
        self.content = content
    }
    
    // Optional For Your Customize Usage
    init(startDate: Date, endDate: Date, category: Category?, @ViewBuilder content: @escaping ([Transaction]) -> Content) {
        let rawValue = category?.rawValue ?? ""
        //Custom Predicate
        let predicate = #Predicate<Transaction> { transaction in
            return transaction.dateAdded >= startDate && transaction.dateAdded <= endDate && (rawValue.isEmpty ? true : transaction.category == rawValue)
        }
        _transactions = Query(filter: predicate, sort: [SortDescriptor(\Transaction.dateAdded, order: .reverse)], animation: .snappy)
        self.content = content
    }
    
    var body: some View {
        content(transactions)
    }
}
