# NAVIGATION

**Project:** StudyHub  
**Document:** 03_NAVIGATION.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team

---

# 1. Purpose

This document defines the navigation architecture for StudyHub.

Navigation should feel identical to Apple's first-party iPad applications such as:

- Apple Mail
- Apple Notes
- Apple Calendar
- Apple Files
- Apple Reminders

StudyHub is a **Landscape-First**, **Portrait-Supported**, **Adaptive** iPad application.

The navigation system must be:

- Fast
- Predictable
- Context-aware
- Keyboard-friendly
- Apple Pencil friendly
- Accessible
- Fully native

---

# 2. Navigation Philosophy

Navigation should answer three questions at all times:

- Where am I?
- What can I do here?
- How do I return?

Users should never feel lost.

Every screen should preserve context.

---

# 3. Navigation Principles

StudyHub follows the following navigation principles.

## 3.1 Native First

Use SwiftUI's native navigation APIs.

Never create a custom navigation system unless absolutely necessary.

---

## 3.2 Preserve Context

Editing an object should never force users back to the Home Dashboard.

Example

```
Course

↓

Lecture

↓

Edit Lecture

↓

Save

↓

Return to Lecture
```

---

## 3.3 Minimize Navigation Depth

Users should rarely need more than three taps to reach common content.

Poor

```
Dashboard

↓

Courses

↓

Semester

↓

Course

↓

Lecture

↓

Notes
```

Preferred

```
Dashboard

↓

Course

↓

Lecture
```

---

## 3.4 Multiple Entry Points

Important features should be reachable from multiple places.

Example

Assignments may be opened from:

- Dashboard
- Course
- Calendar
- Search
- Notifications
- Widgets

---

## 3.5 Consistency

Every feature should follow similar navigation behavior.

Creating an Assignment should feel identical to creating a Reading or Lecture.

---

# 4. Navigation Style

StudyHub uses

**NavigationSplitView**

as the primary navigation container.

```
┌────────────┬──────────────────────┬──────────────────────┐
│ Sidebar    │ Content              │ Detail               │
│            │                      │                      │
│ Home       │ Course List          │ Course Details       │
│ Courses    │                      │                      │
│ Calendar   │                      │                      │
│ Settings   │                      │                      │
└────────────┴──────────────────────┴──────────────────────┘
```

---

# 5. Adaptive Layout

Navigation adapts automatically.

## Large iPad

Three Columns

```
Sidebar

↓

Content

↓

Detail
```

---

## Medium Width

Two Columns

```
Sidebar

↓

Detail
```

---

## Compact Width

NavigationStack

```
Home

↓

Courses

↓

Course Detail

↓

Lecture
```

---

# 6. Root Navigation

The Sidebar represents the application's primary navigation.

```
🏠 Home

────────────

📚 Semesters

📖 Courses

📅 Calendar

📝 Assignments

📖 Readings

📂 Resources

🧠 Flashcards

🎯 Study Mode

⏱ Pomodoro

📊 Statistics

────────────

💬 Quotes

⚙ Settings
```

The Sidebar remains available throughout the application.

---

# 7. Sidebar Behavior

The Sidebar should:

- Collapse automatically when appropriate
- Support keyboard navigation
- Support search
- Remember expansion state
- Remember selected item
- Animate smoothly

---

# 8. Navigation Hierarchy

The application hierarchy is:

```
Home

↓

Module

↓

List

↓

Detail

↓

Child Detail
```

Example

```
Courses

↓

Computer Science

↓

Lecture

↓

Flashcards
```

---

# 9. Home Dashboard Navigation

The Home Dashboard acts as the central hub.

Every major feature should be reachable from Home.

Dashboard sections are interactive.

Example

```
Today's Assignment

↓

Assignment Detail

↓

Edit

↓

Save

↓

Dashboard
```

---

# 10. Semester Navigation

Users may switch semesters from:

- Sidebar
- Dashboard
- Settings

Changing semesters refreshes the entire workspace.

The active semester is global.

---

# 11. Course Navigation

```
Courses

↓

Course List

↓

Course Detail
```

Course Detail provides navigation to:

- Lectures
- Assignments
- Readings
- Flashcards
- Resources
- Grades
- Statistics

---

# 12. Lecture Navigation

```
Course

↓

Lecture

↓

Lecture Detail
```

Lecture Detail provides access to:

- Notes
- Objectives
- Attachments
- Active Recall
- Flashcards
- GoodNotes

---

# 13. Assignment Navigation

```
Assignments

↓

Assignment List

↓

Assignment Detail

↓

Checklist

↓

Submission
```

Assignments can also be opened from:

- Dashboard
- Calendar
- Notifications
- Search

---

# 14. Reading Navigation

```
Readings

↓

Reading List

↓

Reading Detail
```

Reading Detail includes:

- Progress
- Notes
- Highlights
- Estimated Time

---

# 15. Calendar Navigation

Calendar supports multiple views.

```
Calendar

↓

Day

Week

Month

Agenda
```

Selecting an event opens the relevant detail screen.

---

# 16. Flashcard Navigation

```
Flashcards

↓

Deck

↓

Review

↓

Statistics
```

Users may also review flashcards from:

- Dashboard
- Study Mode
- Notifications

---

# 17. Active Recall Navigation

```
Lecture

↓

Active Recall

↓

Question

↓

Answer

↓

Next Question
```

Navigation should remain distraction-free.

---

# 18. Study Mode Navigation

```
Study Mode

↓

Generate Session

↓

Study

↓

Summary
```

Study Mode temporarily hides unnecessary navigation elements.

---

# 19. Search Navigation

Search is global.

Users can search from anywhere.

Results may include:

- Courses
- Lectures
- Assignments
- Readings
- Flashcards
- Quotes
- Resources

Selecting a result navigates directly to its detail screen.

---

# 20. Global "+" Button

Every primary module supports creation.

Examples

```
Courses

+

↓

New Course
```

```
Assignments

+

↓

New Assignment
```

```
Lectures

+

↓

New Lecture
```

Creation should use:

- Sheet
- Full-screen sheet (if necessary)

Never push creation forms onto the navigation stack.

---

# 21. Sheets

Sheets are used for temporary tasks.

Examples

- Add Course
- Add Assignment
- Add Semester
- Add Flashcard
- Settings
- Quote Manager

Users should return to their previous screen after dismissal.

---

# 22. Popovers

Popovers are used for lightweight actions.

Examples

- Color picker
- Date picker
- Filter menu
- Sort menu
- Quick actions

Avoid large workflows inside popovers.

---

# 23. Context Menus

Long press or secondary click reveals contextual actions.

Example

Course

```
Open

Edit

Duplicate

Archive

Delete
```

Context menus reduce toolbar clutter.

---

# 24. Swipe Actions

Available where appropriate.

Examples

Assignments

```
Complete

Edit

Delete
```

Readings

```
Update Progress

Edit

Delete
```

Flashcards

```
Edit

Delete
```

Swipe actions should remain consistent throughout the application.

---

# 25. Toolbar

Every screen should include only the most relevant actions.

Typical actions:

- Add
- Search
- Filter
- Sort
- More

Avoid overcrowding toolbars.

---

# 26. Breadcrumb Strategy

StudyHub does not use traditional breadcrumbs.

Instead, NavigationSplitView naturally provides context.

Example

```
Sidebar

↓

Courses

↓

Computer Science

↓

Lecture 5
```

The visible hierarchy replaces breadcrumb navigation.

---

# 27. Deep Linking

StudyHub should support deep links.

Examples

```
studyhub://course/123

studyhub://lecture/42

studyhub://assignment/18

studyhub://flashcard/95
```

Used by:

- Widgets
- Notifications
- Siri (future)
- Shortcuts (future)

---

# 28. Keyboard Navigation

StudyHub should support keyboard users.

Examples

- Arrow Keys
- Return
- Escape
- Command + F
- Command + N
- Command + S
- Command + ,

Keyboard shortcuts should mirror Apple's apps where possible.

---

# 29. State Restoration

When reopening the app, restore:

- Active semester
- Selected module
- Scroll position
- Open detail screen
- Sidebar state
- Filters
- Sort order

Users should continue exactly where they left off.

---

# 30. Multiwindow Support

StudyHub supports multiple windows using Stage Manager.

Examples

Window 1

```
Calendar
```

Window 2

```
Flashcards
```

Window 3

```
Lecture Notes
```

Each window maintains its own navigation state.

---

# 31. External Display Support

Navigation should adapt to external monitors.

The Sidebar remains fixed.

Content expands naturally.

No custom layouts are required.

---

# 32. Accessibility Navigation

Navigation must support:

- VoiceOver
- Keyboard
- Switch Control
- Apple Pencil
- Dynamic Type

Every navigation destination must expose clear accessibility labels.

---

# 33. Navigation Performance

Navigation should feel immediate.

Targets

- Screen transitions < 150 ms
- Detail loading < 200 ms
- Sidebar switching should appear instantaneous
- Preserve 60 FPS during transitions

---

# 34. Navigation Rules

The following rules are mandatory.

- Use NavigationSplitView as the primary navigation container.
- Use NavigationStack for compact layouts.
- Preserve user context after editing.
- Use Sheets for creation workflows.
- Use Popovers for lightweight interactions.
- Use Context Menus for secondary actions.
- Avoid deep navigation hierarchies.
- Support keyboard navigation.
- Support state restoration.
- Support multiple windows.

---

# 35. Navigation Summary

StudyHub adopts a navigation system inspired by Apple's professional productivity apps.

The experience should feel:

- Native
- Calm
- Predictable
- Efficient
- Adaptive
- Scalable

Users should be able to move between planning, learning, reviewing, and managing their academic life without losing context or disrupting their workflow.