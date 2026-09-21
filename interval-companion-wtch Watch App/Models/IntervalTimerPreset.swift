//
//  IntervalTimerPreset.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-17.
//

import Foundation
import SwiftData

@Model
class IntervalTimerPreset {
    var name: String
    var work: Int
    var rest: Int
    var cycles: Int
    var dateCreated: Date

    init(name: String, work: Int, rest: Int, cycles: Int) {
        self.name = name
        self.work = work
        self.rest = rest
        self.cycles = cycles
        self.dateCreated = Date()
    }

    private func exists(context: ModelContext, work: Int, rest: Int, cycles: Int) -> Bool {
        let predicate = #Predicate<IntervalTimerPreset> {
            $0.work == work && $0.rest == rest && $0.cycles == cycles
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
       
        do {
            let count = try context.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Failed to fetch count: \(error)")
            return false
        }
    }
    
    func save(context: ModelContext) {
        if !exists(context: context, work: self.work, rest: self.rest, cycles: self.cycles) {
            context.insert(self)
        } else {
            print("Instance W: \(self.work), R: \(self.rest), C: \(self.cycles) already exists")
        }
    }

    func remove(context: ModelContext) {
        context.delete(self)
    }
}
