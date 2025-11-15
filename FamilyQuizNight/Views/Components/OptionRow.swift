import SwiftUI

struct OptionRow: View {
    var label: String
    var text: String
    var isCorrect: Bool
    var isSelected: Bool
    var showResult: Bool
    var isDisabled: Bool
    var onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 18) {
                Circle()
                    .fill(circleColor)
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
                    .fill(backgroundColor)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var circleColor: Color {
        if showResult {
            if isCorrect { return .green }
            if isSelected && !isCorrect { return .red }
            return Color.gray.opacity(0.3)
        } else {
            if isSelected { return .blue }
            return Color.gray.opacity(0.3)
        }
    }

    private var backgroundColor: Color {
        if showResult {
            if isCorrect { return Color.green.opacity(0.15) }
            if isSelected && !isCorrect { return Color.red.opacity(0.15) }
            return Color.gray.opacity(0.12)
        } else {
            if isSelected { return Color.blue.opacity(0.15) }
            return Color.gray.opacity(0.12)
        }
    }
}
