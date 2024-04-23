//
//  Settings.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 16.04.2024.
//

import SwiftUI

struct Settings: View {
    //User Properties
    @AppStorage("userName") private var userName: String = ""
    //App Lock Properties
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    @AppStorage("lockWhenAppGoesBackground") private var lockWhenAppGoesBackground: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("User Name") {
                    TextField("This is your name...", text: $userName)
                }
                Section("App Lock") {
                    Toggle("Is App Lock Enabled", isOn: $isAppLockEnabled)
                    
                    if isAppLockEnabled {
                        Toggle("Lock When App Goes Background", isOn: $lockWhenAppGoesBackground)
                    }
                }
            }
            .font(.subheadline)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    Settings()
}
