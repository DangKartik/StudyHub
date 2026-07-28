# GLOBAL COMPONENTS

**Project:** StudyHub  
**Document:** 24_GLOBAL_COMPONENTS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

Global Components define reusable UI elements shared across the entire StudyHub application.

These components ensure:

- Consistent design.
- Faster development.
- Better maintainability.
- Unified user experience.

---

# 2. Component Philosophy

A strong design system is built from reusable building blocks.

Without components:

```
Every Screen

↓

Custom UI

↓

Inconsistent Experience
```

With components:

```
Reusable Components

↓

Consistent Screens

↓

Better Product Experience
```

---

# 3. Component Categories

Global components are divided into:

```
Navigation Components

Layout Components

Content Components

Input Components

Feedback Components

Data Components

Learning Components
```

---

# 4. Navigation Components

Shared navigation elements.

Includes:

```
App Sidebar

Navigation Bar

Tab Bar

Toolbar

Breadcrumbs
```

---

# 5. App Sidebar

Purpose:

Main application navigation.

Used in:

```
iPad

macOS

Landscape Mode
```

---

Contains:

```
Home

Semesters

Courses

Calendar

Study Mode

Statistics

Resources

Settings
```

---

Example:

```
┌──────────────┐
│ StudyHub     │
├──────────────┤
│ Home         │
│ Courses      │
│ Calendar     │
│ Statistics   │
│ Settings     │
└──────────────┘
```

---

# 6. Navigation Bar

Used across pages.

Contains:

```
Back Button

Title

Actions
```

---

Example:

```
← Courses          +
```

---

# 7. Toolbar

Common actions.

Examples:

```
Search

Filter

Add

Edit

Share
```

---

# 8. Cards

Primary content container.

Used for:

```
Courses

Tasks

Statistics

Resources

Insights
```

---

Card structure:

```
┌────────────────────┐
│ Title              │
│                    │
│ Content            │
│                    │
│ Action             │
└────────────────────┘
```

---

# 9. Course Card

Displays:

```
Course Name

Code

Progress

Next Task
```

---

Example:

```
SC302

Data Structures

75%

Assignment Due Friday
```

---

# 10. Task Card

Displays:

```
Task Title

Deadline

Priority

Status
```

---

Example:

```
Assignment 2

Due Tomorrow

High Priority
```

---

# 11. Resource Card

Displays:

```
File Icon

Title

Type

Course
```

---

Example:

```
📄

Graph Theory.pdf

SC302
```

---

# 12. Statistics Card

Displays:

```
Metric

Value

Trend
```

---

Example:

```
Study Time

24 Hours

↑20%
```

---

# 13. Buttons

Standard actions.

Types:

```
Primary Button

Secondary Button

Destructive Button

Icon Button

Floating Action Button
```

---

# 14. Primary Button

Used for:

```
Main Actions
```

Examples:

```
Start Session

Create Course

Add Resource
```

---

# 15. Secondary Button

Used for:

```
Alternative Actions
```

Examples:

```
Cancel

View Details

Later
```

---

# 16. Floating Action Button

Used for:

```
Create

Add

Quick Actions
```

---

Examples:

```
+

Add Note

Create Task

Upload Resource
```

---

# 17. Input Components

Reusable input elements.

Includes:

```
Text Fields

Search Bars

Pickers

Toggle Switches

Sliders
```

---

# 18. Search Bar

Used globally.

Features:

```
Search Suggestions

Recent Searches

Filters
```

---

Example:

```
🔍 Search StudyHub
```

---

# 19. Form Components

Used for:

```
Course Creation

Task Creation

Settings

Profile Editing
```

---

Includes:

```
Labels

Validation

Error Messages
```

---

# 20. Status Components

Used to communicate state.

Includes:

```
Progress Indicators

Badges

Labels

Tags
```

---

# 21. Progress Ring

Used for:

```
Goals

Course Progress

Statistics
```

---

Example:

```
     75%

████████░░
```

---

# 22. Progress Bar

Used for:

```
Completion

Reading Progress

Assignments
```

---

Example:

```
Assignment

███████░░░

70%
```

---

# 23. Badge

Displays small information.

Examples:

```
New

Due Soon

Completed

Important
```

---

# 24. Tag Component

Used for organization.

Examples:

```
Algorithms

Exam

Important

Research
```

---

# 25. Empty State Component

Used when content does not exist.

Structure:

```
Icon

Title

Description

Action Button
```

---

Example:

```
No Courses Yet

Add your first course.

[Create Course]
```

---

# 26. Loading Components

Includes:

```
Skeleton Cards

Progress Indicators

Loading Spinners
```

---

# 27. Error Components

Used for failures.

Structure:

```
Error Icon

Message

Retry Action
```

---

Example:

```
Unable to load data.

[Retry]
```

---

# 28. Modal Components

Used for temporary interactions.

Examples:

```
Confirmation

Picker

Creation Form

Preview
```

---

# 29. Sheet Components

Used for:

```
Quick Actions

Filters

Details
```

---

Examples:

```
Filter Sheet

Course Selector
```

---

# 30. Alert Components

Used for important messages.

Examples:

```
Delete Confirmation

Permission Request

Sync Error
```

---

# 31. Learning Components

StudyHub-specific reusable components.

Includes:

```
Flashcard View

Timer View

Question Card

Reflection Card

Study Goal Card
```

---

# 32. Flashcard Component

Displays:

```
Question

Answer

Difficulty

Actions
```

---

Example:

```
Question:

What is polymorphism?


Reveal Answer
```

---

# 33. Question Card

Used in:

```
Active Recall

Practice Mode
```

---

Contains:

```
Question

Answer Input

Feedback
```

---

# 34. Timer Component

Used in:

```
Pomodoro

Study Mode
```

---

Displays:

```
Time Remaining

Session Type

Controls
```

---

# 35. Study Goal Component

Displays:

```
Goal

Progress

Deadline
```

---

Example:

```
Study 20 Hours

14 / 20 Hours
```

---

# 36. Reflection Component

Used after:

```
Study Sessions

Assignments

Readings
```

---

Contains:

```
Question

Text Input

Save Action
```

---

# 37. Chart Components

Reusable data visualization.

Includes:

```
Line Chart

Bar Chart

Progress Chart

Heatmap
```

---

# 38. Avatar Components

Used for:

```
Profile

Authors

Collaborators
```

---

# 39. Icon Components

Standardized:

```
SF Symbols

Custom Icons

Feature Icons
```

---

# 40. Animation Components

Reusable motion:

```
Transitions

Loading Animation

Success Animation
```

---

# 41. Accessibility Components

Every component supports:

```
VoiceOver

Dynamic Type

Keyboard Navigation

Reduced Motion
```

---

# 42. Component Naming Convention

SwiftUI naming:

```
ComponentNameView
```

Examples:

```
CourseCardView

TaskRowView

SearchBarView
```

---

# 43. SwiftUI Structure

Recommended:

```
Shared/

└── Components/

    ├── Cards/

    ├── Buttons/

    ├── Navigation/

    ├── Inputs/

    ├── Feedback/

    ├── Learning/

    ├── Charts/

    └── Accessibility/
```

---

# 44. Component Rules

Every component must:

```
Be Reusable

Have Single Responsibility

Support Dark Mode

Support Accessibility

Follow Design System
```

---

# 45. Testing Checklist

```
□ Component consistency

□ Dark Mode

□ Dynamic Type

□ VoiceOver

□ Keyboard navigation

□ iPad layout

□ Animation behavior

□ Error handling
```

---

# 46. Final Component Architecture

```
Global Components

        |

        ├── Navigation

        ├── Layout

        ├── Cards

        ├── Buttons

        ├── Inputs

        ├── Feedback

        ├── Learning

        ├── Charts

        └── Accessibility
```

Global Components form the foundation of StudyHub's interface, ensuring every screen feels consistent, polished, and aligned with Apple's design principles.