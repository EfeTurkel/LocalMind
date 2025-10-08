//
//  LockMindApp.swift
//  LockMind
//
//  Created by Efe Türkel on 3.11.2024.
//

import SwiftUI

@main
struct LockMindApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("preferredColorScheme") private var preferredColorScheme: Int = 0
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(getPreferredColorScheme())
                .onChange(of: systemColorScheme) { oldValue, newValue in
                    if preferredColorScheme == 0 {
                        // Force UI update
                        NotificationCenter.default.post(
                            name: NSNotification.Name("UpdateColorScheme"),
                            object: nil
                        )
                    }
                }
        }
    }
    
    private func getPreferredColorScheme() -> ColorScheme? {
        switch preferredColorScheme {
        case 0:
            return nil // System
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }
}
