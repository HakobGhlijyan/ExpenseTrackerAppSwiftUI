//
//  ExpenseTrackerAppSwiftUIApp.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 15.04.2024.
//

import SwiftUI
import WidgetKit

@main
struct ExpenseTrackerAppSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
        .modelContainer(for: [Transaction.self])
    }
}
