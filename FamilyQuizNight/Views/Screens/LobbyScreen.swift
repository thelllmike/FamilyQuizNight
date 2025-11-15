
import SwiftUI

struct LobbyScreen: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        VStack(spacing: 30) {
            Text("Waiting for players to join…")
                .font(.system(size: 48, weight: .semibold))

            VStack(spacing: 12) {
                ForEach(game.players) { p in
                    Text("• \(p.name)")
                        .font(.system(size: 36))
                }
            }
            .padding(.top, 20)

            Text("Press Next to continue")
                .font(.title2)
                .opacity(0.7)

            LargeButton("Next") {
                game.screen = .genre
            }
        }
        .padding(60)
    }
}
