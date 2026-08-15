import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var targetsList: [Targets]
    @Query(sort: \DailyEntry.date, order: .forward) private var entries: [DailyEntry]

    @State private var exportURL: URL?
    @State private var isShowingShareSheet = false

    private var targets: Targets? { targetsList.first }

    var body: some View {
        NavigationStack {
            Form {
                if let targets {
                    Section {
                        numberRow(title: "Calories", value: intBinding(targets, \.dailyCalories), unit: "kcal")
                        numberRow(title: "Protéines", value: doubleBinding(targets, \.proteinGrams), unit: "g")
                        numberRow(title: "Lipides", value: doubleBinding(targets, \.fatGrams), unit: "g")
                        numberRow(title: "Glucides", value: doubleBinding(targets, \.carbsGrams), unit: "g")
                        numberRow(title: "Pas", value: intBinding(targets, \.dailySteps), unit: "pas")
                    } header: {
                        Text("Cibles quotidiennes")
                    }

                    Section {
                        numberRow(title: "Poids de départ", value: doubleBinding(targets, \.startWeight), unit: "kg")
                        numberRow(title: "Poids objectif", value: doubleBinding(targets, \.goalWeight), unit: "kg")
                    } header: {
                        Text("Programme")
                    }
                }

                Section {
                    Button {
                        exportCSV()
                    } label: {
                        Label("Exporter en CSV", systemImage: "square.and.arrow.up")
                    }
                    .disabled(entries.isEmpty)
                } header: {
                    Text("Données")
                } footer: {
                    Text("Exporte tous les jours renseignés au format CSV via la feuille de partage iOS.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .tint(Theme.cyan)
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .task { ensureTargetsExist() }
            .sheet(isPresented: $isShowingShareSheet) {
                if let exportURL {
                    ShareSheet(items: [exportURL])
                }
            }
        }
    }

    private func numberRow(title: String, value: Binding<Double>, unit: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(Theme.monoFont(size: 15))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 90)
                .accessibilityLabel(title)
            Text(unit)
                .font(.system(size: 13))
                .foregroundStyle(Theme.textTertiary)
        }
        .listRowBackground(Theme.panelBackground)
    }

    private func ensureTargetsExist() {
        guard targetsList.isEmpty else { return }
        modelContext.insert(Targets())
        try? modelContext.save()
    }

    private func exportCSV() {
        guard let url = CSVExporter.export(entries: entries) else { return }
        exportURL = url
        isShowingShareSheet = true
    }

    private func doubleBinding(_ targets: Targets, _ keyPath: ReferenceWritableKeyPath<Targets, Double>) -> Binding<Double> {
        Binding(
            get: { targets[keyPath: keyPath] },
            set: { newValue in
                targets[keyPath: keyPath] = newValue
                try? modelContext.save()
            }
        )
    }

    private func intBinding(_ targets: Targets, _ keyPath: ReferenceWritableKeyPath<Targets, Int>) -> Binding<Double> {
        Binding(
            get: { Double(targets[keyPath: keyPath]) },
            set: { newValue in
                targets[keyPath: keyPath] = Int(newValue.rounded())
                try? modelContext.save()
            }
        )
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailyEntry.self, Targets.self], inMemory: true)
        .preferredColorScheme(.dark)
}
