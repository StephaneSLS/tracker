import Foundation
import SwiftData

@Model
final class DailyEntry {
    var date: Date
    var weight: Double
    var calories: Int
    var proteinGrams: Double
    var fatGrams: Double
    var carbsGrams: Double
    var steps: Int
    var strengthTraining: Bool
    var zone2Minutes: Int

    init(
        date: Date,
        weight: Double = 0,
        calories: Int = 0,
        proteinGrams: Double = 0,
        fatGrams: Double = 0,
        carbsGrams: Double = 0,
        steps: Int = 0,
        strengthTraining: Bool = false,
        zone2Minutes: Int = 0
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.weight = weight
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.carbsGrams = carbsGrams
        self.steps = steps
        self.strengthTraining = strengthTraining
        self.zone2Minutes = zone2Minutes
    }

    var hasWeight: Bool { weight > 0 }
    var hasAnyData: Bool {
        weight > 0 || calories > 0 || proteinGrams > 0 || fatGrams > 0
            || carbsGrams > 0 || steps > 0 || strengthTraining || zone2Minutes > 0
    }
}
