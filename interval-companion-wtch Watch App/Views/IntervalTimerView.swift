//
//  IntervalTimerView.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-13.
//

import SwiftUI

struct IntervalTimerView: View {
    @State private var store = IntervalTimerStore()
    @State private var isShowingConfig = false
    @State private var runtimeManager = WatchRuntimeManager() // Monitors watch wrist states
    
    // Default values synced across to setup matrix
    @State private var workDuration: TimeInterval = 10
    @State private var restDuration: TimeInterval = 5
    @State private var totalCycles: Int = 2
    
    var body: some View {
        VStack(spacing: 8) {
            // Core Timeline Processing Frame
            TimelineView(
                .animation(
                    minimumInterval: 0.01,
                    paused: store.currentState != .running
                )
            ) { context in
                ZStack {
                    // 1. Thin adaptive circular ring track
                    Circle()
                        .stroke(
                            store.currentPhase?.type.color.opacity(0.15) ?? Color.gray.opacity(0.15),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                    
                    Circle()
                        .trim(from: 0.0, to: store.currentProgress)
                        .stroke(
                            store.currentPhase?.type.color ?? Color.gray,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.01), value: store.currentProgress)
                    
                    // 2. Focused central digital readouts
                    VStack(spacing: 2) {
                        if let phase = store.currentPhase {
                            Text(phase.type.rawValue.uppercased())
                                .font(.system(.caption2, design: .rounded)).bold()
                                .foregroundColor(phase.type.color)
                            
                            Text(String(format: "%.1f", max(0, store.timeRemaining)))
                                .font(.system(size: 34, weight: .bold, design: .monospaced))
                            
                            Text("R \(store.currentCycle)/\(store.totalCycles)")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundColor(.secondary)
                        } else {
                            Text(store.currentState == .completed ? "DONE 🎉" : "READY")
                                .font(.system(.headline, design: .rounded)).bold()
                        }
                    }
                }
                .frame(width: 130, height: 130) // Scaled safely for 41mm/45mm watch cases
                .onChange(of: context.date) { _, newDate in
                    store.update(currentDate: newDate)
                }
            }
            
            // 3. Compact Control System
            HStack(spacing: 12) {
                if store.currentState == .running {
                    Button(action: { store.pause() }) {
                        Image(systemName: "pause.fill")
                    }
                    .tint(.orange)
                } else {
                    Button(action: { store.start() }) {
                        Image(systemName: "play.fill")
                    }
                    .tint(.green)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small) // Fits micro layouts on small screens
        }
        .padding(.top, 4)
        // CRUCIAL STEP: Intercept current timing state variables
        .onChange(of: store.currentState) { _, newState in
            handleRuntimeState(for: newState)
        }
        .onAppear {
            loadTimerSettings()
        }
    }
    
    /// Locks or unlocks background continuous execution depending on target fitness state
    private func handleRuntimeState(for state: IntervalTimerState) {
        if state == .running {
            // Lock the system open to process drops in wrist posture cleanly
            runtimeManager.activateBackgroundSession()
        } else {
            // State is paused, idle, or completed -> Let watchOS sleep normally
            runtimeManager.deactivateBackgroundSession()
        }
    }
    
    private func loadTimerSettings() {
        store.setupTimer(
            workTime: workDuration,
            restTime: restDuration,
            cycles: totalCycles
        )
    }
}

#Preview {
    IntervalTimerView()
}
