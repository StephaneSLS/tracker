import SwiftUI

/// Signature instrument: a vertical altimeter-style tape that scrolls to the
/// current weight, with a fixed readout window at the centre, an amber
/// dashed marker for the goal weight, and a dimmer marker for the start weight.
struct WeightTapeView: View {
    let weight: Double
    let startWeight: Double
    let goalWeight: Double

    private let pixelsPerKg: CGFloat = 42
    private let viewportHeight: CGFloat = 240
    private let tickSpan: Double = 5 // kg shown above and below the reference value

    private var hasWeight: Bool { weight > 0 }
    private var referenceValue: Double { hasWeight ? weight : startWeight }

    /// Tick positions expressed in tenths of a kilogram to avoid floating point
    /// drift when generating the ladder.
    private var tickValuesTenths: [Int] {
        let centerTenths = Int((referenceValue * 10).rounded())
        let spanTenths = Int(tickSpan * 10)
        return Array(stride(from: centerTenths - spanTenths, through: centerTenths + spanTenths, by: 2))
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.panelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Theme.hairline, lineWidth: 1)
                )

            GeometryReader { geo in
                let centerY = geo.size.height / 2
                ZStack {
                    ForEach(tickValuesTenths, id: \.self) { tenths in
                        tickRow(tenths: tenths, centerY: centerY)
                    }
                    markerLine(
                        value: goalWeight,
                        centerY: centerY,
                        color: Theme.amber,
                        dashed: true,
                        label: "OBJ"
                    )
                    markerLine(
                        value: startWeight,
                        centerY: centerY,
                        color: Theme.textTertiary,
                        dashed: false,
                        label: "DÉPART"
                    )
                }
                .animation(.spring(response: 0.55, dampingFraction: 0.82), value: weight)
            }
            .frame(height: viewportHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .mask(edgeFadeMask)

            centerReadout
                .allowsHitTesting(false)
        }
        .frame(height: viewportHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Poids du matin")
        .accessibilityValue(
            hasWeight
                ? String(format: "%.1f kilogrammes", weight)
                : "Non renseigné"
        )
    }

    private func yPosition(for value: Double, centerY: CGFloat) -> CGFloat {
        centerY - CGFloat(value - referenceValue) * pixelsPerKg
    }

    @ViewBuilder
    private func tickRow(tenths: Int, centerY: CGFloat) -> some View {
        let value = Double(tenths) / 10
        let isMajor = tenths % 10 == 0
        let y = yPosition(for: value, centerY: centerY)

        HStack(spacing: 8) {
            Rectangle()
                .fill(Theme.textSecondary.opacity(isMajor ? 0.85 : 0.35))
                .frame(width: isMajor ? 22 : 12, height: isMajor ? 2 : 1)

            if isMajor {
                Text(String(format: "%.0f", value))
                    .font(Theme.monoFont(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .frame(width: 90, alignment: .leading)
        .position(x: 55, y: y)
    }

    @ViewBuilder
    private func markerLine(value: Double, centerY: CGFloat, color: Color, dashed: Bool, label: String) -> some View {
        let y = yPosition(for: value, centerY: centerY)
        HStack(spacing: 6) {
            HorizontalLine()
                .stroke(color, style: StrokeStyle(lineWidth: 2, dash: dashed ? [5, 4] : []))
                .frame(width: 150, height: 2)
            Text(label)
                .font(Theme.labelFont)
                .foregroundStyle(color)
                .fixedSize()
        }
        .frame(width: 210, alignment: .leading)
        .position(x: 165, y: y)
    }

    private var centerReadout: some View {
        VStack(spacing: 2) {
            Text(hasWeight ? String(format: "%.1f", weight) : "--.-")
                .font(Theme.monoFont(size: 44, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .contentTransition(.numericText())
            Text("KG")
                .font(Theme.labelFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.panelBackgroundElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.cyan.opacity(0.7), lineWidth: 1.5)
        )
    }

    private var edgeFadeMask: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.12),
                .init(color: .black, location: 0.88),
                .init(color: .clear, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

/// A single horizontal line spanning its frame, used with `.stroke` for solid or dashed markers.
private struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        WeightTapeView(weight: 72.4, startWeight: 74, goalWeight: 70)
        WeightTapeView(weight: 0, startWeight: 74, goalWeight: 70)
    }
    .padding()
    .background(Theme.background)
}
