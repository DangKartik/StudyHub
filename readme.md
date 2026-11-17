<h1 align="center">StudyHub</h1>

<p align="center"><b>A native iPad app that keeps a student's semesters, courses, lectures, readings, notes, flashcards, grades and study sessions in one SwiftData graph, so every item knows where it came from.</b></p>

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white">
  <img alt="SwiftUI" src="https://img.shields.io/badge/SwiftUI-0D96F6?logo=swift&logoColor=white">
  <img alt="SwiftData" src="https://img.shields.io/badge/SwiftData-1F6FEB">
  <img alt="iPadOS" src="https://img.shields.io/badge/iPadOS-18%2B-000000?logo=apple&logoColor=white">
  <img alt="dependencies" src="https://img.shields.io/badge/dependencies-none-lightgrey">
</p>

**Topics:** SwiftUI · SwiftData · MVVM · repository pattern · dependency injection · PDFKit · PencilKit · EventKit · UserNotifications · Swift Charts · SM-2 spaced repetition · iPadOS

Most students split their week across a notes app, a PDF reader, a flashcard app, a calendar and a timer, and none of them know about each other. StudyHub models all of it as one connected schema: a note links to the course, lecture or reading it came from; a flashcard and an active-recall question are scheduled by the same SM-2 engine; an exam pushed to Apple Calendar is the same record that feeds the grade and GPA views.

## At a glance

| | |
|---|---|
| **Scope** | 145 Swift files, about 23,000 lines, 17 feature modules, 18 SwiftData models, 15 repositories. Solo project, July to September 2026. |
| **Persistence** | One SwiftData schema with explicit delete rules: deleting a semester cascades to its courses, sessions and statistics, while deleting a reading *nullifies* the link on its notes so they survive. |
| **Architecture** | SwiftUI view → `@Observable` view model → repository protocol → SwiftData. A single `AppContainer` builds every repository and service once and injects them, so no view touches a `ModelContext` directly. |
| **System frameworks** | PDFKit and PencilKit for reading and annotation, EventKit for calendar and reminder sync, UserNotifications for local reminders, Swift Charts for analytics. No third-party packages. |
| **Status** | Core features complete; development paused. Not on the App Store. |

## Features

- **Academic structure.** Semesters, courses, lectures, assignments, readings and resources, with attachments and per-course colours.
- **PDF reading.** A PDFKit reader with Apple Pencil markup (Pencil draws, fingers scroll), in-document search, outline navigation, bookmarks, and reading position and progress restored on reopen.
- **Notes.** Markdown notes with tags (case-insensitive, de-duplicated), each linkable to a course, lecture or reading.
- **Flashcards and active recall.** Two review modes sharing one SM-2 scheduler. The four-button rating (Again, Hard, Good, Easy) maps onto SM-2's 0–5 quality scale, and a daily notification reports how many items are due.
- **Study Mode.** A session workspace that puts a reading, its notes, flashcards and recall questions side by side, with a Pomodoro timer (25, 45, 60, 90 minutes or custom) and an end-of-session summary.
- **Grades and GPA.** Weighted assessment grades per course and a credit-weighted GPA on a 5.0 scale; Pass/Fail courses count toward credits but never toward GPA.
- **Calendar sync.** Assignments and exams are written to a dedicated StudyHub calendar and reminders list; lectures can be imported from any existing calendar, which stays the source of truth.
- **Analytics and search.** Study-time and grade charts, and one global search across notes, flashcards, questions, readings and courses, including tags.

## Architecture

```
Semester ─┬─ Course ─┬─ Lecture
          │          ├─ Assignment ── Attachment
          │          ├─ Assessment
          │          ├─ Reading ─┬─ PDFProgress, Bookmark
          │          │           └─ Note (nullify on delete) ── Flashcard
          │          └─ Resource
          ├─ StudySession
          └─ StatisticsSnapshot
```

```
SwiftUI views ──▶ view models (@Observable) ──▶ repository protocols ──▶ SwiftData ModelContext
                         │
                         └──▶ services: PDFService, CalendarSyncService, NotificationManager,
                                        SpacedRepetitionScheduler (pure function)
```

Design decisions:

- **Protocols at every boundary.** Each repository and service is used through a protocol (`NoteRepositoryProtocol`, `CalendarSyncServiceProtocol`, `NotificationSchedulingProtocol`), so a view model can be given an in-memory fake.
- **Framework imports are contained.** `CalendarSyncService` is the only file that imports EventKit; it hands the rest of the app plain structs, so nothing above it depends on `EKEvent`.
- **The scheduler is a pure function.** `SpacedRepetitionScheduler.schedule(rating:current:)` takes the current ease factor, interval and repetition count and returns the next state and review date. It knows nothing about flashcards, questions or persistence.
- **Idempotent notifications.** Every notification uses an identifier derived from its model's UUID, so rescheduling is cancel-then-add with no lookup table, and reminders for dates already past are skipped instead of firing immediately.

## Run it

Requires Xcode 26 or later. Open `StudyHub/StudyHub.xcodeproj`, choose an iPad simulator or device running iPadOS 18 or later, and run the `StudyHub` scheme. There are no packages to resolve.

Calendar, reminder and notification features ask for permission on first use. The store is configured for CloudKit (`cloudKitDatabase: .automatic`), but without an iCloud container provisioned for your team it runs as a local store.

## Repository layout

| Path | Contents |
|---|---|
| `StudyHub/StudyHub/App` | entry point, `AppContainer` (dependency wiring), root view |
| `StudyHub/StudyHub/Core/Models` | the 18 SwiftData models and shared enums |
| `StudyHub/StudyHub/Core/Repositories` | one repository per aggregate, each behind a protocol |
| `StudyHub/StudyHub/Core/Services` | PDF, calendar sync, notifications, SM-2 scheduler |
| `StudyHub/StudyHub/Core/Utilities` | grade and GPA calculators, file import, formatters |
| `StudyHub/StudyHub/Features` | one folder per screen: views and their view models |
| `StudyHub/StudyHub/Shared/Components` | PDF viewer and Pencil tools, pickers, forms, empty states |

## Limitations and what I would do next

- **No automated tests.** The calculators and the scheduler are pure functions and the repositories sit behind protocols, so unit tests are straightforward to add; they are the first thing I would write.
- **iCloud sync is not provisioned**, so data stays on one device.
- **Not hardened for release.** `ModelContainerFactory` stops the app if the store cannot open, and there is no schema migration plan yet.
- **iPad only.** The layout is built around `NavigationSplitView` and Pencil input; an iPhone layout would need its own navigation.

---

Personal project by Kartik Dang · [GitHub](https://github.com/DangKartik) · [LinkedIn](https://www.linkedin.com/in/dangkartik/)
