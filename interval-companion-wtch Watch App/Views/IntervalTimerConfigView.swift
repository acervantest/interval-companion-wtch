//
//  IntervalTimerConfigView.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-15.
//

import SwiftUI
import SwiftData

struct IntervalTimerConfigView: View {
    
    @Environment(\.modelContext) private var context
    
    @Binding var isShowingConfig: Bool
    @Binding var workDuration: Int
    @Binding var restDuration: Int
    @Binding var totalCycles: Int
    
    @State private var addNewPreset: Bool = false
    
    @Query(sort: \IntervalTimerPreset.dateCreated, order: .reverse)
    private var presets: [IntervalTimerPreset]
    
    var isButtonDisabled: Bool {
        workDuration == 0 || restDuration == 0 || totalCycles == 0
    }
    
    private var isQueryEmpty: Bool {
        presets.isEmpty
    }
    
    var body: some View {
        VStack {
            List {
                if !isQueryEmpty && !addNewPreset {
                    ForEach(presets) { preset in
                        Button(action: {
                            workDuration = preset.work
                            restDuration = preset.rest
                            totalCycles = preset.cycles
                            isShowingConfig = false // Instantly apply and exit sheet to save steps
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(preset.name)
                                    .font(.system(.body, design: .rounded)).bold()
                                Text("\(Int(preset.work))s / \(Int(preset.rest))s • \(preset.cycles)R")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteItem(preset)
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .tint(.red)
                            }
                        }
                    }
                    
                    if !isQueryEmpty {
                        Button {
                            addNewPreset = true
                        } label: {
                            Text("Add New Preset")
                        }
                    }
                }
            }
            .listStyle(.carousel)
            .overlay {
                if isQueryEmpty || addNewPreset {
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
                            savePreset()
                            isShowingConfig = false
                        } label: {
                            Text("Stop Watch")
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        .tint(.orange)
                        .disabled(isButtonDisabled)
                    }
                    .toolbar {
                        if !isQueryEmpty {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    addNewPreset = false
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    }
                }
            }
        }
        //.interactiveDismissDisabled(true)
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
    
    private func savePreset() {
        let newPreset = IntervalTimerPreset(
            name: "Preset \(presets.count + 1)",
            work: workDuration,
            rest: restDuration,
            cycles: totalCycles
        )
        newPreset.save(context: context)
    }
    
    func deleteItem(_ item: IntervalTimerPreset) {
        let presetToDelete = item
        presetToDelete.remove(context: context)
    }
}

#Preview {
    @Previewable @State var isShowingConfig = true
    @Previewable @State var workduration: Int = 10
    @Previewable @State var restduration: Int = 5
    @Previewable @State var totalcycles = 3
    
    // 1. Create a container wrapped in a MainActor closure
    let container = try! ModelContainer(
        for: IntervalTimerPreset.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 2. Add sample data to display in the preview canvas
    let presets: [IntervalTimerPreset] = [
        IntervalTimerPreset(name: "Preset 1", work: 10, rest: 5, cycles: 8),
        IntervalTimerPreset(name: "Preset 2", work: 8, rest: 4, cycles: 2)
    ]
    
    for preset in presets {
        container.mainContext.insert(preset)
    }
    
    return NavigationStack {
        IntervalTimerConfigView(
            isShowingConfig: $isShowingConfig,
            workDuration: $workduration,
            restDuration: $restduration,
            totalCycles: $totalcycles
        )
        .modelContainer(container)
    }
}
