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
    
    @Test("Timer display updates correctly", arguments: [
        (work: 45, rest: 15, cycles: 2, expectedString: "00:40"),
        (work: 10, rest: 5, cycles: 3, expectedString: "00:05"),
        (work: 90, rest: 20, cycles: 4, expectedString: "01:25")
    ])
    func displayUpdates(expectedWork: Int, expectedRest: Int, expectedCycles: Int, expectedString: String) {
        
        store.setupTimer(workTime: expectedWork, restTime: expectedRest, cycles: expectedCycles)
        
        let startDate = Date()
        store.start()
        
        // Simulate a TimelineView refresh exactly 5.5 seconds later
        let futureDate = startDate.addingTimeInterval(5.7)
        store.update(currentDate: futureDate)
        
        #expect(store.display == expectedString)
    }
    
    // MARK: - Parameterized Data-Driven Tests
       
   // This allows testing multiple workout variations without repeating code blocks
   @Test("Workout completions correctly mark states across diverse timeline durations", arguments: [
       (work: 10, rest: 5, cycles: 1, totalTime: 15),
       (work: 20, rest: 10, cycles: 3, totalTime: 90),
       (work: 45, rest: 15, cycles: 4, totalTime: 240)
   ])
   func workoutCompletions(expectedWork: Int, expectedRest: Int, expectedCycles: Int, totalTime: Int) {
       
       store.setupTimer(workTime: expectedWork, restTime: expectedRest, cycles: expectedCycles)
       
       var startDate = Date()
       store.start()
       
       let expectedWorkTI = TimeInterval(expectedWork)
       let expectedRestTI = TimeInterval(expectedRest)
       
       // Leap past entire session time boundary safely
       for _ in 1...expectedCycles {
           let executionEndDate = startDate.addingTimeInterval(expectedWorkTI + 0.6)
           store.update(currentDate: executionEndDate)
           // Then
           #expect(store.currentState == .running)
           #expect(store.timeRemaining == expectedRestTI)
           #expect(store.currentPhase?.type == .rest)
           #expect(store.currentPhase?.duration == expectedRestTI)
           
           let restEndDate = executionEndDate.addingTimeInterval(expectedRestTI + 0.6)
           store.update(currentDate: restEndDate)
           
           if store.currentState == .running {
               #expect(store.timeRemaining == expectedWorkTI)
               #expect(store.currentPhase?.type == .work)
               #expect(store.currentPhase?.duration == expectedWorkTI)
           }
           
           startDate = restEndDate
       }
       
       // Then
       #expect(store.currentState == .completed)
       #expect(store.timeRemaining == 0)
   }
}
