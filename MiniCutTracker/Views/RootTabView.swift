import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var targetsList: [Targets]

    var body: some View {
        TabView {
            DayView()
                .tabItem { Label("Jour", systemImage: "sun.horizon.fill") }

            TrendView()
                .tabItem { Label("Tendance", systemImage: "chart.xyaxis.line") }

            HistoryView()
                .tabItem { Label("Historique", systemImage: "list.bullet.clipboard") }

            SettingsView()
                .tabItem { Label("Réglages", systemImage: "gearshape.fill") }
        }
        .tint(Theme.cyan)
        .task { ensureTargetsExist() }
    }

    private func ensureTargetsExist() {
        guard targetsList.isEmpty else { return }
        modelContext.insert(Targets())
        try? modelContext.save()
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [DailyEntry.self, Targets.self], inMemory: true)
        .preferredColorScheme(.dark)
}
