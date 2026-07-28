# SEMESTERS

**Project:** StudyHub  
**Document:** 04_SEMESTERS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Semester Management screen allows users to organize their academic life into independent semester environments.

A semester acts as a container that separates:

- Courses
- Assignments
- Lectures
- Readings
- Grades
- Flashcards
- Notes
- Statistics
- Resources

Each semester is isolated to prevent academic data from different periods mixing together.

---

# 2. Semester Philosophy

University students naturally organize their work by academic terms.

StudyHub mirrors this mental model.

Instead of:

```
All Courses

All Assignments

All Notes
```

StudyHub uses:

```
Semester

↓

Courses

↓

Academic Activities
```

---

# 3. User Goals

Users should be able to:

- Create unlimited semesters.
- Switch between active semesters.
- Archive old semesters.
- Review previous academic performance.
- Duplicate semester structures.
- Manage future semesters.

---

# 4. Navigation Flow

Entry:

```
Sidebar

↓

Courses

↓

Semester Selector

↓

Semester Detail
```

---

Alternative:

```
Settings

↓

Academic Management

↓

Semesters
```

---

# 5. Semester Screen Overview

Main layout:

```
┌───────────────────────────────────┐
│ Semesters                 + Add   │
├───────────────────────────────────┤
│                                   │
│ Active Semester                   │
│                                   │
│ Fall 2026                         │
│                                   │
├───────────────────────────────────┤
│ Previous Semesters                │
│                                   │
│ Spring 2026                       │
│ Fall 2025                         │
│                                   │
└───────────────────────────────────┘
```

---

# 6. Semester Categories

Semesters have three states:

## Current Semester

The currently active academic period.

Example:

```
Fall 2026
```

---

## Upcoming Semester

Future semester.

Example:

```
Spring 2027
```

---

## Archived Semester

Completed semester.

Example:

```
Fall 2025
```

---

# 7. Semester Card

Each semester appears as a card.

---

Displays:

```
Semester Name

Academic Year

Date Range

Number of Courses

Progress

Status
```

---

Example:

```
Fall 2026

Aug 2026 - Dec 2026

6 Courses

45% Complete

Current
```

---

# 8. Add Semester

Users create semesters manually.

Primary action:

```
+
```

---

Screen:

```
Create Semester
```

---

Fields:

```
Semester Name

Academic Year

Start Date

End Date

Status
```

---

Example:

```
Fall 2026

2026

August 10

December 5

Current
```

---

# 9. Semester Creation Rules

Required:

```
Semester Name

Start Date

End Date
```

---

Optional:

```
Academic Year

Description

Color
```

---

Validation:

End date cannot be before start date.

---

# 10. Semester Detail Page

Selecting a semester opens a dedicated page.

Navigation:

```
Semester List

↓

Semester Detail
```

---

Layout:

```
Fall 2026


Overview

Courses

Assignments

Grades

Statistics

Settings
```

---

# 11. Semester Header

Contains:

```
Semester Name

Date Range

Status

Progress
```

---

Example:

```
Fall 2026

Aug 10 - Dec 5

Current Semester

65% Complete
```

---

# 12. Semester Overview

Displays:

```
Total Courses

Upcoming Deadlines

Study Hours

Grade Progress

Completion Rate
```

---

Example:

```
6 Courses

3 Assignments Due

42 Study Hours

78% Average
```

---

# 13. Semester Courses

Shows courses belonging to this semester.

Example:

```
Fall 2026

├── SC302 Data Structures

├── SC2002 Object Oriented Design

├── MH1812 Mathematics
```

---

Action:

```
Add Course
```

---

# 14. Semester Assignments

Displays all assignments.

Grouped:

```
Upcoming

Completed

Overdue
```

---

Example:

```
Upcoming:

Machine Learning Report

Due Friday
```

---

# 15. Semester Statistics

Displays semester-level analytics.

Metrics:

```
Study Hours

Assignment Completion

Grade Average

Flashcards Reviewed

Attendance
```

---

# 16. Semester Switching

Users can quickly switch semesters.

Location:

```
Semester Selector
```

---

Example:

Toolbar:

```
Fall 2026 ▼
```

---

Dropdown:

```
Fall 2026

Spring 2026

Fall 2025
```

---

# 17. Active Semester Rules

Only one semester can be active.

Example:

Current:

```
Fall 2026
```

If user activates:

```
Spring 2027
```

then:

```
Fall 2026

↓

Archived
```

or:

```
Completed
```

depending on date.

---

# 18. Archive Semester

Purpose:

Preserve historical academic data.

---

Archive action:

```
Archive Semester
```

---

Archived semesters:

- Cannot modify active workflows.
- Remain searchable.
- Preserve statistics.

---

# 19. Duplicate Semester

Useful for recurring structures.

Example:

```
Fall 2026
```

Duplicate:

```
Fall 2027
```

---

Copies:

```
Courses

Grade Structure

Templates

Recurring Lectures
```

---

Does not copy:

```
Grades

Completed Assignments

Study History
```

---

# 20. Delete Semester

Deletion requires confirmation.

Warning:

```
Delete Fall 2026?

This will permanently remove:

Courses
Assignments
Notes
Statistics

This action cannot be undone.
```

---

Options:

```
Cancel

Delete
```

---

# 21. Empty State

New user:

```
No Semesters Yet

Create your first semester
to start organizing your academics.

[Create Semester]
```

---

# 22. Loading State

While loading:

Display:

- Semester card skeletons.
- Placeholder statistics.

---

# 23. Error State

Example:

```
Unable to load semesters.

Try again.
```

---

# 24. Search Integration

Users can search semesters.

Search:

```
Fall 2026

Spring 2027
```

---

# 25. Toolbar

Toolbar:

```
Leading:

Sidebar


Center:

Semesters


Trailing:

+

Search
```

---

# 26. Context Menu

Long press semester:

```
Open

Rename

Duplicate

Archive

Delete
```

---

# 27. SwiftUI Structure

Recommended:

```
Features/

└── Semesters/

    ├── SemesterListView.swift

    ├── SemesterDetailView.swift

    ├── SemesterCard.swift

    ├── SemesterFormView.swift

    └── SemesterViewModel.swift
```

---

# 28. ViewModel Responsibilities

SemesterViewModel manages:

```
Load semesters

Create semester

Update semester

Archive semester

Delete semester

Switch active semester
```

---

# 29. Data Requirements

Required models:

```
Semester

Course

Assignment

Grade

StudySession

Statistics
```

---

# 30. Navigation Rules

Flow:

```
Semester List

↓

Semester Detail

↓

Course List

↓

Course Detail
```

---

# 31. iPad Design Requirements

Supports:

- Landscape mode.
- Portrait mode.
- Stage Manager.
- Keyboard shortcuts.
- Apple Pencil.

---

# 32. Accessibility

Supports:

- VoiceOver.
- Dynamic Type.
- High Contrast.
- Reduced Motion.

---

Semester cards require:

```
Accessible label:

Fall 2026 semester.
6 courses.
65 percent complete.
```

---

# 33. Performance Requirements

The semester screen should:

- Load quickly.
- Support unlimited semesters.
- Efficiently handle archived data.
- Avoid loading unnecessary relationships.

---

# 34. Testing Checklist

```
□ Create semester

□ Edit semester

□ Delete semester

□ Archive semester

□ Switch semesters

□ Duplicate semester

□ Empty state

□ Large semester history

□ Dark Mode

□ Dynamic Type

□ VoiceOver

□ Stage Manager
```

---

# 35. Final Semester Architecture

```
Semesters

↓

Academic Periods

↓

Courses

↓

Learning Data

↓

Historical Records
```

Semesters provide the foundation for organizing a student's entire academic journey inside StudyHub.