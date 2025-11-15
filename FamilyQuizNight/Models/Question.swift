import Foundation

struct Question {
    let text: String
    let options: [String]    // A, B, C, D
    let correctIndex: Int    // 0..3
    let explanation: String?
}
