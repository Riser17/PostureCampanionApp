import Foundation
import Combine
import SwiftUI
import SwiftData
import UserNotifications

struct DayPostureScore {
    let day: String
    let score: Double // 0.0 to 100.0
}

class PostureManager: ObservableObject {
    static let shared = PostureManager()

    @Published var currentState: PostureState = .unknown
    @Published var xp: Int = 0
    @Published var level: Int = 1
    @Published var isBreakDue: Bool = false

    private let engine = PostureEngine()
    private var breakTimer: Timer?
    private var xpTimer: Timer?
    private var trackingTimer: Timer?

    private var modelContext: ModelContext?
    private var userProgress: UserProgress?

    private var sessionTotalMinutes: Int = 0
    private var sessionGoodMinutes: Int = 0

    private init() {
        setupSwiftData()
        loadProgress()
        requestNotificationPermission()

        engine.delegate = self
        engine.start()
        startBreakTimer()
        startXPTimer()
        startTrackingTimer()
    }

    private func setupSwiftData() {
        do {
            let container = try ModelContainer(for: UserProgress.self, DailyScore.self)
            modelContext = ModelContext(container)
        } catch {
            print("SwiftData Error: Could not initialize ModelContainer: \(error)")
        }
    }

    private func loadProgress() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<UserProgress>()
        if let firstProgress = try? context.fetch(descriptor).first {
            self.userProgress = firstProgress
            self.xp = firstProgress.xp
            self.level = firstProgress.level
        } else {
            let newProgress = UserProgress()
            context.insert(newProgress)
            try? context.save()
            self.userProgress = newProgress
            self.xp = 0
            self.level = 1
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func calibrate() {
        engine.triggerCalibration()
    }

    private func startBreakTimer() {
        breakTimer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { _ in
            DispatchQueue.main.async {
                self.isBreakDue = true
                self.sendBreakNotification()
                SoundManager.shared.playBreakReminder()
            }
        }
    }

    private func sendBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to stretch! 🧘"
        content.body = "Your pet is waiting for you to stand up and move around."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "break_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func startXPTimer() {
        xpTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.currentState == .good {
                    self.awardXP(1)
                }
            }
        }
    }

    private func startTrackingTimer() {
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            DispatchQueue.main.async {
                self.sessionTotalMinutes += 1
                if self.currentState == .good {
                    self.sessionGoodMinutes += 1
                }
                self.updateDailyScore()
            }
        }
    }

    private func updateDailyScore() {
        guard let context = modelContext, let progress = userProgress else { return }

        let today = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<DailyScore> { $0.date == today }
        let descriptor = FetchDescriptor<DailyScore>(predicate: predicate)

        if let todayScore = try? context.fetch(descriptor).first {
            let currentSessionRatio = Double(sessionGoodMinutes) / Double(max(1, sessionTotalMinutes)) * 100.0
            todayScore.score = (todayScore.score + currentSessionRatio) / 2.0
            try? context.save()
        } else {
            let currentSessionRatio = Double(sessionGoodMinutes) / Double(max(1, sessionTotalMinutes)) * 100.0
            let newScore = DailyScore(date: today, score: currentSessionRatio)
            progress.dailyScores.append(newScore)
            try? context.save()
        }
    }

    func awardXP(_ amount: Int) {
        xp += amount
        if let progress = userProgress {
            progress.addXP(amount)
            try? modelContext?.save()
            self.level = progress.level
        }
    }

    func resetBreak() {
        isBreakDue = false
    }

    func getWeeklyProgress() -> [DayPostureScore]? {
        guard let progress = userProgress else { return nil }

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E"

        var finalResults: [DayPostureScore] = []
        for i in (0...6).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: calendar.startOfDay(for: Date())) {
                let dayLetter = formatter.string(from: date)
                let score = progress.dailyScores.first(where: {
                    calendar.isDate($0.date, inSameDayAs: date)
                })?.score ?? 0.0
                finalResults.append(DayPostureScore(day: dayLetter, score: score))
            }
        }

        return finalResults
    }

    deinit {
        engine.stop()
        breakTimer?.invalidate()
        xpTimer?.invalidate()
        trackingTimer?.invalidate()
    }
}

extension PostureManager: PostureEngineDelegate {
    func postureEngine(_ engine: PostureEngine, didUpdateState state: PostureState) {
        DispatchQueue.main.async {
            self.currentState = state
        }
    }
}
