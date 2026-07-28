# STATE MANAGEMENT

**Project:** StudyHub  
**Document:** 08_STATE_MANAGEMENT.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team

---

# 1. Purpose

This document defines the state management architecture used throughout StudyHub.

State management determines:

- How application data flows through the app
- How Views receive updates
- How user interactions modify data
- How shared application state is handled
- How temporary UI state is managed

The goals are:

- Predictable data flow
- Minimal complexity
- High performance
- SwiftUI-native implementation
- Easy debugging
- Scalable architecture

---

# 2. State Management Philosophy

StudyHub follows one fundamental principle:

> State should live at the lowest level where it is needed, but no lower.

This prevents:

- Unnecessary global state
- Complex dependencies
- Difficult debugging
- Excessive UI updates

---

# 3. State Architecture Overview

StudyHub uses:

- Swift Observation Framework
- SwiftUI State Management
- MVVM architecture
- Dependency Injection
- Repository-driven data flow

Architecture:

```
User Interaction

↓

SwiftUI View

↓

ViewModel

↓

Repository

↓

SwiftData

↓

Observable State Update

↓

View Refresh
```

---

# 4. State Categories

StudyHub has four categories of state.

```
Application State

↓

Feature State

↓

View State

↓

Transient State
```

Each category has different ownership rules.

---

# 5. Application State

Application state is data required across multiple features.

Examples:

- Active semester
- User preferences
- Theme
- Sync status
- Account status
- Permissions

Application state should be small.

---

# 6. Application State Manager

Global application state is managed through dedicated managers.

Examples:

```
AppState

ThemeManager

SettingsManager

SyncManager

SessionManager
```

These are injected through the App Container.

---

# 7. AppState

AppState contains global information about the current application session.

Example responsibilities:

- Current user state
- Active semester
- Application readiness
- Global alerts
- Navigation state

AppState should not contain feature-specific data.

---

# 8. Active Semester State

The active semester is a critical global state.

Example:

```
Current Semester

↓

Courses

↓

Assignments

↓

Statistics
```

Changing the active semester updates all dependent screens.

---

# 9. Feature State

Feature state belongs to individual modules.

Examples:

Courses:

- Selected course
- Course filters
- Course sorting

Calendar:

- Selected date
- Calendar view mode

Flashcards:

- Current deck
- Review progress

Feature state belongs inside feature ViewModels.

---

# 10. ViewModel State

ViewModels own presentation state.

Examples:

```
CourseListViewModel

selectedCourse

searchText

isLoading

errorMessage

courses
```

The View only observes this state.

---

# 11. View State

View state represents temporary UI conditions.

Examples:

- Sheet presentation
- Alert visibility
- Expanded sections
- Scroll position
- Selected tab

View state belongs directly inside SwiftUI Views.

---

# 12. Transient State

Transient state exists temporarily.

Examples:

- Text being typed
- Animation progress
- Drag position
- Current gesture state

Transient state should never be persisted.

---

# 13. Swift Observation Framework

StudyHub uses the modern Observation framework.

Preferred:

```
@Observable
```

Avoid creating unnecessary:

```
ObservableObject
```

unless required by older APIs.

---

# 14. Observable Objects

Objects that need UI updates should be observable.

Examples:

```
DashboardViewModel

CourseViewModel

CalendarViewModel

FlashcardViewModel
```

---

# 15. View State Ownership Rules

The following rules apply.

A View owns:

- UI-only state

A ViewModel owns:

- Feature logic state

A Repository owns:

- Persistent data access

SwiftData owns:

- Stored application data

---

# 16. Example State Flow

Creating an Assignment:

```
User taps +

↓

AssignmentView

↓

AssignmentViewModel

↓

AssignmentRepository

↓

SwiftData

↓

Repository updates

↓

ViewModel refreshes

↓

UI updates
```

The View never modifies data directly.

---

# 17. State Updates

State updates should be predictable.

Preferred flow:

```
Action

↓

Intent

↓

ViewModel Method

↓

Repository Operation

↓

State Update
```

Avoid modifying multiple unrelated states from Views.

---

# 18. Async State Handling

All asynchronous operations must represent their state.

Example:

```
enum LoadingState {

idle

loading

success

failure

}
```

Used for:

- AI generation
- Calendar sync
- Cloud sync
- PDF loading

---

# 19. Loading States

Every major feature should handle:

- Initial loading
- Refreshing
- Empty state
- Error state
- Success state

Never leave users with a blank screen.

---

# 20. Error State Management

Errors should be stored as state.

Example:

```
errorMessage

showErrorAlert
```

The ViewModel decides when an error occurs.

The View decides how it appears.

---

# 21. Navigation State

Navigation state includes:

- Selected sidebar item
- Navigation path
- Presented sheets
- Presented popovers

Navigation state belongs to the Navigation Manager.

---

# 22. Sheet State

Sheets should be controlled using explicit state.

Examples:

```
showAddCourseSheet

showEditAssignmentSheet

showSettingsSheet
```

Avoid complicated presentation chains.

---

# 23. Search State

Search state includes:

- Search query
- Search filters
- Search scope
- Search history

Global search state belongs to SearchManager.

Feature-specific search belongs to feature ViewModels.

---

# 24. Filter State

Filters should be stored only where needed.

Examples:

Assignment filters:

```
Priority

Status

Due Date
```

Calendar filters:

```
Visible Calendars

Event Types
```

---

# 25. Persistence State

Persistent data is not application state.

Examples:

Persistent:

```
Course

Assignment

Flashcard

Study Session
```

Temporary:

```
Selected Course

Current Filter

Sheet Visibility
```

---

# 26. Sync State

Synchronization state is managed separately.

Examples:

```
Syncing

Completed

Failed

Offline
```

Sync status should be observable.

---

# 27. Offline State

The application must support offline usage.

State examples:

```
isOffline

pendingChanges

lastSyncDate
```

Users should always know whether data is synchronized.

---

# 28. State Restoration

The app should restore:

- Selected semester
- Sidebar location
- Last opened course
- Calendar position
- Search filters
- Study session progress

State restoration improves continuity.

---

# 29. Memory Management

State should not retain unnecessary objects.

Rules:

- Avoid storing large files in memory.
- Avoid keeping unused ViewModels alive.
- Release temporary resources.
- Use lazy loading.

---

# 30. State Sharing Rules

Shared state should be limited.

Good candidates:

- Theme
- Settings
- Active semester
- Sync status

Bad candidates:

- Current assignment
- Current lecture
- Temporary UI selections

---

# 31. State Testing

State management should be tested.

Tests should verify:

- State changes correctly
- Loading states work
- Errors appear correctly
- Data refreshes correctly
- Navigation restores correctly

---

# 32. State Debugging

State changes should be easy to trace.

Recommended:

- Clear naming
- Small ViewModels
- Predictable updates
- Minimal hidden state

Avoid:

- Global mutable variables
- Side effects inside Views
- Untracked state changes

---

# 33. State Management Rules

The following rules are mandatory.

- Use Observation framework.
- Keep Views lightweight.
- ViewModels own presentation logic.
- Repositories own persistence.
- Avoid unnecessary global state.
- Persist only meaningful user data.
- Temporary UI state should not be stored.
- Async operations must expose loading state.
- Errors must be represented explicitly.
- Shared state must have clear ownership.
- State changes should follow one-directional flow.

---

# 34. Future State Requirements

Future versions may introduce:

- Cross-device session continuation
- Shared study groups
- Collaborative notes
- Apple Intelligence context state
- Multi-user synchronization

The current state architecture should support these additions without major redesign.

---

# 35. State Management Summary

StudyHub uses a modern SwiftUI state architecture based on:

- Observation Framework
- MVVM
- Dependency Injection
- Repository Pattern
- Unidirectional Data Flow

The objective is a predictable and scalable application where every piece of state has a clear owner.

A well-designed state system ensures StudyHub remains fast, maintainable, and easy to extend as new academic features are introduced.