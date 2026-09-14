//
//  IntervalType.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-08.
//

import SwiftUI

enum IntervalType: String {
    case work = "Work"
    case rest = "Rest"
    
    var color: Color {
        self == .work ? .orange : .blue
    }
    
    var icon: String {
        switch self {
        case .work:
            return "work"
        case .rest:
            return "rest"
        }
    }
    
    var colors: [Color] {
        switch self {
        case .work:
            [.blue]
        case .rest:
            [.orange]
        }
    }
}
