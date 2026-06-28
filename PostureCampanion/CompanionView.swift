import SwiftUI

struct CompanionView: View {

    @EnvironmentObject var manager: PostureManager

    @State private var blink = false
    @State private var floating = false

    var body: some View {

        ZStack {

            // Glow
            Circle()
                .fill(statusColor.opacity(0.25))
                .frame(width: 170, height: 170)
                .blur(radius: 30)

            VStack(spacing: -10) {

                // MARK: Evolution Rewards

                if manager.level >= 10 {
                    // Crown for High Level
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20))
                        .offset(y: -40)
                } else if manager.level >= 5 {
                    // Halo for Mid Level
                    Circle()
                        .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                        .frame(width: 40, height: 15)
                        .offset(y: -40)
                        .scaleEffect(x: 1.2, y: 0.5)
                }

                // MARK: Antenna

                VStack(spacing: 0) {

                    Circle()
                        .fill(statusColor)
                        .frame(width: 14, height: 14)

                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 4, height: 20)
                }

                // MARK: Head

                ZStack {

                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color.gray.opacity(0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                        )

                    VStack(spacing: 20) {

                        // Eyes

                        HStack(spacing: 28) {

                            eyeView
                            eyeView
                        }

                        // Mouth

                        mouthView
                    }
                }
                .frame(width: 120, height: 100)

                // MARK: Body

                ZStack {

                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)

                    VStack(spacing: 5) {

                        Circle()
                            .fill(statusColor)
                            .frame(width: 12, height: 12)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(statusColor.opacity(0.6))
                            .frame(width: 35, height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(statusColor.opacity(0.3))
                            .frame(width: 25, height: 6)
                    }
                }
                .frame(width: 75, height: 60)

                // MARK: XP

                VStack(spacing: 2) {

                    Text("Lv \(manager.level)")
                        .font(.caption.bold())

                    Text("\(manager.xp) XP")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .offset(y: floating ? -5 : 5)
            .rotationEffect(rotationAngle)
            .animation(
                .easeInOut(duration: 2),
                value: floating
            )

            // MARK: Break Bubble

            if manager.isBreakDue {

                SpeechBubble(
                    text: randomBreakMessage
                )
                .offset(x: 120, y: -80)
            }
        }
        .frame(width: 250, height: 250)
        .background(Color.clear)
        .onAppear {

            floating = true

            startBlinking()
        }
    }
}

// MARK: - Computed Views

extension CompanionView {

    private var eyeView: some View {

        Group {

            if blink {

                Capsule()
                    .fill(Color.black)
                    .frame(width: 16, height: 3)

            } else {

                Circle()
                    .fill(Color.black)
                    .frame(
                        width: eyeSize,
                        height: eyeSize
                    )
            }
        }
    }

    @ViewBuilder
    private var mouthView: some View {

        switch manager.currentState {

        case .good:

            SmileShape()
                .stroke(
                    Color.black,
                    lineWidth: 3
                )
                .frame(width: 24, height: 12)

        case .slightSlouch:

            Capsule()
                .fill(Color.black)
                .frame(width: 20, height: 3)

        case .severeSlouch:

            SadShape()
                .stroke(
                    Color.black,
                    lineWidth: 3
                )
                .frame(width: 24, height: 12)

        default:

            Capsule()
                .fill(Color.black)
                .frame(width: 16, height: 3)
        }
    }

    private var eyeSize: CGFloat {

        switch manager.currentState {

        case .good:
            return 10

        case .slightSlouch:
            return 12

        case .severeSlouch:
            return 14

        default:
            return 10
        }
    }

    private var statusColor: Color {

        switch manager.currentState {

        case .good:
            return .green

        case .slightSlouch:
            return .yellow

        case .severeSlouch:
            return .red

        case .cameraError:
            return .orange

        case .unknown:
            return .gray
        }
    }

    private var rotationAngle: Angle {

        switch manager.currentState {

        case .slightSlouch:
            return .degrees(-5)

        case .severeSlouch:
            return .degrees(5)

        default:
            return .degrees(0)
        }
    }

    private var randomBreakMessage: String {

        let messages = [
            "Stretch Time! 🧘",
            "Stand Up! 🚶",
            "Hydrate 💧",
            "Neck Roll!",
            "Walk 2 Minutes 🚶",
            "Move Your Shoulders!",
            "Touch The Ceiling 🙌"
        ]

        return messages.randomElement() ?? "Take a Break!"
    }
}

// MARK: - Blink Animation

extension CompanionView {

    private func startBlinking() {

        Timer.scheduledTimer(
            withTimeInterval: 3,
            repeats: true
        ) { _ in

            blink = true

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.15
            ) {

                blink = false
            }
        }
    }
}

// MARK: - Speech Bubble

struct SpeechBubble: View {

    let text: String

    var body: some View {

        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(Color.white)
            )
            .shadow(radius: 5)
    }
}

// MARK: - Smile

struct SmileShape: Shape {

    func path(in rect: CGRect) -> Path {

        var path = Path()

        path.addArc(
            center: CGPoint(
                x: rect.midX,
                y: rect.minY
            ),
            radius: rect.width / 2,
            startAngle: .degrees(20),
            endAngle: .degrees(160),
            clockwise: false
        )

        return path
    }
}

// MARK: - Sad

struct SadShape: Shape {

    func path(in rect: CGRect) -> Path {

        var path = Path()

        path.addArc(
            center:CGPoint(
                x: rect.midX,
                y: rect.maxY
            ),
            radius: rect.width / 2,
            startAngle: .degrees(200),
            endAngle: .degrees(340),
            clockwise: false
        )

        return path
    }
}
