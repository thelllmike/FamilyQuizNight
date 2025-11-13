import SwiftUI
internal import Combine

// MARK: - Models

enum Screen {
    case home, lobby, genre, question, scoreboard, gameover
}

struct Player: Identifiable {
    let id = UUID()
    var name: String
    var score: Int = 0
}

struct Question {
    let text: String
    let options: [String] // A, B, C, D
    let correctIndex: Int // 0..3
    let explanation: String? // e.g., "Elephant 🐘"
}

enum Genre: String, CaseIterable, Identifiable {
    case music = "Music"
    case cinema = "Cinema"
    case kdrama = "K-Drama"
    case netflix = "Netflix Originals"
    case tv = "TV Series"

    var id: String { rawValue }
}

// MARK: - Game State

@MainActor
final class GameState: ObservableObject {
    @Published var screen: Screen = .home

    @Published var players: [Player] = [
        Player(name: "Mom"),
        Player(name: "Dad"),
        Player(name: "Sam"),
        Player(name: "Ava")
    ]

    @Published var genre: Genre? = nil
    @Published var roundIndex: Int = 0
    @Published var questions: [Question] = []
    @Published var timerSeconds: Int = 10
    @Published var isCountingDown: Bool = false
    @Published var revealedCorrect: Bool = false
    @Published var selectedByPlayer: [UUID: Int] = [:] // playerId -> optionIndex

    // Config
    let roundsPerGame = 5
    let timePerQuestion = 10

    func resetAll() {
        players = players.map { Player(name: $0.name, score: 0) }
        genre = nil
        roundIndex = 0
        questions = []
        timerSeconds = timePerQuestion
        isCountingDown = false
        revealedCorrect = false
        selectedByPlayer = [:]
        screen = .home
    }

    func fakeLobby() {
        screen = .lobby
    }

    func chooseGenre(_ g: Genre) {
        genre = g
        loadQuestions(for: g)
        roundIndex = 0
        screen = .question
        startQuestion()
    }

    func loadQuestions(for g: Genre) {
        // Sample questions; you can change per genre if you want
        let sample: [Question] = [
            Question(
                text: "Which animal is the largest land mammal?",
                options: ["Lion", "Elephant", "Hippopotamus", "Giraffe"],
                correctIndex: 1,
                explanation: "Elephant 🐘"
            ),
            Question(
                text: "Which planet is known as the Red Planet?",
                options: ["Venus", "Mars", "Jupiter", "Saturn"],
                correctIndex: 1,
                explanation: "Mars"
            ),
            Question(
                text: "What is the capital of France?",
                options: ["Berlin", "Paris", "Rome", "Madrid"],
                correctIndex: 1,
                explanation: "Paris"
            ),
            Question(
                text: "In computing, what does CPU stand for?",
                options: [
                    "Central Processing Unit",
                    "Core Power Unit",
                    "Compute Process Utility",
                    "Central Power Unit"
                ],
                correctIndex: 0,
                explanation: "Central Processing Unit"
            ),
            Question(
                text: "Which ocean is the largest?",
                options: ["Atlantic", "Indian", "Pacific", "Arctic"],
                correctIndex: 2,
                explanation: "Pacific"
            )
        ]

        questions = Array(sample.prefix(roundsPerGame))
    }

    func startQuestion() {
        guard roundIndex < questions.count else {
            goToWinner()
            return
        }

        timerSeconds = timePerQuestion
        isCountingDown = true
        revealedCorrect = false
        selectedByPlayer = [:]

        Task {
            while isCountingDown && timerSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard isCountingDown else { return }
                timerSeconds -= 1
            }
            if timerSeconds <= 0 {
                endQuestionAndScore()
            }
        }
    }

    func endQuestionAndScore() {
        isCountingDown = false
        revealedCorrect = true
        scoreAnswers()
    }

    func scoreAnswers() {
        guard roundIndex < questions.count else { return }
        let q = questions[roundIndex]

        players = players.map { p in
            var copy = p
            if let sel = selectedByPlayer[p.id], sel == q.correctIndex {
                copy.score += 20 // points for correct
            }
            return copy
        }
    }

    func nextRoundOrScoreboard() {
        screen = .scoreboard
    }

    func nextFromScoreboard() {
        roundIndex += 1
        if roundIndex >= questions.count {
            goToWinner()
        } else {
            screen = .question
            startQuestion()
        }
    }

    func goToWinner() {
        screen = .gameover
    }
}

// MARK: - App Entry

@main
struct FamilyQuizNightApp: App {
    @StateObject private var game = GameState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(minWidth: 1280, minHeight: 720) // nice big window
                .environmentObject(game)
        }
    }
}

// MARK: - Root Router

struct RootView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        switch game.screen {
        case .home:
            HomeScreen()
        case .lobby:
            LobbyScreen()
        case .genre:
            GenreScreen()
        case .question:
            QuestionScreen()
        case .scoreboard:
            ScoreboardScreen()
        case .gameover:
            GameOverScreen()
        }
    }
}

// MARK: - Home Screen

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
                    // MVP: no controllers, just go to lobby
                    game.fakeLobby()
                }

                LargeButton("Settings") {
                    // TODO: add settings later
                }
            }
        }
        .padding(60)
    }
}

// MARK: - Lobby Screen

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

// MARK: - Genre Selection

struct GenreScreen: View {
    @EnvironmentObject var game: GameState

    let columns = [GridItem(.adaptive(minimum: 250), spacing: 30)]

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

// MARK: - Question Screen

struct QuestionScreen: View {
    @EnvironmentObject var game: GameState

    var q: Question? {
        guard game.roundIndex < game.questions.count else { return nil }
        return game.questions[game.roundIndex]
    }

    var progress: CGFloat {
        let total = CGFloat(game.timePerQuestion)
        let left = CGFloat(game.timerSeconds)
        guard total > 0 else { return 0 }
        return max(0, min(1, left / total))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Timer bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 18)

                Capsule()
                    .fill(Color.green)
                    .frame(width: 800 * progress, height: 18)
            }
            .animation(.linear(duration: 0.2), value: game.timerSeconds)

            HStack {
                Text("Q\(game.roundIndex + 1)")
                    .font(.title)
                    .foregroundColor(.secondary)
                Spacer()
                if let g = game.genre {
                    Text(g.rawValue)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }

            Text(q?.text ?? "")
                .font(.system(size: 40, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { idx in
                    let label = "ABCD"[idx]
                    OptionRow(
                        label: String(label),
                        text: q?.options[safe: idx] ?? "",
                        isCorrect: game.revealedCorrect && (idx == q?.correctIndex),
                        isDisabled: !game.isCountingDown
                    ) {
                        if game.isCountingDown {
                            // Simulate Sam answering
                            if let sam = game.players.first(where: { $0.name == "Sam" }) {
                                game.selectedByPlayer[sam.id] = idx
                            }
                        }
                    }
                }
            }

            Spacer()

            if game.revealedCorrect, let q = q {
                Text("Correct Answer: \(letter(for: q.correctIndex)) – \(q.explanation ?? "")")
                    .font(.title2)
                    .padding(.top, 10)

                HStack {
                    Spacer()
                    LargeButton("Next") {
                        game.nextRoundOrScoreboard()
                    }
                }
            }
        }
        .padding(40)
        .onChange(of: game.timerSeconds) { _, newVal in
            if newVal == 0 && !game.revealedCorrect {
                game.endQuestionAndScore()
            }
        }
    }

    func letter(for idx: Int) -> String {
        switch idx {
        case 0: return "A"
        case 1: return "B"
        case 2: return "C"
        default: return "D"
        }
    }
}

// MARK: - Scoreboard

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

// MARK: - Game Over

struct GameOverScreen: View {
    @EnvironmentObject var game: GameState

    var winner: Player? {
        game.players.max(by: { $0.score < $1.score })
    }

    var body: some View {
        VStack(spacing: 40) {
            if let w = winner {
                Text("Winner: \(w.name) (\(w.score) points)")
                    .font(.system(size: 64, weight: .bold))
            } else {
                Text("Winner: —")
                    .font(.system(size: 64, weight: .bold))
            }

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
}

// MARK: - UI Bits

struct LargeButton: View {
    var title: String
    var action: () -> Void

    init(_ t: String, _ a: @escaping () -> Void) {
        self.title = t
        self.action = a
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor)
                )
        }
        .buttonStyle(.plain)
    }
}

struct OptionRow: View {
    var label: String
    var text: String
    var isCorrect: Bool
    var isDisabled: Bool
    var onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 18) {
                Circle()
                    .fill(isCorrect ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(label)
                            .font(.headline)
                            .foregroundColor(.white)
                    )

                Text(text)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isCorrect
                        ? Color.green.opacity(0.15)
                        : Color.gray.opacity(0.12)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - Helpers

fileprivate extension String {
    subscript(i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }
}

fileprivate extension Array {
    subscript(safe idx: Index) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}
