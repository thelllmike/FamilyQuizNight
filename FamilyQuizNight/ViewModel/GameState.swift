import SwiftUI   // SwiftUI re-exports Combine, so this is enough
internal import Combine

// MARK: - Game State

@MainActor
final class GameState: ObservableObject {

    // Navigation
    @Published var screen: Screen = .home

    // Players
    @Published var players: [Player] = [
        Player(name: "Mom"),
        Player(name: "Dad"),
        Player(name: "Sam"),
        Player(name: "Ava")
    ]

    // Quiz state
    @Published var genre: Genre? = nil
    @Published var roundIndex: Int = 0
    @Published var questions: [Question] = []
    @Published var timerSeconds: Int = 10
    @Published var isCountingDown: Bool = false
    @Published var revealedCorrect: Bool = false
    @Published var selectedByPlayer: [UUID: Int] = [:]   // playerId -> optionIndex

    // Config
    let roundsPerGame = 5
    let timePerQuestion = 10
}

// MARK: - Public API

extension GameState {

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
        // Just show lobby – in future you could simulate players joining here
        screen = .lobby
    }

    func chooseGenre(_ g: Genre) {
        genre = g
        loadQuestions(for: g)
        roundIndex = 0
        screen = .question
        startQuestion()
    }

    func nextRoundOrScoreboard() {
        // Called from QuestionScreen after reveal
        screen = .scoreboard
    }

    /// Called from Scoreboard screen when tapping "Next Round"
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

// MARK: - Question / Timer logic

extension GameState {

    func loadQuestions(for g: Genre) {
        switch g {
        case .music:
            loadMusicQuestions()
        default:
            loadDefaultQuestions()
        }
    }

    private func loadMusicQuestions() {
        let musicQuestions: [Question] = [
            Question(
                text: "Which artist holds the record for the most Grammy wins in history?",
                options: ["Quincy Jones", "Beyoncé", "Georg Solti", "Jay-Z"],
                correctIndex: 2,
                explanation: "Georg Solti 🎵"
            ),
            Question(
                text: "Who is known as the “King of Pop”?",
                options: ["Bruno Mars", "Justin Timberlake", "Michael Jackson", "Lionel Richie"],
                correctIndex: 2,
                explanation: "Michael Jackson 👑"
            ),
            Question(
                text: "Which song became the first YouTube video to surpass 1 billion views?",
                options: [
                    "“Shape of You” – Ed Sheeran",
                    "“Baby” – Justin Bieber",
                    "“Gangnam Style” – PSY",
                    "“Despacito” – Luis Fonsi"
                ],
                correctIndex: 2,
                explanation: "“Gangnam Style” – PSY 💃"
            ),
            Question(
                text: "Which artist released an album entirely visual, with each track having its own accompanying film?",
                options: [
                    "Lady Gaga – Chromatica",
                    "Beyoncé – Lemonade",
                    "Billie Eilish – Happier Than Ever",
                    "Taylor Swift – Evermore"
                ],
                correctIndex: 1,
                explanation: "Beyoncé – Lemonade 🍋"
            ),
            Question(
                text: "Which band holds the record for the highest-selling album of all time in the US with “Their Greatest Hits (1971–1975)”?",
                options: ["The Eagles", "Fleetwood Mac", "Bee Gees", "The Rolling Stones"],
                correctIndex: 0,
                explanation: "The Eagles 🦅"
            )
        ]

        questions = Array(musicQuestions.prefix(roundsPerGame))
    }

    private func loadDefaultQuestions() {
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
                copy.score += 20
            }
            return copy
        }
    }
}
