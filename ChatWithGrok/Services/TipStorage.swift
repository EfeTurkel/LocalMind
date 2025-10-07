import Foundation

final class TipStorage {
    static let shared = TipStorage()
    
    private let defaults = UserDefaults.standard
    private let lastTipKey = "lastTipDate"
    private let tipCountKey = "dailyTipCount"
    private let cooldownSeconds: TimeInterval = 24 * 60 * 60
    
    func getLastTipDate() -> Date? {
        return defaults.object(forKey: lastTipKey) as? Date
    }
    
    func setLastTipDate(_ date: Date) {
        defaults.set(date, forKey: lastTipKey)
    }
    
    func getTipCount() -> Int {
        return defaults.integer(forKey: tipCountKey)
    }
    
    func incrementTipCount() {
        let current = getTipCount()
        defaults.set(current + 1, forKey: tipCountKey)
    }
    
    func isTipAvailable(now: Date = Date()) -> Bool {
        guard let last = getLastTipDate() else { return true }
        let next = last.addingTimeInterval(cooldownSeconds)
        return now >= next
    }
    
    func timeRemainingString(now: Date = Date()) -> String {
        let last = getLastTipDate() ?? .distantPast
        let next = last.addingTimeInterval(cooldownSeconds)
        let remaining = max(0, next.timeIntervalSince(now))
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60
        if hours > 0 { return String(format: "%dh %dm %ds", hours, minutes, seconds) }
        if minutes > 0 { return String(format: "%dm %ds", minutes, seconds) }
        return String(format: "%ds", seconds)
    }
}


