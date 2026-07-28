# SIDEBAR NAVIGATION

**Project:** StudyHub  
**Document:** 03_SIDEBAR_NAVIGATION.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

This document defines the sidebar navigation system of StudyHub.

The sidebar is the primary global navigation mechanism that allows users to move between major areas of the application.

It establishes the overall information hierarchy and provides constant orientation.

---

# 2. Navigation Philosophy

StudyHub follows Apple's navigation principles:

- Clear hierarchy.
- Minimal navigation depth.
- Persistent access to major features.
- Context-aware navigation.
- Native iPad interaction patterns.

The sidebar should feel similar to:

- Apple Mail mailbox navigation.
- Apple Notes folder navigation.
- Files app sidebar.
- Settings navigation.

---

# 3. Navigation Structure

The global navigation hierarchy:

```
StudyHub

│
├── Home
│
├── Courses
│
├── Calendar
│
├── Study Mode
│
├── Flashcards
│
├── Statistics
│
├── Resources
│
├── Search
│
└── Settings
```

---

# 4. Sidebar Layout

## Landscape Layout

Default iPad layout:

```
┌──────────────────────┬──────────────────────────┐
│                      │                          │
│  StudyHub            │                          │
│                      │                          │
│  Home                │                          │
│  Courses             │      Main Content       │
│  Calendar            │                          │
│  Study Mode          │                          │
│  Flashcards          │                          │
│  Statistics          │                          │
│  Resources           │                          │
│                      │                          │
│  Settings            │                          │
│                      │                          │
└──────────────────────┴──────────────────────────┘
```

---

# 5. Sidebar Sections

The sidebar is divided into logical groups.

---

## Primary Section

Contains daily academic workflow.

```
Home

Courses

Calendar
```

---

## Learning Section

Contains learning tools.

```
Study Mode

Flashcards

Resources
```

---

## Analytics Section

Contains progress tracking.

```
Statistics
```

---

## System Section

Contains app management.

```
Search

Settings
```

---

# 6. Sidebar Items

---

# Home

## Purpose

The user's academic command center.

---

Destination:

```
HomeDashboardView
```

---

Displays:

- Today's schedule.
- Tasks.
- Deadlines.
- Progress.
- Recommendations.

---

Icon:

```
house.fill
```

---

# Courses

## Purpose

Manage all academic courses.

---

Destination:

```
CoursesView
```

---

Contains:

```
Semester

↓

Course List

↓

Course Detail
```

---

Icon:

```
book.closed.fill
```

---

# Calendar

## Purpose

Unified academic calendar.

---

Contains:

- Apple Calendar events.
- Google Calendar events.
- Lectures.
- Assignments.
- Exams.
- Study sessions.

---

Destination:

```
CalendarView
```

---

Icon:

```
calendar
```

---

# Study Mode

## Purpose

Focused learning workflow.

---

Contains:

- Recommended sessions.
- Active recall.
- Flashcard reviews.
- Pomodoro.

---

Destination:

```
StudyModeView
```

---

Icon:

```
brain.head.profile
```

---

# Flashcards

## Purpose

Dedicated flashcard learning environment.

---

Contains:

- Due cards.
- Decks.
- Review history.
- Statistics.

---

Destination:

```
FlashcardsView
```

---

Icon:

```
rectangle.stack.fill
```

---

# Statistics

## Purpose

Academic analytics.

---

Contains:

- Study hours.
- Progress.
- Accuracy.
- Trends.

---

Destination:

```
StatisticsView
```

---

Icon:

```
chart.bar.fill
```

---

# Resources

## Purpose

Central resource library.

---

Contains:

- PDFs.
- Slides.
- Links.
- Documents.
- Course materials.

---

Destination:

```
ResourcesView
```

---

Icon:

```
folder.fill
```

---

# Search

## Purpose

Universal search.

---

Searchable:

```
Courses

Lectures

Assignments

Notes

Flashcards

Resources
```

---

Destination:

```
SearchView
```

---

Icon:

```
magnifyingglass
```

---

# Settings

## Purpose

Application configuration.

---

Contains:

- Appearance.
- iCloud.
- Calendar.
- Notifications.
- AI settings.
- Integrations.

---

Destination:

```
SettingsView
```

---

Icon:

```
gearshape.fill
```

---

# 7. Sidebar Behavior

## Selection State

The currently selected section is highlighted.

Example:

```
Courses
████████
```

---

Requirements:

- Clear visual indication.
- VoiceOver announces selection.
- Keyboard focus supported.

---

# 8. Sidebar Collapse Behavior

The sidebar supports:

```
Expanded

Collapsed

Hidden
```

---

## Expanded

Default landscape mode.

---

## Collapsed

Shows only icons.

Example:

```
⌂
📚
📅
🧠
📊
⚙
```

---

## Hidden

Portrait mode.

Opened through:

```
Sidebar button
```

---

# 9. Navigation Flow

Example:

```
Sidebar

↓

Courses

↓

Course List

↓

Course Detail

↓

Lecture Detail
```

---

The sidebar only controls major sections.

Internal navigation happens inside each section.

---

# 10. Sidebar Does NOT Contain

The sidebar should NOT contain:

```
Individual Courses

Individual Lectures

Individual Assignments

Individual Flashcards
```

Reason:

These are content objects, not application sections.

---

Correct:

```
Sidebar

Courses

↓

Course List

↓

Course Detail
```

---

Incorrect:

```
Sidebar

CS302

SC2002

SC1005
```

---

# 11. Context Awareness

Sidebar can display badges.

Examples:

Courses:

```
Courses
```

---

Flashcards:

```
Flashcards   42
```

Meaning:

42 cards due for review.

---

Assignments:

```
Calendar   3
```

Meaning:

3 upcoming deadlines.

---

# 12. Quick Create Menu

The sidebar supports a global creation menu.

Access:

```
+
```

---

Create:

```
Course

Assignment

Lecture

Reading

Flashcard

Study Session

Note
```

---

# 13. Sidebar Toolbar

Top area:

```
StudyHub

+
```

---

Bottom area:

```
Settings

Profile
```

---

# 14. Context Menus

Sidebar items support:

Long press / right click:

```
Customize Sidebar

Show/Hide

Reset Layout
```

---

# 15. Drag and Reorder

Future support:

Users can customize sidebar order.

Example:

Move:

```
Flashcards
```

above:

```
Calendar
```

---

Stored using:

```
UserPreferences
```

---

# 16. Keyboard Navigation

Supported shortcuts:

```
⌘ + 1

Home
```

```
⌘ + 2

Courses
```

```
⌘ + 3

Calendar
```

```
⌘ + 4

Study Mode
```

---

Arrow navigation:

```
↑ ↓
```

between sidebar items.

---

# 17. Accessibility

Sidebar supports:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Switch Control.

---

VoiceOver example:

```
Courses selected.
Double tap to open.
```

---

# 18. SwiftUI Implementation

Recommended:

```
Features/

└── Navigation/

    ├── SidebarView.swift

    ├── SidebarItem.swift

    ├── SidebarSection.swift

    └── NavigationRouter.swift
```

---

Implementation:

```swift
NavigationSplitView {

    SidebarView()

} detail: {

    NavigationStack {

        RootContentView()

    }
}
```

---

# 19. Navigation Model

Example:

```swift
enum SidebarDestination {

    case home

    case courses

    case calendar

    case studyMode

    case flashcards

    case statistics

    case resources

    case settings
}
```

---

# 20. State Management

Sidebar state manages:

```
Selected destination

Collapsed state

User customization

Navigation restoration
```

---

# 21. Persistence

Store:

```
Last selected section

Sidebar preferences

Expanded sections
```

Using:

```
SwiftData

UserDefaults
```

---

# 22. iPad Requirements

Sidebar supports:

- iPad Pro.
- iPad Air.
- iPad Mini.
- Stage Manager.
- External keyboard.
- Apple Pencil workflows.

---

# 23. Dark Mode

Sidebar adapts automatically.

Requirements:

- System colors.
- Semantic materials.
- Native vibrancy.

---

# 24. Testing Checklist

```
□ Navigation works

□ Selection state works

□ Portrait mode works

□ Landscape mode works

□ Sidebar collapse works

□ Keyboard shortcuts work

□ VoiceOver works

□ State restoration works

□ Dark Mode works
```

---

# 25. Final Sidebar Architecture

```
Global Navigation

        ↓

Sidebar

        ↓

Feature Sections

        ↓

NavigationStack

        ↓

Detail Pages
```

The sidebar provides the foundation of StudyHub's academic operating system while keeping navigation simple, predictable, and consistent with Apple's iPad design language.