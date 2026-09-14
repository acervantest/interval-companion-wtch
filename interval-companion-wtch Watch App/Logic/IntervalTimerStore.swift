//
//  IntervalTimerStore.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-08.
//
import SwiftUI


nonisolated enum IntervalTimerState {
    case idle, running, paused, completed
}

struct IntervalPhase {
    let type: IntervalType
    let duration: TimeInterval
}

@Observable
class IntervalTimerStore {
    // Configuration
    private var phases: [IntervalPhase] = []
    var totalCycles: Int = 0 // Track total cycles configured
    
    // State
    var currentState: IntervalTimerState = .idle
    var currentPhaseIndex: Int = 0
    var timeRemaining: TimeInterval = 0
    
    // Tracking precise elapsed time
    private var lastTickDate: Date?
    
    var currentPhase: IntervalPhase? {
        guard phases.indices.contains(currentPhaseIndex) else { return nil }
        return phases[currentPhaseIndex]
    }
    
    // Returns the current cycle number (1-indexed)
    var currentCycle: Int {
        // Each cycle has 2 phases (Work and Rest).
        // Adding 1 scales index 0-1 to round 1, index 2-3 to round 2, etc.
        min(totalCycles, (currentPhaseIndex / 2) + 1)
    }
    
    func setupTimer(workTime: TimeInterval, restTime: TimeInterval, cycles: Int) {
        phases.removeAll()
        
        self.totalCycles = cycles
        
        for _ in 1...cycles {
            phases.append(IntervalPhase(type: .work, duration: workTime))
            phases.append(IntervalPhase(type: .rest, duration: restTime))
        }
        
        resetTimer()
    }
    
    // Controls
    
    func start() {
        guard currentState == .idle || currentState == .paused else { return }
        lastTickDate = Date()
        currentState = .running
    }
    
    func pause() {
        currentState = .paused
        lastTickDate = nil
    }
    
    func resetTimer() {
        currentState = .idle
        currentPhaseIndex = 0
        timeRemaining = phases.first?.duration ?? 0
        lastTickDate = nil
    }
    
    // Core logic fired by TimelineView
    func update(currentDate: Date) {
        guard currentState == .running, let lastTick = lastTickDate else { return }
        
        // Calculate exact time elapsed since the last frame update
        let elapsed = currentDate.timeIntervalSince(lastTick)
        self.lastTickDate = currentDate
        
        timeRemaining -= elapsed
        
        if timeRemaining <= 0 {
            moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        currentPhaseIndex += 1
        
        if currentPhaseIndex < phases.count {
            // Move to next work/rest phase
            timeRemaining = phases[currentPhaseIndex].duration
            // Optional: Add haptic/audio feedback here
        } else {
            // All intervals done
            currentState = .completed
            timeRemaining = 0
            lastTickDate = nil
        }
    }
    
    // Returns a value between 0.0 and 1.0 representing completion progress of the active phase
    var currentProgress: CGFloat {
        guard let currentPhase, currentPhase.duration > 0 else { return 0 }
        // Progress goes from 1.0 (start) down to 0.0 (end)
        return CGFloat(timeRemaining / currentPhase.duration)
    }
}
