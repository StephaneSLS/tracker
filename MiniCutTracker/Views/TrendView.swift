import SwiftUI
import SwiftData
import Charts

private struct WeightPoint: Identifiable {
    let date: Date
    let weight: Double
    let movingAverage: Double
    var id: Date { date }
}

struct TrendView: View {
    @Query(sort: \DailyEntry.date, order: .forward) private var entries: [DailyEntry]
    @Query private var targetsList: [Targets]

    private var targets: Targets { targetsList.first ?? Targets() }

    private var points: [WeightPoint] {
        let measured = entries.filter { $0.hasWeight }.map { (date: $0.date, weight: $0.weight) }
        let calendar = Calendar.current

        return measured.map { point in
            let windowStart = calendar.date(byAdding: .day, value: -6, to: point.date) ?? point.date
            let window = measured.filter { $0.date >= windowStart && $0.date <= point.date }.map(\.weight)
            let average = window.reduce(0, +) / Double(window.count)
            return WeightPoint(date: point.date, weight: point.weight, movingAverage: average)
        }
    }

    private var latestAverage: Double? { points.last?.movingAverage }

    private var isTrendingDown: Bool? {
        guard points.count >= 2 else { return nil }
        let referenceIndex = max(0, points.count - 8)
        let reference = points[referenceIndex].movingAverage
        guard let latest = latestAverage else { return nil }
        return latest < reference - 0.05
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if points.isEmpty {
                        emptyState
                    } else {
                        chartCard
                        summaryCards
                    }
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Tendance")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 32))
                .foregroundStyle(Theme.textTertiary)
            Text("Pas encore de données de poids")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("POIDS")
                .font(Theme.labelFont)
                .foregroundStyle(Theme.textSecondary)

            Chart {
                ForEach(points) { point in
                    PointMark(x: .value("Date", point.date, unit: .day), y: .value("Poids", point.weight))
                        .foregroundStyle(Theme.textTertiary)
                        .symbolSize(24)
                }
                ForEach(points) { point in
                    LineMark(x: .value("Date", point.date, unit: .day), y: .value("Moyenne 7j", point.movingAverage))
                        .foregroundStyle(Theme.cyan)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                RuleMark(y: .value("Objectif", targets.goalWeight))
                    .foregroundStyle(Theme.amber)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Objectif \(String(format: "%.0f", targets.goalWeight)) kg")
                            .font(Theme.labelFont)
                            .foregroundStyle(Theme.amber)
                    }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine().foregroundStyle(Theme.hairline)
                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Theme.hairline)
                    AxisValueLabel()
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .frame(height: 240)
        }
        .panelStyle()
    }

    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(
                    title: "MOYENNE HEBDO",
                    value: latestAverage.map { String(format: "%.1f kg", $0) } ?? "--"
                )
                statCard(
                    title: "DEPUIS LE DÉPART",
                    value: changeSinceStartText,
                    valueColor: changeColor
                )
            }
            HStack(spacing: 12) {
                statCard(title: "JOURS SUIVIS", value: "\(points.count)")
                trendCard
            }
        }
    }

    private var changeSinceStartText: String {
        guard let latest = latestAverage else { return "--" }
        let delta = latest - targets.startWeight
        return String(format: "%+.1f kg", delta)
    }

    private var changeColor: Color {
        guard let latest = latestAverage else { return Theme.textPrimary }
        return latest <= targets.startWeight ? Theme.cyan : Theme.amber
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TENDANCE")
                .font(Theme.labelFont)
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 6) {
                Image(systemName: trendIconName)
                Text(trendLabel)
                    .font(Theme.displayFont(size: 15))
            }
            .foregroundStyle(trendColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .panelStyle()
    }

    private var trendIconName: String {
        switch isTrendingDown {
        case .some(true): return "arrow.down.right"
        case .some(false): return "arrow.right"
        case .none: return "minus"
        }
    }

    private var trendLabel: String {
        switch isTrendingDown {
        case .some(true): return "En baisse"
        case .some(false): return "Stagnant"
        case .none: return "Pas assez de données"
        }
    }

    private var trendColor: Color {
        switch isTrendingDown {
        case .some(true): return Theme.cyan
        case .some(false): return Theme.amber
        case .none: return Theme.textSecondary
        }
    }

    private func statCard(title: String, value: String, valueColor: Color = Theme.textPrimary) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Theme.labelFont)
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(Theme.monoFont(size: 20, weight: .bold))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .panelStyle()
    }
}

#Preview {
    TrendView()
        .modelContainer(for: [DailyEntry.self, Targets.self], inMemory: true)
        .preferredColorScheme(.dark)
}
