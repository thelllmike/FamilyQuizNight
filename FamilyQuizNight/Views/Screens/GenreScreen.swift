
import SwiftUI

struct GenreScreen: View {
    @EnvironmentObject var game: GameState

    private let columns = [GridItem(.adaptive(minimum: 250), spacing: 30)]

    var body: some View {
        VStack(spacing: 30) {
            Text("Choose Your Quiz Genre!")
                .font(.system(size: 56, weight: .bold))

            LazyVGrid(columns: columns, spacing: 30) {
                ForEach(Genre.allCases) { g in
                    Button {
                        game.chooseGenre(g)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 180)

                            Text(g.rawValue)
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(60)
    }
}
