import SwiftUI

struct QuestionScreen: View {
    @EnvironmentObject var game: GameState

    // Current question for this round
    private var q: Question? {
        guard game.roundIndex < game.questions.count else { return nil }
        return game.questions[game.roundIndex]
    }

    // Sam's selected option (if any)
    private var samSelection: Int? {
        guard let sam = game.players.first(where: { $0.name == "Sam" }) else {
            return nil
        }
        return game.selectedByPlayer[sam.id]
    }

    // Timer progress 0...1
    private var progress: CGFloat {
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

            // Options A–D
            VStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { idx in
                    let label = letter(for: idx)
                    let isCorrect = (q?.correctIndex == idx)
                    let isSelected = (samSelection == idx)

                    // Safely read option text without using [safe:]
                    let optionText: String = {
                        guard let question = q,
                              question.options.indices.contains(idx) else {
                            return ""
                        }
                        return question.options[idx]
                    }()

                    OptionRow(
                        label: label,
                        text: optionText,
                        isCorrect: isCorrect,
                        isSelected: isSelected,
                        showResult: game.revealedCorrect,
                        isDisabled: !game.isCountingDown
                    ) {
                        if game.isCountingDown {
                            if let sam = game.players.first(where: { $0.name == "Sam" }) {
                                game.selectedByPlayer[sam.id] = idx
                            }
                        }
                    }
                }
            }

            Spacer()

            // Reveal text + Next button after time ends / reveal
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

    private func letter(for idx: Int) -> String {
        switch idx {
        case 0: return "A"
        case 1: return "B"
        case 2: return "C"
        default: return "D"
        }
    }
}
