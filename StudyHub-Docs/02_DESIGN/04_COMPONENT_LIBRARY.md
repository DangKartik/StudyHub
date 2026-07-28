# COMPONENT LIBRARY

**Project:** StudyHub  
**Document:** 04_COMPONENT_LIBRARY.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the reusable UI component library for StudyHub.

The component library establishes:

- Consistent interface patterns
- Reusable SwiftUI components
- Faster development
- Better maintainability
- Apple-quality user experience

Every major screen in StudyHub should be composed from these reusable components.

---

# 2. Component Philosophy

StudyHub follows the principle:

> Build small, reusable, meaningful components instead of designing every screen independently.

Components should be:

- Modular
- Accessible
- Adaptive
- Reusable
- Theme-aware

---

# 3. Component Architecture

Component hierarchy:

```
Design System

↓

Primitive Components

↓

Common Components

↓

Feature Components

↓

Screen Components
```

---

# 4. Component Categories

StudyHub components are divided into:

```
Layout Components

↓

Navigation Components

↓

Content Components

↓

Academic Components

↓

Learning Components

↓

Data Visualization Components

↓

Feedback Components
```

---

# 5. Component Naming Convention

All components follow:

```
StudyHub + Component Name
```

Examples:

```
StudyHubCard

StudyHubButton

StudyHubProgressRing

StudyHubEmptyState
```

---

# 6. Primitive Components

Primitive components are the foundation of the design system.

---

# 6.1 StudyHubButton

Purpose:

Reusable action button.

Used for:

- Create actions
- Confirm actions
- Navigation actions

Examples:

```
+ Add Assignment

Start Study Session

Generate Flashcards
```

---

Properties:

```
title

icon

style

action

disabled state
```

---

Button Styles:

```
Primary

Secondary

Destructive

Text
```

---

SwiftUI Example:

```swift
StudyHubButton(
    title: "Add Course",
    icon: "plus"
)
```

---

# 6.2 StudyHubCard

Purpose:

Primary container component.

Used for:

- Dashboard sections
- Course summaries
- Statistics
- Tasks

---

Properties:

```
title

subtitle

content

accentColor

action
```

---

Design:

```
Rounded Rectangle

↓

Material Background

↓

Content

```

---

# 6.3 StudyHubIconContainer

Purpose:

Provides consistent icon presentation.

Used for:

- Navigation
- Cards
- Status indicators

Properties:

```
icon

color

size

style
```

---

# 6.4 StudyHubBadge

Purpose:

Displays compact information.

Examples:

```
Due Tomorrow

Completed

3 Days Left

AI Generated
```

---

Properties:

```
text

color

icon
```

---

# 6.5 StudyHubDivider

Purpose:

Separates content sections.

Rules:

- Subtle
- Minimal
- Native iPadOS appearance

---

# 7. Layout Components

---

# 7.1 StudyHubSection

Purpose:

Groups related information.

Example:

Dashboard:

```
Today's Schedule

↓

Upcoming Assignments

↓

Study Statistics
```

---

Properties:

```
title

subtitle

content
```

---

# 7.2 StudyHubGrid

Purpose:

Adaptive card layouts.

Used for:

- Dashboard widgets
- Statistics
- Course overview

---

Supports:

- iPad landscape
- Split View
- Stage Manager

---

# 7.3 StudyHubList

Purpose:

Standardized list container.

Used for:

- Assignments
- Courses
- Lectures
- Resources

---

Features:

- Swipe actions
- Sorting
- Filtering
- Empty states

---

# 8. Navigation Components

---

# 8.1 StudyHubSidebar

Purpose:

Primary iPad navigation.

Structure:

```
Dashboard

Calendar

Courses

Assignments

Readings

Flashcards

Statistics

Settings
```

---

Features:

- Selection state
- Keyboard navigation
- Pointer support

---

# 8.2 StudyHubToolbar

Purpose:

Top-level actions.

Examples:

```
Search

Add

Filter

Sort
```

---

Supports:

- iPad toolbar placement
- Keyboard shortcuts

---

# 8.3 StudyHubSearchBar

Purpose:

Global search.

Features:

- Search suggestions
- Recent searches
- Filtering

---

# 9. Academic Components

---

# 9.1 CourseCard

Purpose:

Displays course overview.

Contains:

```
Course Name

Course Code

Instructor

Progress

Upcoming Tasks
```

---

Example:

```
-------------------

SC2002

Object Oriented Design

72% Complete

3 Assignments Due

-------------------
```

---

# 9.2 LectureRow

Purpose:

Displays lecture information.

Contains:

```
Date

Time

Topic

Location
```

---

Actions:

- Open notes
- Open flashcards
- Open resources

---

# 9.3 AssignmentCard

Purpose:

Displays assignment information.

Contains:

```
Title

Due Date

Priority

Progress

Status
```

---

States:

```
Not Started

In Progress

Completed

Overdue
```

---

# 9.4 ReadingCard

Purpose:

Displays reading progress.

Contains:

```
Title

Pages

Progress

Due Date
```

---

# 9.5 ExamCard

Purpose:

Displays upcoming exams.

Contains:

```
Course

Date

Countdown

Preparation Progress
```

---

# 10. Learning Components

---

# 10.1 FlashcardView

Purpose:

Main flashcard learning interface.

Structure:

```
Question

↓

Flip Animation

↓

Answer

↓

Difficulty Buttons
```

---

Actions:

```
Again

Hard

Good

Easy
```

---

# 10.2 ActiveRecallCard

Purpose:

Displays recall questions.

Types:

```
Question Answer

Fill Blank

Definition

Diagram

Explain Concept
```

---

# 10.3 StudySessionCard

Purpose:

Displays active study session.

Contains:

```
Timer

Current Activity

Progress

Controls
```

---

# 10.4 PomodoroTimer

Purpose:

Focused study timer.

Modes:

```
25/5

50/10

Custom
```

---

States:

```
Ready

Running

Paused

Completed
```

---

# 11. Dashboard Components

---

# 11.1 GreetingHeader

Purpose:

Personalized dashboard introduction.

Example:

```
Good Morning, Kartik

Ready for today's study?
```

---

# 11.2 QuoteCard

Purpose:

Daily motivational quote.

Contains:

```
Quote

Author

Refresh Action
```

---

# 11.3 ProgressRing

Purpose:

Visual progress tracking.

Used for:

- Semester progress
- Study goals
- Assignment completion

---

# 11.4 StatCard

Purpose:

Display important numbers.

Examples:

```
25 Hours Studied

120 Flashcards Reviewed

7 Day Streak
```

---

# 11.5 DeadlineCard

Purpose:

Shows upcoming deadlines.

Contains:

```
Task

Due Date

Priority
```

---

# 12. Data Visualization Components

---

# 12.1 StudyChart

Purpose:

Reusable chart container.

Used for:

- Study hours
- Progress
- Grades

---

# 12.2 ProgressBar

Purpose:

Linear progress tracking.

Examples:

```
Assignment Completion

Reading Progress
```

---

# 12.3 Heatmap

Purpose:

Visualizes study consistency.

Example:

```
Study Streak Calendar
```

---

# 13. Feedback Components

---

# 13.1 StudyHubEmptyState

Purpose:

Handles missing content.

Structure:

```
Icon

↓

Title

↓

Description

↓

Action Button
```

---

Examples:

```
No Courses Yet

Add your first course
```

---

# 13.2 StudyHubLoadingView

Purpose:

Displays loading states.

Types:

```
Spinner

Skeleton

Progress Indicator
```

---

# 13.3 StudyHubErrorView

Purpose:

Displays recoverable errors.

Contains:

```
Error Icon

Message

Retry Button
```

---

# 14. Modal Components

---

# 14.1 CreateSheet

Used for:

- New course
- Assignment
- Flashcard
- Study session

---

# 14.2 DetailSheet

Used for:

- Quick preview
- Editing

---

# 14.3 ConfirmationDialog

Used for:

- Delete actions
- Destructive changes

---

# 15. Component States

Every component should support:

```
Default

Loading

Empty

Error

Disabled

Selected
```

---

# 16. Accessibility Requirements

All components must support:

- Dynamic Type
- VoiceOver
- Keyboard navigation
- Pointer interaction
- Reduced Motion

---

# 17. Dark Mode Requirements

Every component must:

- Use semantic colors.
- Support system materials.
- Maintain contrast.
- Avoid hardcoded colors.

---

# 18. Component File Structure

Recommended SwiftUI structure:

```
DesignSystem/

├── Components/

│
├── Buttons/

│   └── StudyHubButton.swift

│
├── Cards/

│   └── StudyHubCard.swift

│
├── Charts/

│   └── StudyChart.swift

│
├── Feedback/

│   └── EmptyStateView.swift

│
└── Navigation/

    └── Sidebar.swift
```

---

# 19. Component Testing

Every component requires:

## Preview Testing

Test:

- Light Mode
- Dark Mode
- Different content lengths

---

## Accessibility Testing

Test:

- Dynamic Type
- VoiceOver

---

## Device Testing

Test:

- iPad Pro
- iPad Air
- Split View
- Stage Manager

---

# 20. Component Rules Summary

Mandatory rules:

- Components must be reusable.
- Components must support accessibility.
- Components must support Dark Mode.
- Components must use design tokens.
- Components must avoid duplicated UI logic.
- Components must follow Apple conventions.

---

# 21. Component Library Architecture Summary

StudyHub UI is built using:

```
Primitive Components

↓

Reusable Components

↓

Feature Components

↓

Complete Screens
```

This allows StudyHub to scale into a large academic operating system while maintaining a consistent premium Apple-quality interface.