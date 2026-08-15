import SwiftUI

/// Track + coloured fill + target tick, shared by the read-only gauge and the
/// editable nutrient rows on the day screen.
struct GaugeBar: View {
    let value: Double
    let target: Double
    let color: Color

    private var scaleMax: Double {
        max(max(value, target) * 1.15, 1)
    }

    private var fillFraction: Double {
        guard scaleMax > 0 else { return 0 }
        return min(value / scaleMax, 1)
    }

    private var targetFraction: Double {
        guard scaleMax > 0 else { return 0 }
        return min(target / scaleMax, 1)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Theme.trackBackground)

                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.55), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(4, width * fillFraction))
                    .animation(.spring(response: 0.5, dampingFraction: 0.85), value: value)

                Rectangle()
                    .fill(Theme.amber)
                    .frame(width: 2)
                    .offset(x: max(0, width * targetFraction - 1))
            }
        }
    }
}

/// A horizontal instrument-style gauge: label, read-only value/target readout
/// and a `GaugeBar` — used on the trend and history screens.
struct InstrumentGaugeView: View {
    let label: String
    let value: Double
    let target: Double
    let unit: String
    let color: Color
    var valueFormatter: (Double) -> String = { String(format: "%.0f", $0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label.uppercased())
                    .font(Theme.labelFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(valueFormatter(value)) / \(valueFormatter(target)) \(unit)")
                    .font(Theme.monoFont(size: 13))
                    .foregroundStyle(Theme.textPrimary)
            }

            GaugeBar(value: value, target: target, color: color)
                .frame(height: 14)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(valueFormatter(value)) sur \(valueFormatter(target)) \(unit)")
    }
}

#Preview {
    VStack(spacing: 24) {
        InstrumentGaugeView(label: "Calories", value: 1450, target: 2000, unit: "kcal", color: Theme.cyan)
        InstrumentGaugeView(label: "Protéines", value: 140, target: 133, unit: "g", color: Theme.amber)
        InstrumentGaugeView(label: "Pas", value: 6200, target: 10000, unit: "pas", color: Theme.cyan)
    }
    .padding()
    .background(Theme.background)
}
