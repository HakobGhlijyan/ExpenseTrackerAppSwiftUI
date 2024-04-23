//
//  ContentView.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 15.04.2024.
//

import SwiftUI

struct ContentView: View {
    // Intro Visiblity Status
    @AppStorage("isFirstTime") private var isFirstTime: Bool = true
    //App Lock Properties
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    @AppStorage("lockWhenAppGoesBackground") private var lockWhenAppGoesBackground: Bool = false
    // Active Tab
    @State private var acriveTab: Tab = .recents
    
    var body: some View {
        LockView(lockType: .biometric, lockPin: "0000", isEnabled: isAppLockEnabled, lockWhenAppGoesBackground: lockWhenAppGoesBackground) {
            TabView(selection: $acriveTab) {
                Recents()
                    .tag(Tab.recents)
                    .tabItem { Tab.recents.tabContent }
                
                Search()
                    .tag(Tab.search)
                    .tabItem { Tab.search.tabContent }
                
                Graphs()
                    .tag(Tab.charts)
                    .tabItem { Tab.charts.tabContent }
                
                Settings()
                    .tag(Tab.settings)
                    .tabItem { Tab.settings.tabContent }
            }
            .tint(appTint)
            .sheet(isPresented: $isFirstTime, content: {
                IntroScreen()
                    .interactiveDismissDisabled()
            })
        }
   }
}

#Preview {
    ContentView()
}
