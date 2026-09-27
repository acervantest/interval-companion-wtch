//
//  IntervalTimerView.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-13.
//

import SwiftUI

struct IntervalTimerView: View {
    //@State private var store = IntervalTimerStore()
    @Environment(IntervalTimerStore.self) var store
    @State private var isShowingConfig = true
    @State private var runtimeManager = WatchRuntimeManager() // Monitors watch wrist states
    
    // Default values synced across to setup matrix
    @State private var workDuration: Int = 0
    @State private var restDuration: Int = 0
    @State private var totalCycles: Int = 0
    
    var body: some View {
        NavigationStack {
            // Core Timeline Processing Frame
            TimelineView(.animation(
                minimumInterval: 0.01,
                paused: store.currentState != .running)
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
                            
                            Display(value: store.display)
                            
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
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                            Button {
                                withAnimation {
                                    store.resetTimer()
                                    isShowingConfig = true
                                }
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .foregroundStyle(Color.orange)
                            
                            Spacer()
                            
                            Button {
                                switch store.currentState {
                                case .idle, .paused:
                                        withAnimation {
                                            store.start()
                                        }
                                case .running:
                                        withAnimation {
                                            store.pause()
                                        }
                                case .completed:
                                    break
                                }
                            } label: {
                                switch store.currentState {
                                case .idle, .paused, .completed:
                                        Image(systemName: "play")
                                            .id("idle-state")
                                case .running:
                                        Image(systemName: "pause")
                                            .id("pause-state")
                                }
                            }
                            .contentTransition(.identity)
                            //.transition(.opacity)
                            .disabled(store.currentState == .completed)
                            .foregroundStyle(Color.orange)
                    }
                    
                }
            }
        }
        //.padding(.top, 4)
        // CRUCIAL STEP: Intercept current timing state variables
        .onChange(of: store.currentState) { _, newState in
            handleRuntimeState(for: newState)
        }
        .onAppear {
           
        }
        .sheet(isPresented: $isShowingConfig, onDismiss: setupTimerCallbacks) {
                IntervalTimerConfigView(
                    isShowingConfig: $isShowingConfig,
                    workDuration: $workDuration,
                    restDuration: $restDuration,
                    totalCycles: $totalCycles
                )
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
    
    private func setupTimerCallbacks() {
        store.setupTimer(
            workTime: workDuration,
            restTime: restDuration,
            cycles: totalCycles
        )
        
        // Define haptic vibration assignments
        store.onPhaseChange = { nextPhaseType in
            guard let nextPhaseType else {
                // Workout Completed completely -> Long celebratory fan-fare pattern
                WKInterfaceDevice.current().play(.success)
                return
            }
            
            switch nextPhaseType {
            case .work:
                // Starting a Work Interval -> Aggressive double-tap pattern
                WKInterfaceDevice.current().play(.start)
            case .rest:
                // Starting a Rest Interval -> Subtle calming triple-click pattern
                WKInterfaceDevice.current().play(.directionDown)
            }
        }
    }
}

#Preview {
    @Previewable @State var store = IntervalTimerStore()
    NavigationStack {
        IntervalTimerView()
            .environment(store)
    }
}
