# FOLDER STRUCTURE

**Project:** StudyHub  
**Document:** 02_FOLDER_STRUCTURE.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team

---

# 1. Purpose

This document defines the physical folder structure of the StudyHub Xcode project.

A consistent folder structure improves:

- Maintainability
- Discoverability
- Scalability
- Team collaboration
- AI-assisted development

Every engineer and coding agent must follow this structure when creating new files.

---

# 2. Folder Organization Philosophy

StudyHub follows a **Feature-First Architecture**.

Instead of grouping files by type (Views, ViewModels, Models), everything related to one feature lives together.

For example:

❌ Bad

```
Views/
ViewModels/
Models/
Repositories/
```

Finding everything related to Courses requires searching multiple folders.

---

✅ Good

```
Features/
    Courses/
        Views/
        ViewModels/
        Components/
        Repositories/
```

Everything for Courses lives in one place.

This makes navigation significantly easier as the project grows.

---

# 3. High-Level Project Structure

```
StudyHub/
│
├── App/
│
├── Core/
│
├── Features/
│
├── Shared/
│
├── Assets/
│
├── Preview Content/
│
└── Supporting Files/
```

---

# 4. App Folder

The **App** folder contains the application's entry point and global configuration.

```
App/
│
├── StudyHubApp.swift
├── AppCoordinator.swift
├── RootView.swift
├── AppEnvironment.swift
├── AppConfiguration.swift
└── LaunchManager.swift
```

Responsibilities

- Application startup
- Global environment
- Root navigation
- App initialization

---

# 5. Core Folder

The **Core** folder contains code shared across the entire application.

```
Core/
│
├── Models/
├── Services/
├── Repositories/
├── Database/
├── Extensions/
├── Utilities/
├── Constants/
├── Protocols/
├── DesignSystem/
├── Permissions/
└── Errors/
```

Everything inside Core should be reusable.

---

# 6. Core / Models

Contains shared models used throughout the application.

Examples

```
Semester.swift

Course.swift

Lecture.swift

Assignment.swift

Reading.swift

Flashcard.swift

Quote.swift

StudySession.swift

NotificationItem.swift
```

SwiftData models should only exist here.

---

# 7. Core / Services

Contains application services.

Examples

```
CalendarService

NotificationService

GoodNotesService

SearchService

StatisticsService

QuoteService

BackupService

AIService
```

Services communicate with external systems.

---

# 8. Core / Repositories

Repositories manage data access.

Examples

```
CourseRepository

LectureRepository

AssignmentRepository

SemesterRepository

StatisticsRepository

FlashcardRepository
```

Repositories isolate SwiftData from the rest of the app.

---

# 9. Core / Database

Contains everything related to SwiftData.

Examples

```
ModelContainer

ModelConfiguration

MigrationPlan

SampleData

DatabaseSeeder
```

---

# 10. Core / Extensions

Contains Swift extensions.

Examples

```
Color+

Date+

String+

View+

Font+

Array+

URL+

```

Each extension should remain small and focused.

---

# 11. Core / Utilities

General helper utilities.

Examples

```
DateFormatter

FileHelper

GradeCalculator

ReminderScheduler

ReviewScheduler

TimeFormatter
```

Utilities should not contain business logic.

---

# 12. Core / Constants

Application-wide constants.

Examples

```
AppColors

AnimationDurations

LayoutValues

NotificationIdentifiers

DefaultSettings
```

Avoid magic numbers throughout the project.

---

# 13. Core / Protocols

Contains shared protocols.

Examples

```
CalendarServiceProtocol

AIServiceProtocol

RepositoryProtocol

Searchable

Syncable
```

Protocols improve flexibility and testing.

---

# 14. Core / DesignSystem

Contains reusable design definitions.

```
Colors

Typography

Spacing

CornerRadius

Shadows

Icons
```

Every screen should use this design system.

---

# 15. Core / Permissions

Handles permission requests.

Examples

```
Calendar

Notifications

Files

Camera

Photos
```

Permission logic should never exist inside Views.

---

# 16. Core / Errors

Centralized error definitions.

Examples

```
CalendarError

SyncError

StorageError

ImportError

AIError
```

---

# 17. Features Folder

The Features folder contains all user-facing functionality.

```
Features/
│
├── Dashboard/
├── Semesters/
├── Courses/
├── Lectures/
├── Assignments/
├── Readings/
├── Calendar/
├── Flashcards/
├── ActiveRecall/
├── StudyMode/
├── Pomodoro/
├── Statistics/
├── Quotes/
├── Resources/
├── Search/
└── Settings/
```

Each feature owns its implementation.

---

# 18. Standard Feature Structure

Every feature follows the same layout.

```
Feature/
│
├── Views/
├── ViewModels/
├── Components/
├── Repositories/
├── Models/
├── Services/
├── Utilities/
└── Resources/
```

Not every feature requires every folder.

Create folders only when needed.

---

# 19. Example Feature

```
Courses/
│
├── Views/
│   ├── CourseListView.swift
│   ├── CourseCard.swift
│   ├── AddCourseSheet.swift
│   └── EditCourseSheet.swift
│
├── ViewModels/
│   ├── CourseListViewModel.swift
│   └── CourseDetailViewModel.swift
│
├── Components/
│   ├── CourseBadge.swift
│   ├── GradeRing.swift
│   └── CourseHeader.swift
│
├── Utilities/
│   └── CourseValidation.swift
```

Everything remains together.

---

# 20. Shared Folder

The Shared folder contains reusable UI elements.

```
Shared/
│
├── Components/
├── Modifiers/
├── Styles/
├── Layouts/
├── Animations/
├── Previews/
└── Assets/
```

These are not tied to any specific feature.

---

# 21. Shared Components

Examples

```
StudyHubButton

StudyHubCard

SectionHeader

ProgressRing

EmptyStateView

LoadingView

QuoteCard

FloatingAddButton

SearchBar

PrimaryToolbar
```

Every screen should reuse these components.

---

# 22. Shared Modifiers

Reusable ViewModifiers.

Examples

```
CardStyle

PrimaryButtonStyle

GlassBackground

SectionSpacing

NavigationTitleStyle
```

---

# 23. Shared Layouts

Examples

```
DashboardGrid

AdaptiveSidebarLayout

StatisticsGrid

CardGrid
```

---

# 24. Assets Folder

Contains application assets.

```
Assets/
│
├── Colors
├── Icons
├── Images
├── Illustrations
├── Logos
├── Placeholder PDFs
└── App Icons
```

---

# 25. Preview Content

Contains SwiftUI preview data.

```
Preview Content/
│
├── MockCourses
├── MockAssignments
├── MockStatistics
└── MockQuotes
```

Preview data should never be shipped in production builds.

---

# 26. Supporting Files

Contains project configuration.

Examples

```
Info.plist

.entitlements

Launch Screen

Localization Files
```

---

# 27. Naming Conventions

Folders

- PascalCase

Files

- PascalCase

ViewModels

```
CourseViewModel
```

Views

```
CourseListView
```

Repositories

```
CourseRepository
```

Services

```
CalendarService
```

Protocols

```
CalendarServiceProtocol
```

Enums

```
StudyMode
```

---

# 28. File Organization Rules

Each Swift file should contain one primary type.

Example

```
CourseCard.swift

contains

CourseCard
```

Avoid multiple unrelated types in one file.

---

# 29. Scalability Guidelines

The folder structure should comfortably support:

- 50+ features
- Hundreds of Swift files
- Thousands of SwiftData objects
- Future platforms

New features should integrate without restructuring existing folders.

---

# 30. Folder Structure Summary

StudyHub adopts a **Feature-First** folder organization supported by a shared Core and Shared layer.

This structure provides:

- Clear ownership
- Reduced coupling
- Easier navigation
- Better scalability
- Improved testability
- Consistent engineering practices

Every new file added to the project should fit naturally into this hierarchy, ensuring the codebase remains organized and maintainable as StudyHub evolves.