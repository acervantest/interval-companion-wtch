//
//  interval_companion_wtchApp.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-08.
//

import SwiftUI

@main
struct interval_companion_wtch_Watch_AppApp: App {
    
    @State private var store: IntervalTimerStore = .init()
    
    var body: some Scene {
        WindowGroup {
            IntervalTimerView()
                .environment(store)
        }
    }
}
