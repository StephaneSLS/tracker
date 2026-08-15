import SwiftUI
import SwiftData

struct DayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]
    @Query private var targetsList: [Targets]

    @State private var selectedDate: Date
    @State private var currentEntry: DailyEntry?

    init(initialDate: Date = .now) {
        _selectedDate = State(initialValue: Calendar.current.startOfDay(for: initialDate))
    }

    private var targets: Targets { targetsList.first ?? Targets() }
    private var isToday: Bool { Calendar.current.isDateInToday(selectedDate) }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                if let entry = currentEntry {
                    VStack(spacing: 20) {
                        dateNavigator
                        weightSection(entry: entry)
                        nutritionSection(entry: entry)
                        activitySection(entry: entry)
                    }
                    .padding(16)
                } else {
                    ProgressView()
                        .padding(.top, 80)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Mini-Cut Tracker")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task(id: selectedDate) { loadEntry(for: selectedDate) }
    }

    // MARK: - Sections

    private var dateNavigator: some View {
        HStack {
            Button {
                changeDay(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Jour précédent")

            Spacer()

            VStack(spacing: 2) {
                Text(Self.dateFormatter.string(from: selectedDate).capitalized)
                    .font(Theme.displayFont(size: 17))
                    .foregroundStyle(Theme.textPrimary)
                if !isToday {
                    Button("Revenir à aujourd'hui") {
                        withAnimation { selectedDate = Calendar.current.startOfDay(for: .now) }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.cyan)
                }
            }

            Spacer()

            Button {
                changeDay(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("Jour suivant")
            .disabled(isToday)
            .opacity(isToday ? 0.3 : 1)
        }
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(Theme.cyan)
    }

    private func weightSection(entry: DailyEntry) -> some View {
        VStack(spacing: 12) {
            WeightTapeView(weight: entry.weight, startWeight: targets.startWeight, goalWeight: targets.goalWeight)

            HStack {
                Text("Poids du matin")
                    .font(Theme.labelFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                TextField("0.0", value: doubleBinding(entry: entry, \.weight), format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(Theme.monoFont(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 80)
                    .accessibilityLabel("Saisir le poids en kilogrammes")
                Text("kg")
                    .font(Theme.monoFont(size: 14))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .panelStyle()
    }

    private func nutritionSection(entry: DailyEntry) -> some View {
        VStack(spacing: 18) {
            NutrientField(
                label: "Calories",
                value: intBinding(entry: entry, \.calories),
                target: Double(targets.dailyCalories),
                unit: "kcal",
                color: Theme.cyan,
                isInteger: true
            )
            NutrientField(
                label: "Protéines",
                value: doubleBinding(entry: entry, \.proteinGrams),
                target: targets.proteinGrams,
                unit: "g",
                color: Theme.amber,
                isInteger: false
            )
            NutrientField(
                label: "Lipides",
                value: doubleBinding(entry: entry, \.fatGrams),
                target: targets.fatGrams,
                unit: "g",
                color: Theme.coral,
                isInteger: false
            )
            NutrientField(
                label: "Glucides",
                value: doubleBinding(entry: entry, \.carbsGrams),
                target: targets.carbsGrams,
                unit: "g",
                color: Theme.violet,
                isInteger: false
            )
            NutrientField(
                label: "Pas",
                value: intBinding(entry: entry, \.steps),
                target: Double(targets.dailySteps),
                unit: "pas",
                color: Theme.cyan,
                isInteger: true
            )
        }
        .panelStyle()
    }

    private func activitySection(entry: DailyEntry) -> some View {
        VStack(spacing: 16) {
            Toggle(isOn: Binding(
                get: { entry.strengthTraining },
                set: { entry.strengthTraining = $0; persist() }
            )) {
                Label("Séance de musculation", systemImage: "dumbbell.fill")
                    .foregroundStyle(Theme.textPrimary)
            }
            .tint(Theme.cyan)
            .accessibilityLabel("Séance de musculation aujourd'hui")

            Divider().overlay(Theme.hairline)

            HStack {
                Label("Zone 2", systemImage: "heart.fill")
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                TextField("0", value: intBinding(entry: entry, \.zone2Minutes), format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(Theme.monoFont(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 60)
                    .accessibilityLabel("Minutes en zone 2")
                Text("min")
                    .font(Theme.monoFont(size: 14))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .panelStyle()
    }

    // MARK: - Data

    private func loadEntry(for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            currentEntry = existing
        } else {
            let created = DailyEntry(date: day)
            modelContext.insert(created)
            try? modelContext.save()
            currentEntry = created
        }
    }

    private func changeDay(by offset: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) else { return }
        guard newDate <= Calendar.current.startOfDay(for: .now) else { return }
        withAnimation { selectedDate = newDate }
    }

    private func persist() {
        try? modelContext.save()
    }

    private func doubleBinding(entry: DailyEntry, _ keyPath: ReferenceWritableKeyPath<DailyEntry, Double>) -> Binding<Double> {
        Binding(
            get: { entry[keyPath: keyPath] },
            set: { newValue in
                entry[keyPath: keyPath] = newValue
                persist()
            }
        )
    }

    private func intBinding(entry: DailyEntry, _ keyPath: ReferenceWritableKeyPath<DailyEntry, Int>) -> Binding<Double> {
        Binding(
            get: { Double(entry[keyPath: keyPath]) },
            set: { newValue in
                entry[keyPath: keyPath] = Int(newValue.rounded())
                persist()
            }
        )
    }
}

/// One editable macro/steps row: label, numeric field, target readout and gauge bar.
private struct NutrientField: View {
    let label: String
    @Binding var value: Double
    let target: Double
    let unit: String
    let color: Color
    var isInteger: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label.uppercased())
                    .font(Theme.labelFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                TextField("0", value: $value, format: .number)
                    .keyboardType(isInteger ? .numberPad : .decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(Theme.monoFont(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 64)
                    .accessibilityLabel("Saisir \(label)")
                Text("/ \(Int(target)) \(unit)")
                    .font(Theme.monoFont(size: 13))
                    .foregroundStyle(Theme.textTertiary)
            }
            GaugeBar(value: value, target: target, color: color)
                .frame(height: 14)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DayView()
        .modelContainer(for: [DailyEntry.self, Targets.self], inMemory: true)
        .preferredColorScheme(.dark)
}
