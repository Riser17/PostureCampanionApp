import Foundation
import SwiftData

@Model
class UserProgress {
    var xp: Int = 0
    var level: Int = 1
    var lastSessionDate: Date = Date()
    var currentStreak: Int = 0

    @Relationship(deleteRule: .cascade)
    var dailyScores: [DailyScore] = []

    init(xp: Int = 0, level: Int = 1, currentStreak: Int = 0) {
        self.xp = xp
        self.level = level
        self.currentStreak = currentStreak
        self.lastSessionDate = Date()
    }

    func addXP(_ amount: Int) {
        xp += amount
        let newLevel = Int(sqrt(Double(xp) / 10.0)) + 1
        if newLevel > level {
            level = newLevel
        }
    }

    func updateStreak() {
        let calendar = Calendar.current
        if calendar.isDateInYesterday(lastSessionDate) {
            currentStreak += 1
        } else if !calendar.isDateInToday(lastSessionDate) {
            currentStreak = 1
        }
        lastSessionDate = Date()
    }
}

@Model
class DailyScore {
    var date: Date
    var score: Double // Percentage of time in "Good" posture (0-100)

    init(date: Date = Date(), score: Double = 0.0) {
        self.date = date
        self.score = score
    }
}
