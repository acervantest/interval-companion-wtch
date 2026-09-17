//
//  IntervalTimerConfigView.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-15.
//

import SwiftUI

struct IntervalTimerConfigView: View {
    
    @Binding var isShowingConfig: Bool
    @Binding var workDuration: Int
    @Binding var restDuration: Int
    @Binding var totalCycles: Int
    
    var isButtonDisabled: Bool {
        workDuration == 0 || restDuration == 0 || totalCycles == 0
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Work", selection: $workDuration) {
                    ForEach(0..<50, id: \.self) {
                        Text("\($0)")
                    }
                }
                Picker("Rest", selection: $restDuration) {
                    ForEach(0..<50, id: \.self) {
                        Text("\($0)")
                    }
                }
                Picker("Cycles", selection: $totalCycles) {
                    ForEach(0..<50, id: \.self) {
                        Text("\($0)")
                    }
                }
            }
            Button {
                isShowingConfig = false
            } label: {
                Text("Stop Watch")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            .tint(.orange)
            .disabled(isButtonDisabled)
        }
        .interactiveDismissDisabled(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("", action: {})
                    .buttonStyle(.plain)
                    .opacity(0)
                    .disabled(true)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    
    @Previewable @State var isShowingConfig = true
    @Previewable @State var workduration: Int = 10
    @Previewable @State var restduration: Int = 5
    @Previewable @State var totalcycles = 3
    
    IntervalTimerConfigView(
        isShowingConfig: $isShowingConfig,
        workDuration: $workduration,
        restDuration: $restduration,
        totalCycles: $totalcycles
    )
}
