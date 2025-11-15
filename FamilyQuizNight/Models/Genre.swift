import Foundation

enum Genre: String, CaseIterable, Identifiable {
    case music = "Music"
    case cinema = "Cinema"
    case kdrama = "K-Drama"
    case netflix = "Netflix Originals"
    case tv = "TV Series"

    var id: String { rawValue }
}
