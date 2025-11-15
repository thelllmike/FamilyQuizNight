import SwiftUI

struct GameOverScreen: View {
    @EnvironmentObject var game: GameState

    // Highest-scoring player
    private var winner: Player? {
        game.players.max(by: { $0.score < $1.score })
    }

    @State private var pulse = false

    var body: some View {
        ZStack {
            // Confetti / balloons background
            ConfettiView()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Game Over")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 10)

                if let w = winner {
                    Text("Winner: \(w.name) (\(w.score) points)")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(pulse ? 1.08 : 0.95)
                        .shadow(radius: 8)
                        .animation(
                            .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: pulse
                        )
                } else {
                    Text("Winner: —")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Final scores
                VStack(spacing: 12) {
                    Text("Final Scores")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))

                    ForEach(game.players.sorted(by: { $0.score > $1.score })) { p in
                        HStack {
                            Text(p.name)
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(p.score) pts")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.black.opacity(0.35))
                        )
                        .frame(maxWidth: 500)
                    }
                }
                .padding(.top, 10)

                LargeButton("Play Again") {
                    game.resetAll()
                    game.fakeLobby()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        game.screen = .genre
                    }
                }
            }
            .padding(60)
        }
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Confetti / Balloons View

struct ConfettiView: View {
    private let emojis = ["🎈", "🎉", "🎊", "✨"]
    private let itemCount = 28

    @State private var animate = false

    var body: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            GeometryReader { geo in
                ZStack {
                    ForEach(0..<itemCount, id: \.self) { i in
                        let xPos = CGFloat(i) / CGFloat(itemCount) * geo.size.width
                        let delay = Double(i) * 0.12
                        let emoji = emojis[i % emojis.count]
                        let size: CGFloat = CGFloat.random(in: 26...40)

                        Text(emoji)
                            .font(.system(size: size))
                            .position(
                                x: xPos,
                                y: animate ? geo.size.height + 60 : -60
                            )
                            .rotationEffect(.degrees(animate ? 360 : 0))
                            .opacity(0.9)
                            .animation(
                                .linear(duration: Double.random(in: 4.0...6.0))
                                    .repeatForever(autoreverses: false)
                                    .delay(delay),
                                value: animate
                            )
                    }
                }
            }
        )
        .onAppear {
            animate = true
        }
    }
}
