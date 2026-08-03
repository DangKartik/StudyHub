import Foundation

/// Shared weighted-grade math — used by `GradesViewModel` for a course's
/// Current Grade.
enum GradeCalculator {
    /// Weighted average across past, scored assessments. An assessment with
    /// no positive weight or maximum score can't contribute a meaningful
    /// percentage, so it's excluded from both the sum and the weight total
    /// rather than counted as a zero. One that hasn't happened yet (or has
    /// no score entered) is excluded the same way — it isn't zero, it just
    /// doesn't count yet.
    static func currentGradePercent(assessments: [Assessment]) -> Double? {
        let graded = assessments.filter {
            $0.weight > 0 && $0.maximumScore > 0 && $0.isPast && $0.score != nil
        }

        let totalWeight = graded.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return nil }

        let contribution = graded.reduce(0.0) { total, assessment in
            total + ((assessment.score ?? 0) / assessment.maximumScore) * assessment.weight
        }

        return (contribution / totalWeight) * 100
    }

    /// Sum of every weight already assigned to a course's assessments —
    /// they share one 100% pool.
    static func totalAssignedWeight(assessments: [Assessment]) -> Double {
        assessments.reduce(0) { $0 + $1.weight }
    }
}
