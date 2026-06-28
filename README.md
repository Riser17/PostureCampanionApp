# 🧘 Posture Companion

A cute, gamified macOS desktop companion that helps you maintain a healthy posture using real-time computer vision. Your pet's mood and evolution depend entirely on how straight you sit!

## ✨ Features

- **Real-time Posture Detection**: Powered by Apple's Vision Framework, the app analyzes your posture via the webcam and identifies slouching instantly.
- **Interactive Desktop Pet**: A transparent, floating companion that mirrors your posture:
    - 🟢 **Good Posture**: Pet is happy and energetic.
    - 🟡 **Slight Slouch**: Pet becomes curious/alert.
    - 🔴 **Severe Slouch**: Pet looks sad or "wilts."
- **Gamification & Evolution**:
    - Earn XP for every minute of good posture.
    - Level up to evolve your pet (Unlock a **Halo** at Level 5 and a **Golden Crown** at Level 10).
    - Track your progress with a weekly health analytics chart.
- **Wellness Reminders**: 
    - Cute speech bubbles appear when it's time to move.
    - Native macOS notifications and sound alerts every 30 minutes to encourage stretching.
- **Smart Calibration**: A "one-click" calibration system that learns your specific "perfect posture" based on your chair and camera angle.

## 🛠️ Tech Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI & AppKit
- **Vision**: `VNDetectHumanBodyPoseRequest` for landmark detection.
- **Persistence**: `SwiftData` for tracking XP, Levels, and Daily Scores.
- **OS**: macOS (Optimized for Apple Silicon).

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- A Mac with a built-in camera.

### Installation
1. Clone this repository to your local machine.
2. Open `PostureCampanion.xcodeproj` in Xcode.
3. **Crucial Step: Permissions & Sandbox**
    - Go to **Signing & Capabilities**.
    - Under **App Sandbox**, check the box for **Camera**.
    - Ensure `Info.plist` contains the `NSCameraUsageDescription` key.
4. Press `Cmd + R` to build and run.

### How to Use
1. **Calibrate**: Sit up as straight as possible and click **"Calibrate Posture"** in the Settings window.
2. **Interact**: Drag your pet anywhere on your screen.
3. **Evolve**: Maintain a good posture to earn XP and watch your pet evolve from a basic buddy to a Posture Master!

## 📁 Project Structure

- `PostureEngine.swift`: The Vision-based logic for landmark detection.
- `PostureManager.swift`: The central hub coordinating state, timers, and SwiftData.
- `CompanionView.swift`: The SwiftUI implementation of the pet's visuals and animations.
- `GamificationStore.swift`: SwiftData models for user progress and daily scoring.
- `PostureCompanionApp.swift`: The main entry point and floating window configuration.
- `SoundManager.swift`: Handles audio feedback for breaks and level-ups.


## Screenshots
<img width="4032" height="3024" alt="IMG_4130" src="https://github.com/user-attachments/assets/f089f8ca-2719-460e-989e-e9990b50223f" />
<img width="4032" height="3024" alt="IMG_4129" src="https://github.com/user-attachments/assets/f485e63c-3504-422f-b21c-ee22070d38e6" />
<img width="4032" height="3024" alt="IMG_4128" src="https://github.com/user-attachments/assets/aa66e956-f44a-461e-8b6a-fa3153120d60" />
<img width="4032" height="3024" alt="IMG_4127" src="https://github.com/user-attachments/assets/424206a4-1918-4929-b631-b4cb9b2ad6d6" />



## 📜 License
MIT License
