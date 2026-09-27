//
//  Display.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-27.
//

import SwiftUI

struct Display: View {
    
    let value: String
    
    var body: some View {
        Text(value)
            .font(.title.weight(.bold))
            .fontDesign(.monospaced)
            .foregroundStyle(.white)
            .contentTransition(.numericText(countsDown: true))
            .animation(.bouncy, value: value)
    }
}

#Preview {
    Display(value: "00:10")
}
