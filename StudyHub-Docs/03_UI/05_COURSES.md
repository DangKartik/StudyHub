# COURSES

**Project:** StudyHub  
**Document:** 05_COURSES.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Courses screen is the central academic organization area of StudyHub.

It allows users to manage all courses inside a semester.

A course acts as the primary container for academic information:

- Lectures
- Assignments
- Readings
- Labs
- Tutorials
- Exams
- Grades
- Flashcards
- Notes
- Resources
- Statistics

---

# 2. Course Philosophy

StudyHub treats a course as an academic workspace.

Instead of separating information across multiple apps:

```
Calendar

Notes

Flashcards

Files

Grades
```

everything is connected through the course.

---

# 3. User Goals

Users should be able to:

- View all courses in a semester.
- Create courses manually.
- Edit course information.
- Access course workspaces.
- Track progress.
- Monitor grades.
- Organize resources.

---

# 4. Navigation Flow

Entry:

```
Sidebar

↓

Courses

↓

Semester Selection

↓

Course List

↓

Course Detail
```

---

# 5. Courses Screen Overview

The Courses screen displays all courses belonging to the selected semester.

Layout:

```
┌───────────────────────────────────┐
│ Fall 2026                 +       │
├───────────────────────────────────┤
│                                   │
│ Courses                           │
│                                   │
│ ┌───────────────┐                 │
│ │ SC302         │                 │
│ │ Data Structures│                │
│ │ Progress 70%  │                 │
│ └───────────────┘                 │
│                                   │
│ ┌───────────────┐                 │
│ │ SC2002        │                 │
│ │ OOP           │                 │
│ │ Progress 55%  │                 │
│ └───────────────┘                 │
│                                   │
└───────────────────────────────────┘
```

---

# 6. Course List Layout

The course list supports multiple layouts.

Default:

```
Grid View
```

---

Optional:

```
List View
```

---

# 7. Grid View

Designed for iPad landscape.

Example:

```
┌──────────┐ ┌──────────┐ ┌──────────┐
│ SC302    │ │ SC2002   │ │ MH1812   │
│          │ │          │ │          │
│ Progress │ │ Progress │ │ Progress │
└──────────┘ └──────────┘ └──────────┘
```

---

# 8. List View

Compact view.

Example:

```
SC302
Data Structures
Dr. Zhang

SC2002
Object Oriented Design
Prof. Lee
```

---

# 9. Course Card

Each course is represented by a card.

---

Displays:

```
Course Code

Course Name

Instructor

Progress

Upcoming Deadline

Grade

Color Identifier
```

---

Example:

```
SC302

Data Structures

Dr. Zhang

Progress:
75%

Next:
Assignment 2

Grade:
A-
```

---

# 10. Course Card Actions

Tap:

```
Open Course Detail
```

---

Long press:

```
Open

Edit

Duplicate

Archive

Delete
```

---

# 11. Add Course

Users create courses manually.

Primary action:

```
+
```

---

Form:

```
Create Course
```

---

# 12. Course Fields

Required:

```
Course Name

Course Code
```

---

Optional:

```
Instructor

Instructor Email

Office Hours

Credits / AU

Color

Description
```

---

# 13. Course Creation Example

Input:

```
Course Name:

Object Oriented Design


Course Code:

SC2002


Instructor:

Dr. Zhang


Credits:

3 AU
```

---

Result:

```
SC2002

Object Oriented Design

3 AU
```

---

# 14. Course Detail Navigation

Selecting a course opens a dedicated page.

Flow:

```
Course List

↓

Course Detail Page
```

---

The course detail page contains:

```
Overview

Lectures

Assignments

Readings

Labs

Tutorials

Exams

Grades

Flashcards

Notes

Resources

Statistics
```

---

# 15. Course Progress

Each course tracks progress.

Metrics:

```
Assignments Completed

Lectures Completed

Readings Completed

Flashcards Reviewed

Study Hours
```

---

Example:

```
Course Progress

████████░░

75%
```

---

# 16. Course Status

Courses can have states:

```
Active

Completed

Archived
```

---

Default:

```
Active
```

---

# 17. Course Color System

Users can assign colors.

Purpose:

- Calendar identification.
- Visual organization.
- Quick recognition.

---

Example:

```
SC302

Blue
```

---

Color must support:

- Dark Mode.
- Accessibility.
- High contrast.

---

# 18. Course Sorting

Users can sort by:

```
Name

Code

Progress

Upcoming Deadline

Grade

Recently Opened
```

---

# 19. Course Filtering

Filters:

```
Current Semester

Archived

Completed

Low Progress

Upcoming Deadlines
```

---

# 20. Search

Search courses by:

```
Course Name

Course Code

Instructor
```

---

Example:

Search:

```
SC302
```

Result:

```
Data Structures
```

---

# 21. Empty State

When no courses exist:

```
No Courses Yet

Add your first course
to begin organizing your semester.

[Add Course]
```

---

# 22. Loading State

Display:

- Course card skeletons.
- Placeholder progress rings.
- Loading indicators.

---

# 23. Error State

Example:

```
Unable to load courses.

Please try again.
```

---

# 24. Toolbar

Toolbar:

```
Leading:

Sidebar


Center:

Courses


Trailing:

+

Search

Filter
```

---

# 25. Quick Add Menu

The + button provides:

```
Add Course

Import Calendar Schedule

Create Template
```

---

# 26. Context Menu

Long press:

```
Open Course

Edit

Duplicate

Archive

Delete
```

---

# 27. Keyboard Shortcuts

Supported:

Create Course:

```
⌘ + N
```

Search:

```
⌘ + F
```

---

# 28. Course Detail Deep Links

Users can access:

```
Dashboard

↓

Upcoming Assignment

↓

Course Detail
```

---

# 29. Data Requirements

Required models:

```
Semester

Course

Assignment

Lecture

Reading

Grade

Flashcard

Resource

StudySession
```

---

# 30. ViewModel Responsibilities

CoursesViewModel manages:

```
Load courses

Create course

Update course

Delete course

Filter courses

Sort courses

Calculate progress
```

---

# 31. SwiftUI Structure

Recommended:

```
Features/

└── Courses/

    ├── CoursesView.swift

    ├── CourseCard.swift

    ├── CourseGridView.swift

    ├── CourseListView.swift

    ├── CourseFormView.swift

    └── CoursesViewModel.swift
```

---

# 32. Accessibility Requirements

Course cards must provide:

Example:

```
SC302 Data Structures.

Progress 75 percent.

Next assignment due Friday.
```

---

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduce Motion.

---

# 33. iPad Requirements

Courses screen supports:

## Landscape

Optimized for:

- Multi-column grids.
- Keyboard workflows.
- Large displays.

---

## Portrait

Optimized for:

- Vertical course list.
- Quick browsing.

---

## Stage Manager

Must resize dynamically.

---

# 34. Performance Requirements

The Courses screen must:

- Support unlimited courses.
- Load efficiently.
- Avoid unnecessary relationship loading.
- Use SwiftData queries efficiently.

---

# 35. Testing Checklist

```
□ Create course

□ Edit course

□ Delete course

□ Archive course

□ Search courses

□ Filter courses

□ Sort courses

□ Empty state

□ Dark Mode

□ Dynamic Type

□ VoiceOver

□ Stage Manager

□ Large number of courses
```

---

# 36. Final Course Architecture

```
Semester

↓

Courses

↓

Course Workspace

↓

Academic Activities

    ├── Lectures

    ├── Assignments

    ├── Readings

    ├── Notes

    ├── Flashcards

    └── Grades
```

Courses are the core academic containers in StudyHub and connect every learning activity into one unified workspace.