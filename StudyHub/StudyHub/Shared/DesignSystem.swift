import SwiftUI

/// Phase 5 (Polish & UX) — shared visual constants so every "card" surface,
/// badge/pill, and section in the app draws from the same design language
/// instead of each screen picking its own corner radius/padding/shadow.
/// Additive only: existing screens are updated to reference these instead
/// of their own hardcoded numbers, nothing about their structure changes.
enum StudyHubMetrics {
    /// Standard corner radius for card-style containers (Home tiles, Course
    /// Page sections, Analytics cards, summary cards).
    static let cardCornerRadius: CGFloat = 14

    /// Larger radius reserved for full-size flip cards (Flashcard/Active
    /// Recall review) — intentionally distinct from `cardCornerRadius`
    /// since those are a different, larger-scale surface.
    static let flipCardCornerRadius: CGFloat = 20

    /// Horizontal/vertical padding for small status/count badges (exam
    /// "in N days" pill, due-count pills) — one shared shape for anything
    /// that reads as "a small badge," distinct from tag chips below.
    static let badgeHorizontalPadding: CGFloat = 10
    static let badgeVerticalPadding: CGFloat = 5

    /// Horizontal/vertical padding for compact tag chips (Notes/Flashcards/
    /// Active Recall tag lists) — smaller than a status badge since many
    /// appear side-by-side in one row.
    static let chipHorizontalPadding: CGFloat = 6
    static let chipVerticalPadding: CGFloat = 2
}

/// Small icon-badge + title combo used as section headers across Home,
/// Course Page, and Study Mode — a consistent "eyebrow" treatment instead
/// of each screen writing its own bare `Text(title).font(.title2.bold())`.
/// Extracted after writing the same private helper three times over.
struct SectionHeaderLabel: View {
    let title: String
    let icon: String
    var tint: Color = .accentColor

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint.opacity(0.8))
                .frame(width: 26, height: 26)
                .background(tint.opacity(0.14), in: Circle())
            Text(title)
                .font(.title2.weight(.bold))
        }
    }
}

/// A smaller tinted-icon header for native `List`/`Form` section headers
/// specifically — `SectionHeaderLabel`'s 26pt circle badge is sized for a
/// full-page custom section title, which reads as oversized inside a
/// compact List/Form section header area. Extracted from Courses' list
/// after Settings needed the identical thing (plain gray "Profile"/
/// "Appearance"/"Calendar"/"About" text, the one place still without an
/// icon once every List elsewhere picked one up).
struct ListSectionHeaderLabel: View {
    let title: String
    let icon: String
    var tint: Color = .accentColor

    var body: some View {
        Label {
            Text(title)
        } icon: {
            // Full-saturation color reads as too vivid/neon next to a
            // muted gray section-header label — softened rather than left
            // at full strength like an interactive accent color would be.
            Image(systemName: icon)
                .foregroundStyle(tint.opacity(0.8))
        }
    }
}

/// "See All ›" style — text first, icon trailing — for the small
/// navigation links that close out a section header, instead of a bare
/// `Text("See All")` with no visual cue that it pushes somewhere.
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
                .font(.caption.weight(.semibold))
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}

/// Shared tint per priority/status level — used by both the Assignments
/// list (row dot + badge) and the New/Edit Assignment form (Priority row
/// icon) so a "Critical" assignment reads the same red wherever it shows up.
extension Priority {
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
}

/// Shared icon/tint per attachment/resource type — used everywhere a PDF,
/// Image, or Link needs a badge or icon: Notes/Readings/Lectures/
/// Assignments' attachment rows, and the Resources list + form, mirroring
/// `Priority.color`/`AssignmentStatus.color` above.
extension AttachmentKind {
    var icon: String {
        switch self {
        case .pdf: return "doc.richtext"
        case .link: return "link"
        case .image: return "photo"
        }
    }

    var color: Color {
        switch self {
        case .pdf: return .red
        case .link: return .blue
        case .image: return .green
        }
    }
}

/// Small tinted-icon circle for an attachment row — same visual language as
/// every other icon badge in the app (`CourseRowView`, `ResourceRowView`,
/// `AssignmentRowView`), just sized down for a compact attachment row
/// instead of a full list row. Previously every attachment row (Notes,
/// Lectures, Assignments) used a bare `.secondary`-tinted SF Symbol with no
/// background — easy to miss/read as "no icon at all" next to the vivid
/// tinted badges the rest of the app uses.
struct AttachmentIconBadge: View {
    let kind: AttachmentKind?
    var size: CGFloat = 28

    var body: some View {
        Image(systemName: kind?.icon ?? "paperclip")
            .font(.caption.weight(.semibold))
            .foregroundStyle((kind?.color ?? .secondary).opacity(0.85))
            .frame(width: size, height: size)
            .background((kind?.color ?? .secondary).opacity(0.14), in: Circle())
    }
}

extension AssessmentKind {
    var color: Color {
        switch self {
        case .quiz: return .purple
        case .exam: return .orange
        }
    }
}

extension LetterGrade {
    /// Grade-quality tint for the Grades page's hero card — reads at a
    /// glance the same way a real gradebook color-codes grade bands, not
    /// just decoration.
    var tintColor: Color {
        switch self {
        case .aPlus, .a, .aMinus: return .green
        case .bPlus, .b, .bMinus: return .blue
        // Plain `.yellow` reads fine as a translucent wash but has almost
        // no contrast as text on top of that same wash — a darker
        // goldenrod keeps the "yellow/C-tier" identity while staying
        // legible at label size.
        case .cPlus, .c: return Color(red: 0.72, green: 0.53, blue: 0.05)
        case .dPlus, .d: return .orange
        case .f: return .red
        case .p: return .green
        }
    }
}

extension AssignmentStatus {
    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .submitted: return .teal
        case .completed: return .green
        case .overdue: return .red
        }
    }
}

extension View {
    /// The single "card" elevation used across Home/Course Page/Analytics —
    /// a soft, barely-there shadow so surfaces read as raised without
    /// looking heavy, matching the flatter, subtler look of first-party
    /// iPadOS apps.
    func studyHubCardShadow() -> some View {
        shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
