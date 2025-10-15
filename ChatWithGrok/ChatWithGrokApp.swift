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
                .onAppear {
                    // Set status bar style based on color scheme
                    updateStatusBarStyle()
                }
                .onChange(of: systemColorScheme) { oldValue, newValue in
                    if preferredColorScheme == 0 {
                        updateStatusBarStyle()
                        // Force UI update
                        NotificationCenter.default.post(
                            name: NSNotification.Name("UpdateColorScheme"),
                            object: nil
                        )
                    }
                }
                .onChange(of: preferredColorScheme) { _, _ in
                    updateStatusBarStyle()
                }
        }
    }
    
    private func updateStatusBarStyle() {
        let isDark: Bool
        switch preferredColorScheme {
        case 0:
            isDark = systemColorScheme == .dark
        case 2:
            isDark = true
        default:
            isDark = false
        }
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = preferredColorScheme == 0 ? .unspecified : (isDark ? .dark : .light)
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
