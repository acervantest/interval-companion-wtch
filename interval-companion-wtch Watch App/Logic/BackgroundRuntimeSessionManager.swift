//
//  BackgroundRuntimeSessionManager.swift
//  interval-companion-wtch Watch App
//
//  Created by Alejandro Cervantes on 2026-09-13.
//

import WatchKit

@Observable
class WatchRuntimeManager: NSObject, WKExtendedRuntimeSessionDelegate {
    private var session: WKExtendedRuntimeSession?
    
    /// Starts the session to guarantee execution when the wrist drops
    func activateBackgroundSession() {
        // Ensure we don't duplicate active sessions
        guard session == nil || session?.state == .invalid else { return }
        
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        print("Starts the session to guarantee execution when the wrist drops")
    }
    
    /// Releases the execution lock, allowing watchOS to sleep normally
    func deactivateBackgroundSession() {
        session?.invalidate()
        session = nil
        print("Releases the execution lock, allowing watchOS to sleep normally")
    }
    
    // MARK: - WKExtendedRuntimeSessionDelegate Requirements
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Session successfully grabbed system background processing priority
        print("watchOS running loop locked active.")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        // Triggered when session finishes or gets forcefully terminated by OS
        print("watchOS background tracking released.")
        self.session = nil
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Clean up tasks if the session reaches the system timeout limit (typically 1 hour)
        deactivateBackgroundSession()
    }
}

