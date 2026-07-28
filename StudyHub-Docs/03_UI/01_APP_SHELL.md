# APP SHELL

**Project:** StudyHub  
**Document:** 01_APP_SHELL.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

This document defines the global application structure of StudyHub.

The App Shell is the foundation that every feature screen is built on.

It defines:

- Global navigation
- Window structure
- Sidebar behavior
- Toolbar behavior
- Navigation patterns
- iPad layouts
- Keyboard interactions
- Stage Manager support
- Global actions

---

# 2. App Shell Philosophy

StudyHub is designed as an iPad-first academic operating system.

The app should feel like:

- Apple Notes
- Apple Calendar
- Apple Reminders
- Apple Health
- GoodNotes

combined into one academic workspace.

The shell should provide:

- Fast navigation
- Clear hierarchy
- Minimal friction
- Consistent experience

---

# 3. Navigation Philosophy

StudyHub uses a hybrid navigation model.

Global navigation:

```
NavigationSplitView
```

Internal navigation:

```
NavigationStack
```

---

The structure:

```
App Shell

↓

Sidebar

↓

Feature Section

↓

List Page

↓

Detail Page

↓

Sub Detail Pages
```

---

# 4. Navigation Architecture

High-level structure:

```
                    StudyHub

                       |
                       |

                 Sidebar Navigation

                       |
 ------------------------------------------------

 Home        Courses       Calendar       Statistics

                       |

              Feature Navigation

                       |

                 Detail Screens
```

---

# 5. Global Sidebar

The sidebar is the primary navigation system.

It contains major areas of the application.

---

Sidebar:

```
StudyHub

────────────

Home

Courses

Calendar

Study Mode

Flashcards

Statistics

Resources

────────────

Search

Settings
```

---

# 6. Sidebar Design Goals

The sidebar should:

- Always provide orientation.
- Require minimal interaction.
- Support keyboard navigation.
- Work in landscape and portrait.

---

# 7. Sidebar Behavior

## Landscape

Default:

```
Sidebar visible
```

Example:

```
┌──────────┬─────────────────────────┐
│ Sidebar  │ Main Content             │
│          │                          │
│ Home     │ Dashboard                │
│ Courses  │                          │
│ Calendar │                          │
└──────────┴─────────────────────────┘
```

---

## Portrait

Sidebar becomes:

```
Hidden Drawer
```

Opened through:

```
Sidebar Button
```

---

# 8. Main Content Area

The main content area displays feature screens.

Examples:

```
Home Dashboard

Course List

Calendar

Statistics
```

---

The content area uses:

```
NavigationStack
```

---

# 9. Detail Navigation Model

StudyHub does NOT use persistent detail panes.

Instead:

User action:

```
Tap Item
```

creates:

```
New Detail Page
```

---

Example:

```
Courses

↓

Course List

↓

SC302 Detail

↓

Lecture Detail

↓

Assignment Detail
```

---

# 10. Why Full Page Details

Academic information requires space.

A course contains:

```
Course

├── Lectures

├── Assignments

├── Readings

├── Notes

├── Flashcards

├── Grades

└── Resources
```

A dedicated page provides:

- More screen space
- Better Apple Pencil workflow
- Better document viewing
- Better learning experience

---

# 11. Home Screen Entry Point

Home is the default launch screen.

Purpose:

Provide academic overview.

Contains:

```
Greeting

Quote

Today's Schedule

Tasks

Deadlines

Study Progress

Quick Actions

Recommendations
```

---

# 12. Toolbar Architecture

Every major screen supports a native toolbar.

Toolbar areas:

```
Leading

Center

Trailing
```

---

Example:

Courses:

```
←

Courses

+

Search
```

---

# 13. Global Toolbar Actions

Common actions:

```
+

Search

Filter

Sort

More Options
```

---

# 14. Add Button Philosophy

StudyHub follows Apple's creation pattern.

Users can create objects manually.

Every major section has:

```
+
```

Example:

Courses:

```
+ Add Course
```

Assignments:

```
+ Add Assignment
```

Flashcards:

```
+ Create Flashcard
```

---

# 15. Command System

StudyHub supports external keyboards.

Global shortcuts:

---

New Item:

```
⌘ + N
```

---

Search:

```
⌘ + F
```

---

Open Sidebar:

```
⌘ + S
```

---

Navigate:

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

---

# 16. Search Integration

Search is available globally.

Users can search:

```
Courses

Lectures

Assignments

Notes

Flashcards

Resources
```

---

Access:

```
⌘ + F
```

or:

Toolbar Search.

---

# 17. Context Menus

StudyHub supports iPad context menus.

Examples:

Course:

```
Open

Edit

Duplicate

Archive

Delete
```

---

Assignment:

```
Mark Complete

Edit

Move

Delete
```

---

# 18. Stage Manager Support

StudyHub is optimized for Stage Manager.

Requirements:

- Resizable windows
- Adaptive layouts
- No fixed dimensions
- Preserved navigation state

---

Example:

Large window:

```
Sidebar + Content
```

Small window:

```
Content only
```

---

# 19. Split View Support

StudyHub supports iPad multitasking.

Examples:

StudyHub + Safari:

```
Research Paper

+

StudyHub Notes
```

---

StudyHub + GoodNotes:

```
GoodNotes

+

Lecture Dashboard
```

---

# 20. Orientation Support

## Primary Orientation

Landscape.

Reason:

- Productivity workflow
- Keyboard usage
- Multitasking
- Dashboard visibility

---

## Secondary Orientation

Portrait.

Optimized for:

- Reading
- Flashcards
- Quick reviews

---

# 21. Responsive Layout Rules

Screens must adapt to:

```
iPad Pro

iPad Air

iPad Mini

Stage Manager

Split View
```

---

Avoid:

- Fixed widths
- Hardcoded positions
- Desktop-only layouts

---

# 22. App Lifecycle Integration

App Shell manages:

- Launch state
- Authentication state
- Onboarding state
- Data restoration
- Navigation restoration

---

Launch flow:

```
Open App

↓

Check User State

↓

Check Onboarding

↓

Restore Data

↓

Open Dashboard
```

---

# 23. State Restoration

StudyHub remembers:

- Last opened section
- Last selected course
- Navigation position
- Search state

---

Example:

User closes app:

```
Courses

↓

SC302

↓

Lecture 5
```

When reopened:

Return to:

```
SC302 Lecture 5
```

---

# 24. SwiftUI Architecture

Recommended:

```
App/

├── StudyHubApp.swift

├── AppShellView.swift

├── SidebarView.swift

├── NavigationRouter.swift

└── RootView.swift
```

---

# 25. App Shell Implementation

Example:

```swift
NavigationSplitView {

    SidebarView()

} detail: {

    NavigationStack {

        ContentView()

    }
}
```

---

# 26. Navigation Router

Central navigation management:

Responsibilities:

- Deep links
- Navigation state
- Routing

Example:

```
HomeRoute

CourseRoute

LectureRoute

AssignmentRoute
```

---

# 27. Accessibility Requirements

App Shell supports:

- VoiceOver
- Dynamic Type
- Keyboard navigation
- Switch Control
- Reduce Motion

---

Sidebar items require:

```
Accessible Label

Accessible Hint

Selection State
```

---

# 28. Empty States

Every section must provide:

- First-use guidance
- Creation action
- Helpful explanation

---

Example:

Courses:

```
No Courses Yet

Add your first course.

[Add Course]
```

---

# 29. Loading States

App Shell supports:

- Data restoration
- iCloud loading
- Authentication loading

---

Never block the entire interface unnecessarily.

---

# 30. Error Handling

Global errors appear through:

- Alerts
- Sheets
- Inline messages

---

Examples:

```
Unable to sync calendar.

Retry
```

---

# 31. Performance Requirements

The shell must:

- Launch quickly
- Restore state efficiently
- Avoid unnecessary reloads
- Maintain 60 FPS navigation

---

# 32. App Shell Component Structure

Recommended:

```
Features/

├── AppShell/

│
├── AppShellView.swift

├── SidebarView.swift

├── ToolbarConfiguration.swift

├── NavigationRouter.swift

└── WindowManager.swift
```

---

# 33. Testing Checklist

Before release:

```
□ First launch works

□ Sidebar navigation works

□ Portrait tested

□ Landscape tested

□ Stage Manager tested

□ Split View tested

□ Keyboard shortcuts tested

□ State restoration tested

□ VoiceOver tested
```

---

# 34. Final App Shell Architecture

StudyHub follows:

```
NavigationSplitView

        ↓

Global Sidebar

        ↓

NavigationStack

        ↓

Feature Pages

        ↓

Detail Pages

        ↓

Learning Workflows
```

The App Shell establishes StudyHub as a true iPad productivity application rather than a mobile planner stretched onto a larger screen.