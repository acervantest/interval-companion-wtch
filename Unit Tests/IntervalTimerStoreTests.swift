//
//  Unit_Tests.swift
//  Unit Tests
//
//  Created by Alejandro Cervantes on 2026-09-09.
//

import Testing
import Foundation
@testable import interval_companion_wtch_Watch_App

@Suite("Interval Timer Engine Tests")
struct IntervalTimerStoreTests {
    
    let store = IntervalTimerStore()
    
    // MARK: - Initialization Tests
        
    @Test("Timer initialization creates correct sequence matrix and defaults")
    func timerSetup() {
        // Given a configuration of 2 cycles of 20s Work and 10s Rest
        store.setupTimer(workTime: 20, restTime: 10, cycles: 2)
        
        // Then
        #expect(store.totalCycles == 2)
        #expect(store.currentState == .idle)
        #expect(store.currentPhaseIndex == 0)
        #expect(store.timeRemaining == 20)
        #expect(store.currentCycle == 1)
        #expect(store.currentPhase?.type == .work)
        #expect(store.currentPhase?.duration == 20)
        #expect(store.currentProgress == 1.0)
    }
    
    // MARK: - State Management Tests
       
   @Test("Timer changes state accurately when user interacts with controls")
   func stateTransitions() {
       
       store.setupTimer(workTime: 20, restTime: 10, cycles: 1)
       
       store.start()
       #expect(store.currentState == .running)
       
       store.pause()
       #expect(store.currentState == .paused)
       
       store.resetTimer()
       #expect(store.currentState == .idle)
       #expect(store.timeRemaining == 20)
   }
    
    // MARK: - Core Timeline Simulation Engine
        
    @Test("Timeline engine ticks down time remaining and calculates percentages exactly")
    func timelineTicks() {

        store.setupTimer(workTime: 20, restTime: 10, cycles: 1)
        
        let startDate = Date()
        store.start()
        
        // Simulate a TimelineView refresh exactly 5.5 seconds later
        let futureDate = startDate.addingTimeInterval(5.5)
        store.update(currentDate: futureDate)
        
        // Use tolerance checks for floating-point values
        #expect(abs(store.timeRemaining - 14.5) < 0.001)
        #expect(abs(store.currentProgress - (14.5 / 20.0)) < 0.001)
    }
    
    @Test("Timer gracefully rolls over into rest phase when work duration finishes")
    func phaseRollover() {
        
        store.setupTimer(workTime: 20, restTime: 10, cycles: 2)
        
        let startDate = Date()
        store.start()
        
        // Advance time past the 20-second work window boundary
        let endOfWorkDate = startDate.addingTimeInterval(20.1)
        store.update(currentDate: endOfWorkDate)
        
        // Then: Engine must transition to Rest phase while preserving frame drift
        #expect(store.currentPhase?.type == .rest)
        #expect(store.currentCycle == 1)
        #expect(abs(store.timeRemaining - 9.9) < 0.1) // 0.1s overflow correctly subtracted
    }
    
    // MARK: - Parameterized Data-Driven Tests
       
   // This allows testing multiple workout variations without repeating code blocks
   @Test("Workout completions correctly mark states across diverse timeline durations", arguments: [
       (work: 10.0, rest: 5.0, cycles: 1, totalTime: 15.0),
       (work: 20.0, rest: 10.0, cycles: 3, totalTime: 90.0),
       (work: 45.0, rest: 15.0, cycles: 4, totalTime: 240.0)
   ])
   func workoutCompletions(expectedWork: TimeInterval, expectedRest: TimeInterval, expectedCycles: Int, totalTime: TimeInterval) {
       
       store.setupTimer(workTime: expectedWork, restTime: expectedRest, cycles: expectedCycles)
       
       var startDate = Date()
       store.start()
       
       // Leap past entire session time boundary safely
       for _ in 1...expectedCycles {
           let executionEndDate = startDate.addingTimeInterval(expectedWork + 0.6)
           store.update(currentDate: executionEndDate)
           // Then
           #expect(store.currentState == .running)
           #expect(store.timeRemaining == expectedRest)
           #expect(store.currentPhase?.type == .rest)
           #expect(store.currentPhase?.duration == expectedRest)
           
           let restEndDate = executionEndDate.addingTimeInterval(expectedRest + 0.6)
           store.update(currentDate: restEndDate)
           
           if store.currentState == .running {
               #expect(store.timeRemaining == expectedWork)
               #expect(store.currentPhase?.type == .work)
               #expect(store.currentPhase?.duration == expectedWork)
           }
           
           startDate = restEndDate
       }
       
       // Then
       #expect(store.currentState == .completed)
       #expect(store.timeRemaining == 0)
   }
}
