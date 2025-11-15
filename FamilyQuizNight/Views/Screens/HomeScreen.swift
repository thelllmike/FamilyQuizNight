import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        VStack(spacing: 40) {
            Text("Family Quiz Night")
                .font(.system(size: 72, weight: .bold))

            HStack(spacing: 40) {
                LargeButton("Start Game") {
                    game.fakeLobby()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        game.screen = .genre
                    }
                }

                LargeButton("Join Game") {
                    // MVP: just show lobby for now
                    game.fakeLobby()
                }

                LargeButton("Settings") {
                    // TODO: Add settings later (rounds, timer length, etc.)
                }
            }
        }
        .padding(60)
    }
}
