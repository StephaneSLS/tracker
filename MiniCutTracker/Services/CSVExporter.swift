import Foundation

enum CSVExporter {
    /// Builds a CSV file from the given entries (chronological order) and writes it
    /// to a temporary location suitable for the share sheet.
    static func export(entries: [DailyEntry]) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var lines = ["date,poids_kg,calories,proteines_g,lipides_g,glucides_g,pas,musculation,zone2_minutes"]

        let sorted = entries.sorted { $0.date < $1.date }
        for entry in sorted {
            let fields: [String] = [
                dateFormatter.string(from: entry.date),
                String(format: "%.1f", entry.weight),
                String(entry.calories),
                String(format: "%.1f", entry.proteinGrams),
                String(format: "%.1f", entry.fatGrams),
                String(format: "%.1f", entry.carbsGrams),
                String(entry.steps),
                entry.strengthTraining ? "oui" : "non",
                String(entry.zone2Minutes),
            ]
            lines.append(fields.joined(separator: ","))
        }

        let csvString = lines.joined(separator: "\n")
        let fileName = "mini-cut-tracker-export.csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvString.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
