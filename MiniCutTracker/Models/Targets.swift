import Foundation
import SwiftData

/// Singleton model holding the user's configurable daily targets and program bounds.
@Model
final class Targets {
    var dailyCalories: Int
    var proteinGrams: Double
    var fatGrams: Double
    var carbsGrams: Double
    var dailySteps: Int
    var startWeight: Double
    var goalWeight: Double

    init(
        dailyCalories: Int = 2000,
        proteinGrams: Double = 133,
        fatGrams: Double = 70,
        carbsGrams: Double = 210,
        dailySteps: Int = 10_000,
        startWeight: Double = 74,
        goalWeight: Double = 70
    ) {
        self.dailyCalories = dailyCalories
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.carbsGrams = carbsGrams
        self.dailySteps = dailySteps
        self.startWeight = startWeight
        self.goalWeight = goalWeight
    }
}
