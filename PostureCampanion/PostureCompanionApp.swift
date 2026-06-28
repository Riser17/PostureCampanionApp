import SwiftUI
import AppKit

class CompanionPanel<T: View>: NSPanel {
    init(contentRect: NSRect, content: T) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .titled],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces]
        self.hasShadow = false

        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden

        // Enable dragging by clicking and holding anywhere on the window
        self.isMovableByWindowBackground = true

        let hostingController = NSHostingController(rootView: content)
        self.contentView = hostingController.view
        self.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    }

    override var canBecomeKey: Bool {
        return false
    }
}

@main
struct PostureCompanionApp: App {
    @StateObject private var postureManager = PostureManager.shared

    var body: some Scene {
        Settings {
            VStack(spacing: 20) {
                Text("Posture Companion Settings")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Current Status:")
                        Spacer()
                        Text(postureManager.currentState.description)
                            .bold()
                            .foregroundColor(statusColor(for: postureManager.currentState))
                    }

                    HStack {
                        Text("Level:")
                        Spacer()
                        Text("\(postureManager.level)")
                            .bold()
                    }

                    HStack {
                        Text("Total XP:")
                        Spacer()
                        Text("\(postureManager.xp)")
                            .bold()
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))

                // Posture Analytics Chart (Coming soon in Task 8)
                if let chartData = postureManager.getWeeklyProgress() {
                    VStack(alignment: .leading) {
                        Text("Weekly Progress")
                            .font(.caption.bold())
                            .padding(.top)

                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(chartData, id: \.day) { data in
                                VStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(data.score > 70 ? Color.green : Color.yellow)
                                        .frame(width: 20, height: CGFloat(data.score * 0.5))
                                    Text(data.day)
                                        .font(.system(size: 8))
                                }
                                .frame(width: 25)
                                .padding(.vertical, 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                }

                if postureManager.isBreakDue {
                    Button("I've taken a break!") {
                        postureManager.resetBreak()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button("Calibrate Posture") {
                    postureManager.calibrate()
                }
                .buttonStyle(.bordered)
                .padding(.top)
                .help("Sit up straight and click this to set your baseline.")

                Text("Tip: Sit up straight before calibrating!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 320, height: 450)
        }
    }

    init() {
        setupCompanionPanel()
    }

    private func setupCompanionPanel() {
        DispatchQueue.main.async {
            let manager = PostureManager.shared
            let content = CompanionView()
                .environmentObject(manager)
                .frame(width: 200, height: 200)

            let panel = CompanionPanel(
                contentRect: NSRect(x: 1500, y: 500, width: 200, height: 200),
                content: content
            )
            panel.makeKeyAndOrderFront(nil)
        }
    }

    private func statusColor(for state: PostureState) -> Color {
        switch state {
        case .good: return .green
        case .slightSlouch: return .yellow
        case .severeSlouch: return .red
        case .unknown: return .gray
        case .cameraError: return .orange
        }
    }
}
