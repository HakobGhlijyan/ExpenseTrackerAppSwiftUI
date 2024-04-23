//
//  DateFilterView.swift
//  ExpenseTrackerAppSwiftUI
//
//  Created by Hakob Ghlijyan on 17.04.2024.
//

import SwiftUI

struct DateFilterView: View {
    @State var start: Date
    @State var end: Date
    
    var onSubmitDate: (Date, Date) -> ()
    var onClose: () -> ()
    
    var body: some View {
        VStack(spacing: 15) {
            
            //Date Picker
            DatePicker(
                "Start Date",
                selection: $start,
                displayedComponents: [.date]
            )
            DatePicker(
                "End Date",
                selection: $end,
                displayedComponents: [.date]
            )
            
            //Buttons
            HStack(spacing: 15) {
                Button("Cancel") {
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(.red)
                
                Button("Filter") {
                    onSubmitDate(start, end)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(appTint)
                
            }
            .padding(.top, 10)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
        .padding(.horizontal, 30)
    }
}
