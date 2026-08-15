import SwiftUI
import SwiftData

@main
struct MiniCutTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [DailyEntry.self, Targets.self])
    }
}
