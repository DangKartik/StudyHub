import Foundation

/// The four-button rating both Flashcard review and Active Recall review
/// collect (Phase 4.4) — a single, feature-agnostic type so
/// `SpacedRepetitionScheduler` doesn't need to know about either
/// `FlashcardRating` or `RecallRating`. Each feature's own rating enum
/// converts to this one at the point of grading (see `FlashcardRating
/// .reviewGrade` / `RecallRating.reviewGrade`).
enum ReviewGrade: CaseIterable {
    case again
    case hard
    case good
    case easy

    /// SM-2's original algorithm grades recall quality on a 0-5 scale; this
    /// maps the four-button UI onto that scale. `again` is a full lapse
    /// (0 — "didn't recall it at all"), `hard` is a bare pass (3, the
    /// minimum quality SM-2 treats as "recalled"), `good`/`easy` are
    /// comfortably correct recalls (4/5). This mapping is a judgment call
    /// (SM-2 doesn't itself define a 4-button scheme) but a standard,
    /// widely-used one for adapting SM-2 to Again/Hard/Good/Easy UIs.
    fileprivate var sm2Quality: Int {
        switch self {
        case .again: return 0
        case .hard: return 3
        case .good: return 4
        case .easy: return 5
        }
    }
}

/// SM-2 spaced-repetition scheduling (Phase 4.4, DECISION-038) — the single
/// engine both Flashcards and Active Recall Questions use to turn a rating
/// into updated scheduling state. Pure function: no persistence, no model
/// knowledge — callers (`FlashcardReviewViewModel`/
/// `ActiveRecallReviewViewModel`) read the current state off their model,
/// call `schedule(rating:current:)`, and write the result back.
enum SpacedRepetitionScheduler {
    struct State {
        var easeFactor: Double
        var interval: Double
        var repetitionCount: Int
    }

    struct Result {
        var easeFactor: Double
        var interval: Double
        var repetitionCount: Int
        var nextReviewDate: Date
    }

    /// Classic SM-2: a lapse (quality < 3, i.e. `.again`) resets the
    /// repetition streak and interval back to 1 day; a pass grows the
    /// interval (1 day -> 6 days -> `interval * easeFactor` on later
    /// reps) and advances the streak. Ease factor is adjusted on *every*
    /// review regardless of pass/fail (per the original algorithm) and
    /// floored at 1.3 — SM-2's documented minimum, below which cards spiral
    /// into ever-shorter, unproductive intervals.
    static func schedule(rating: ReviewGrade, current: State, reviewedAt: Date = .now) -> Result {
        let quality = rating.sm2Quality
        var easeFactor = current.easeFactor
        let interval: Double
        let repetitionCount: Int

        if quality < 3 {
            repetitionCount = 0
            interval = 1
        } else {
            switch current.repetitionCount {
            case 0: interval = 1
            case 1: interval = 6
            default: interval = (current.interval * easeFactor).rounded()
            }
            repetitionCount = current.repetitionCount + 1
        }

        let q = Double(quality)
        easeFactor += 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)
        easeFactor = max(1.3, easeFactor)

        let dayInterval = max(1, Int(interval))
        let nextReviewDate = Calendar.current.date(byAdding: .day, value: dayInterval, to: reviewedAt)
            ?? reviewedAt.addingTimeInterval(TimeInterval(dayInterval) * 86400)

        return Result(easeFactor: easeFactor, interval: interval, repetitionCount: repetitionCount, nextReviewDate: nextReviewDate)
    }
}

/// Which due-queue bucket an item (Flashcard/ActiveRecallQuestion) falls
/// into, purely from its `nextReviewDate` (Phase 4.4, DECISION-038) — the
/// shared grouping both features' list views use, replacing the earlier
/// rating-based "Review Again/Never Reviewed/Recently Reviewed" placeholder
/// groupings (which existed only because no real scheduling existed yet).
enum DueQueueSection: CaseIterable, Identifiable, Hashable {
    case dueToday
    case dueSoon
    case future
    case neverReviewed

    var id: Self { self }

    var title: String {
        switch self {
        case .dueToday: return "Due Today"
        case .dueSoon: return "Due Soon"
        case .future: return "Future"
        case .neverReviewed: return "Never Reviewed"
        }
    }

    /// "Soon" = within the 3 days after today — a common SRS default
    /// window for "coming up" versus "not for a while". Not prescribed by
    /// SM-2 itself; a reasonable, documented judgment call.
    static let dueSoonWindowDays = 3

    static func classify(nextReviewDate: Date?, asOf now: Date = .now) -> DueQueueSection {
        guard let nextReviewDate else { return .neverReviewed }

        let calendar = Calendar.current
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        if nextReviewDate < endOfToday { return .dueToday }

        let dueSoonCutoff = calendar.date(byAdding: .day, value: dueSoonWindowDays, to: endOfToday) ?? endOfToday
        if nextReviewDate < dueSoonCutoff { return .dueSoon }

        return .future
    }

    /// Whether an item in this bucket belongs in a "due now" review session
    /// — brand-new (`neverReviewed`) items need learning just as much as
    /// `dueToday` items need reinforcing; `dueSoon`/`future` don't yet.
    var isDueNow: Bool {
        self == .dueToday || self == .neverReviewed
    }
}
