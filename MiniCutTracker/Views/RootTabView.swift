import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var targetsList: [Targets]

    @State private var selectedTab = 0

    /// Launch with `-ScreenshotTour YES` (e.g. via `xcrun simctl launch`) to seed demo
    /// data and auto-cycle through the tabs — used by CI to capture screenshots
    /// without a human driving the simulator.
    private var isScreenshotTour: Bool {
        UserDefaults.standard.bool(forKey: "ScreenshotTour")
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DayView()
                .tabItem { Label("Jour", systemImage: "sun.horizon.fill") }
                .tag(0)

            TrendView()
                .tabItem { Label("Tendance", systemImage: "chart.xyaxis.line") }
                .tag(1)

            HistoryView()
                .tabItem { Label("Historique", systemImage: "list.bullet.clipboard") }
                .tag(2)

            SettingsView()
                .tabItem { Label("Réglages", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .tint(Theme.cyan)
        .task {
            ensureTargetsExist()
            if isScreenshotTour {
                seedDemoDataIfNeeded()
                runScreenshotTour()
            }
        }
    }

    private func ensureTargetsExist() {
        guard targetsList.isEmpty else { return }
        modelContext.insert(Targets())
        try? modelContext.save()
    }

    private func seedDemoDataIfNeeded() {
        let existingCount = (try? modelContext.fetchCount(FetchDescriptor<DailyEntry>())) ?? 0
        guard existingCount == 0 else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let weights: [Double] = [74.2, 74.0, 73.6, 73.8, 73.3, 73.1, 72.9, 73.0, 72.6, 72.4, 72.5, 72.1, 71.9, 72.0]

        for (index, weight) in weights.enumerated() {
            let daysAgo = weights.count - 1 - index
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let entry = DailyEntry(
                date: date,
                weight: weight,
                calories: Int.random(in: 1800...2100),
                proteinGrams: Double.random(in: 120...145),
                fatGrams: Double.random(in: 55...80),
                carbsGrams: Double.random(in: 180...230),
                steps: Int.random(in: 6000...12000),
                strengthTraining: index.isMultiple(of: 3),
                zone2Minutes: index.isMultiple(of: 2) ? Int.random(in: 20...40) : 0
            )
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }

    private func runScreenshotTour() {
        let tourTabs = [1, 2, 3]
        for (offset, tab) in tourTabs.enumerated() {
            let delay = Double(offset + 1) * 3.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                selectedTab = tab
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [DailyEntry.self, Targets.self], inMemory: true)
        .preferredColorScheme(.dark)
}
