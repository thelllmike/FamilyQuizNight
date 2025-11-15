import SwiftUI

struct ScoreboardScreen: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        VStack(spacing: 30) {
            Text("Scoreboard")
                .font(.system(size: 56, weight: .bold))

            VStack(spacing: 16) {
                ForEach(game.players.sorted(by: { $0.score > $1.score })) { p in
                    HStack {
                        Text(p.name)
                            .font(.system(size: 32, weight: .semibold))
                        Spacer()
                        Text("\(p.score) pts")
                            .font(.system(size: 32, weight: .medium))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                    )
                    .frame(maxWidth: 600)
                }
            }

            LargeButton("Next Round") {
                game.nextFromScoreboard()
            }
        }
        .padding(60)
    }
}
