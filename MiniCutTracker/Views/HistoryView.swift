import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]

    private var loggedEntries: [DailyEntry] {
        entries.filter { $0.hasAnyData }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("EEE d MMM yyyy")
        return formatter
    }()

    var body: some View {
        NavigationStack {
            Group {
                if loggedEntries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(loggedEntries) { entry in
                            NavigationLink {
                                DayView(initialDate: entry.date)
                            } label: {
                                row(for: entry)
                            }
                            .listRowBackground(Theme.panelBackground)
                        }
                        .onDelete(perform: delete)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 32))
                .foregroundStyle(Theme.textTertiary)
            Text("Aucun jour renseigné")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func row(for entry: DailyEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(Self.dateFormatter.string(from: entry.date).capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(entry.strengthTraining ? "Musculation" : "Repos")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(entry.hasWeight ? String(format: "%.1f kg", entry.weight) : "-- kg")
                    .font(Theme.monoFont(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                Text("\(entry.calories) kcal")
                    .font(Theme.monoFont(size: 12))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(loggedEntries[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [DailyEntry.self, Targets.self], inMemory: true)
        .preferredColorScheme(.dark)
}
