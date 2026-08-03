import Foundation

struct GPAResult {
    var gpa: Double?
    var totalCredits: Int
}

/// Credit-weighted GPA on NTU's 5.0-point scale (see `LetterGrade`).
enum GPACalculator {
    /// Only counts courses with a positive `credits` value, a
    /// `finalLetterGrade` already set, and not marked Pass/Fail — a
    /// Pass/Fail course counts toward credits completed on a real
    /// transcript, never toward GPA, so it's excluded here entirely
    /// regardless of whether it's a Pass or a Fail.
    static func gpa(for courses: [Course]) -> GPAResult {
        let graded = courses.compactMap { course -> (LetterGrade, Int)? in
            guard course.credits > 0,
                  !course.isPassFail,
                  let raw = course.finalLetterGrade,
                  let letter = LetterGrade(rawValue: raw) else { return nil }
            return (letter, course.credits)
        }

        let totalCredits = graded.reduce(0) { $0 + $1.1 }
        guard totalCredits > 0 else { return GPAResult(gpa: nil, totalCredits: 0) }

        let totalPoints = graded.reduce(0.0) { $0 + $1.0.gradePoints * Double($1.1) }
        return GPAResult(gpa: totalPoints / Double(totalCredits), totalCredits: totalCredits)
    }
}
