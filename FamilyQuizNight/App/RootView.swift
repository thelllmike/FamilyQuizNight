import SwiftUI

struct RootView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        switch game.screen {
        case .home:       HomeScreen()
        case .lobby:      LobbyScreen()
        case .genre:      GenreScreen()
        case .question:   QuestionScreen()
        case .scoreboard: ScoreboardScreen()
        case .gameover:   GameOverScreen()
        }
    }
}
