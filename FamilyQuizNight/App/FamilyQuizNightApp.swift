import SwiftUI

@main
struct FamilyQuizNightApp: App {
    @StateObject private var game = GameState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(minWidth: 1280, minHeight: 720)
                .environmentObject(game)
        }
    }
}
