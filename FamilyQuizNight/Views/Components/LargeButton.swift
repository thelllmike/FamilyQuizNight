import SwiftUI

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
