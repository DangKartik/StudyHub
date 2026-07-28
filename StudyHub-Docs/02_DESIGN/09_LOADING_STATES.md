# LOADING STATES

**Project:** StudyHub  
**Document:** 09_LOADING_STATES.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the loading state system for StudyHub.

Loading states communicate that:

- The application is working.
- Data is being retrieved.
- A process is in progress.
- The user should wait or continue interacting.

The goal is to create loading experiences that feel:

- Fast
- Calm
- Predictable
- Native to iPadOS

---

# 2. Loading Philosophy

StudyHub follows the principle:

> Never leave users wondering whether the application is working.

Every asynchronous operation must provide appropriate feedback.

---

# 3. Loading Goals

Loading states should:

- Communicate progress.
- Preserve user context.
- Avoid unnecessary interruption.
- Reduce perceived waiting time.
- Maintain premium experience.

---

# 4. Loading Architecture

Loading flow:

```
User Action

↓

Async Operation

↓

Loading State

↓

Success / Error State
```

---

# 5. Loading State Categories

StudyHub uses:

```
Initial Loading

↓

Content Loading

↓

Action Loading

↓

Background Loading

↓

Progress Loading
```

---

# 6. Loading Principles

## Principle 1: Show Only When Necessary

Fast operations should not display loading indicators.

Rule:

```
< 300ms

↓

No loading indicator
```

---

Operations taking longer:

```
> 300ms

↓

Show loading feedback
```

---

# 7. Loading Components

StudyHub provides reusable components:

```
StudyHubProgressView

StudyHubSkeletonView

StudyHubLoadingButton

StudyHubSyncIndicator
```

---

# 8. Initial App Loading

Scenario:

User opens StudyHub.

Tasks:

- Load SwiftData
- Restore session
- Sync iCloud
- Prepare services

---

Design:

Use:

```
Launch Screen

↓

Main Interface

↓

Background Loading
```

---

Avoid:

Long blocking launch screens.

---

# 9. Dashboard Loading

Scenario:

Loading:

- Today's schedule
- Assignments
- Statistics
- Recommendations

---

Preferred:

Skeleton loading.

Example:

```
-----------------

████████

██████

████

-----------------
```

---

# 10. Skeleton Loading

Skeletons are used for:

- Cards
- Lists
- Dashboard widgets

---

Advantages:

- Shows layout structure.
- Reduces perceived waiting time.
- Feels natural.

---

# 11. Skeleton Rules

Skeletons should:

- Match final layout.
- Use subtle animation.
- Avoid excessive movement.

---

Example:

Course Card:

Loading:

```
██████████

████

██████
```

Final:

```
Machine Learning

SC302

75% Complete
```

---

# 12. Card Loading States

Components:

```
CourseCard

AssignmentCard

ReadingCard

StatCard
```

must support:

```
Loading

↓

Loaded
```

---

Transition:

Fade replacement.

Duration:

```
300ms
```

---

# 13. List Loading States

Used for:

- Courses
- Assignments
- Lectures
- Resources

---

Display:

```
3-5 skeleton rows
```

---

Avoid:

Blank screens.

---

# 14. Button Loading States

Buttons performing actions must communicate progress.

Examples:

- Save Assignment
- Generate Flashcards
- Sync Data
- AI Processing

---

Before:

```
Generate Flashcards
```

After:

```
◌ Generating...
```

---

Rules:

- Disable duplicate actions.
- Preserve button size.
- Maintain context.

---

# 15. AI Loading States

AI operations may take longer.

Examples:

- Summarizing notes
- Generating quizzes
- Creating flashcards

---

Required states:

```
Idle

↓

Processing

↓

Completed

↓

Failed
```

---

# 16. AI Processing Design

Example:

```
Generating Flashcards...

Analyzing lecture notes

Creating questions

Preparing review cards
```

---

Avoid:

False progress indicators.

---

# 17. Progress Indicators

Used when progress is measurable.

Examples:

- File upload
- Export
- Sync
- AI generation

---

Types:

## Circular Progress

Used for:

- Short operations

---

## Linear Progress

Used for:

- Multi-step operations

---

# 18. Sync Loading States

Used for:

- iCloud synchronization
- Calendar synchronization
- Google Calendar sync

---

States:

```
Synced

↓

Syncing

↓

Failed
```

---

Example:

```
☁ Syncing...
```

---

# 19. Calendar Loading

Calendar requires fast feedback.

Loading situations:

- Importing calendars
- Refreshing events
- Syncing external calendars

---

Preferred:

Partial loading.

Do not block:

- Existing events
- Navigation

---

# 20. Search Loading

Search should feel instant.

For large datasets:

```
Typing

↓

Search Processing

↓

Results
```

---

Use:

Small inline indicator.

---

Avoid:

Full-screen loading.

---

# 21. Flashcard Loading

Flashcard loading:

Examples:

- Loading review queue
- Generating cards
- Fetching images

---

Display:

```
Preparing Review Session
```

---

Avoid interrupting learning flow.

---

# 22. Study Mode Loading

Study Mode builds personalized sessions.

Process:

```
Analyzing Progress

↓

Finding Weak Topics

↓

Building Session
```

---

Display:

```
Creating your study plan...
```

---

# 23. File Loading States

Used for:

- PDFs
- Slides
- Resources
- Attachments

---

States:

```
Loading

↓

Available

↓

Failed
```

---

Provide:

- File name
- Progress
- Error recovery

---

# 24. Error After Loading

Every loading state must have failure handling.

Structure:

```
Loading

↓

Failure

↓

Explanation

↓

Retry Action
```

---

Example:

```
Unable to sync calendars.

[Try Again]
```

---

# 25. Loading Animations

Allowed:

- Fade
- Pulse
- Skeleton shimmer
- Spinner rotation

---

Duration:

```
200ms - 500ms
```

---

Avoid:

- Large animations
- Distracting movement

---

# 26. Reduce Motion Support

When Reduce Motion is enabled:

Replace:

```
Skeleton animation
```

with:

```
Static placeholder
```

---

# 27. Accessibility Requirements

Loading states must announce changes.

Example:

VoiceOver:

```
Loading assignments
```

---

When complete:

```
Assignments loaded
```

---

# 28. Dark Mode Requirements

Loading components must support:

- Semantic colors
- System materials
- Proper contrast

---

# 29. Performance Requirements

Loading states must:

- Not block UI unnecessarily.
- Avoid excessive rendering.
- Use async operations correctly.

---

Preferred:

```swift
.task {
    await viewModel.load()
}
```

---

# 30. SwiftUI Implementation

Example:

```swift
if viewModel.isLoading {

    ProgressView()

} else {

    ContentView()

}
```

---

# 31. Loading State Architecture

Recommended structure:

```
DesignSystem/

├── Loading/

│
├── StudyHubSkeletonView.swift

├── LoadingState.swift

├── ProgressView.swift

└── LoadingButton.swift
```

---

# 32. Testing Checklist

Before release:

```
□ Fast operations do not show unnecessary loaders

□ Long operations show feedback

□ Errors have recovery actions

□ VoiceOver announces loading

□ Dynamic Type works

□ Dark Mode tested

□ Reduce Motion tested

□ Offline scenarios tested
```

---

# 33. Loading Anti-Patterns

Avoid:

## Blank Screens

Bad:

```
(empty screen)
```

---

## Infinite Loading

Bad:

```
Loading forever
```

without explanation.

---

## Blocking Entire App

Bad:

```
Cannot use app while syncing
```

---

## Fake Progress

Bad:

```
Progress bar moving randomly
```

---

# 34. Loading Rules Summary

Mandatory rules:

- Always communicate long operations.
- Prefer skeleton loading for content.
- Use progress indicators when measurable.
- Keep users in context.
- Provide error recovery.
- Support accessibility.

---

# 35. Loading Architecture Summary

StudyHub loading follows:

```
Action

↓

Feedback

↓

Progress

↓

Result

↓

Recovery if Needed
```

The loading system ensures StudyHub feels responsive, reliable, and polished even during complex operations such as synchronization, AI processing, and data loading.