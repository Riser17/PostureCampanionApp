import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func playSound(named name: String) {
        // Look for the sound file in the main bundle
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("SoundManager: Asset \(name).mp3 not found in bundle.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("SoundManager: Could not play sound \(name): \(error)")
        }
    }

    func playLevelUp() {
        playSound(named: "levelup_fanfare")
    }

    func playBreakReminder() {
        playSound(named: "break_ding")
    }
}
