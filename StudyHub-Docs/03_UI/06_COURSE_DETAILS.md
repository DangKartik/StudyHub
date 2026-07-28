# COURSE DETAILS

**Project:** StudyHub  
**Document:** 06_COURSE_DETAILS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Course Detail page is the central workspace for a specific academic course.

It provides a complete overview of everything related to one course:

- Course information
- Lectures
- Assignments
- Readings
- Tutorials
- Labs
- Exams
- Grades
- Flashcards
- Notes
- Resources
- Statistics

The Course Detail page is the student's dedicated workspace for managing and studying a course.

---

# 2. Course Detail Philosophy

A course should feel like a digital academic notebook.

Instead of opening different apps:

```
Calendar

Notes App

Flashcard App

File Manager

Grade Spreadsheet
```

StudyHub connects everything:

```
Course

↓

Learning Materials

↓

Study Activities

↓

Performance Tracking
```

---

# 3. Navigation Flow

Entry:

```
Sidebar

↓

Courses

↓

Course List

↓

Course Detail
```

---

Related navigation:

```
Dashboard

↓

Assignment Card

↓

Course Detail


Calendar

↓

Lecture Event

↓

Course Detail
```

---

# 4. Course Detail Layout

The Course Detail page is a dedicated full-page view.

It does NOT use a permanent detail pane.

---

Landscape layout:

```
┌─────────────────────────────────────────────┐
│ ← Courses        SC302                 More  │
├─────────────────────────────────────────────┤
│                                             │
│ Course Header                               │
│                                             │
├─────────────────────────────────────────────┤
│ Overview | Lectures | Assignments | Notes   │
├─────────────────────────────────────────────┤
│                                             │
│ Selected Content                            │
│                                             │
└─────────────────────────────────────────────┘
```

---

# 5. Course Header

The top section provides important information.

---

Displays:

```
Course Code

Course Name

Instructor

Semester

Progress

Current Grade
```

---

Example:

```
SC302

Data Structures

Dr. Zhang

Fall 2026

Progress: 72%

Current Grade: A-
```

---

# 6. Course Header Actions

Toolbar actions:

```
Edit Course

Add Content

Search Course

More Options
```

---

# 7. Course Navigation Tabs

The Course Detail page uses internal navigation.

Tabs:

```
Overview

Lectures

Assignments

Readings

Tutorials

Labs

Exams

Grades

Flashcards

Notes

Resources

Statistics
```

---

The selected tab remains persistent.

---

# 8. Overview Tab

The default landing page.

Purpose:

Provide a course summary.

---

Contains:

```
Upcoming Events

Course Progress

Recent Activity

Study Recommendation

Quick Actions
```

---

# 9. Upcoming Events Section

Displays:

```
Assignments

Lectures

Quizzes

Exams

Readings
```

---

Example:

```
Upcoming:

Assignment 2

Due Friday


Quiz 3

In 8 days
```

---

# 10. Course Progress Section

Displays completion status.

Metrics:

```
Lectures Completed

Assignments Completed

Readings Completed

Flashcards Reviewed

Study Hours
```

---

Example:

```
Course Progress

████████░░

80%
```

---

# 11. Grade Summary

Displays current academic performance.

Contains:

```
Current Grade

Weighted Grade

Remaining Assessments

Required Score
```

---

Example:

```
Current Grade

84%


Final Exam Needed:

70%
```

---

# 12. Quick Actions

Provides fast creation.

Actions:

```
+ Add Lecture

+ Add Assignment

+ Add Reading

+ Create Flashcards

+ Start Study Session

+ Add Note
```

---

# 13. Lectures Section

Purpose:

Manage all course lectures.

---

Displays:

```
Lecture Number

Date

Topic

Completion Status
```

---

Example:

```
Lecture 05

Trees and Graphs

Completed
```

---

Actions:

```
Open Lecture

Mark Complete

Create Flashcards
```

---

# 14. Assignments Section

Purpose:

Manage course assignments.

---

Displays:

```
Assignment Name

Due Date

Progress

Status

Grade
```

---

Example:

```
Assignment 2

Due Friday

70% Complete

Not Submitted
```

---

# 15. Readings Section

Purpose:

Track course materials.

---

Displays:

```
Reading Title

Pages

Progress

Due Date
```

---

Example:

```
Chapter 5

45 / 60 pages

75%
```

---

# 16. Tutorials and Labs

Separate sections for practical coursework.

---

Tutorial:

```
Tutorial Sessions

Questions

Solutions

Notes
```

---

Labs:

```
Lab Sessions

Instructions

Submission

Results
```

---

# 17. Exams Section

Purpose:

Track assessments.

---

Displays:

```
Exam Name

Date

Countdown

Preparation Progress
```

---

Example:

```
Final Exam

12 Days Remaining

Preparation:
65%
```

---

# 18. Grades Section

Connects to Grade Tracker.

Displays:

```
Grade Breakdown

Weight Distribution

Assessment Scores

Predicted Grade
```

---

Example:

```
Assignments

30%

Quizzes

20%

Final Exam

50%
```

---

# 19. Flashcards Section

Course-specific learning system.

Contains:

```
Flashcard Decks

Cards Due

Accuracy

Review History
```

---

Actions:

```
Start Review

Create Cards

Generate Cards
```

---

# 20. Notes Section

Course notes workspace.

Supports:

```
Typed Notes

Handwritten Notes

Apple Pencil

PDF Annotations

GoodNotes Links
```

---

# 21. Resources Section

Central course file library.

Supports:

```
PDFs

Slides

Links

Documents

Images
```

---

Actions:

```
Open

Preview

Share

Organize
```

---

# 22. Statistics Section

Course analytics.

Displays:

```
Study Hours

Accuracy

Completion Rate

Grade Trend

Learning Progress
```

---

# 23. Course Search

Search only within this course.

Search:

```
Lectures

Assignments

Notes

Flashcards

Resources
```

---

Example:

Search:

```
Binary Tree
```

Results:

```
Lecture 5

Flashcard Deck

Notes
```

---

# 24. Empty States

Example:

No lectures:

```
No Lectures Added

Add your first lecture.

[Add Lecture]
```

---

No flashcards:

```
No Flashcards Yet

Create cards to start active recall.
```

---

# 25. Loading States

Use:

- Skeleton course header.
- Placeholder cards.
- Loading progress indicators.

---

# 26. Error States

Example:

```
Unable to load course data.

Retry
```

---

# 27. Context Menu

Long press course:

```
Edit Course

Archive

Duplicate

Share

Delete
```

---

# 28. Toolbar

Toolbar:

```
Leading:

Back to Courses


Center:

Course Name


Trailing:

+

Search

More
```

---

# 29. Course Settings

Accessible through:

```
More

↓

Course Settings
```

---

Options:

```
Rename Course

Change Color

Manage Notifications

Manage Integrations

Archive Course
```

---

# 30. GoodNotes Integration

Each course can link to a GoodNotes notebook.

Course action:

```
Open Notebook
```

---

Example:

```
SC302 Notebook

↓

GoodNotes
```

---

# 31. Calendar Integration

Course events appear in calendar.

Connected items:

```
Lectures

Labs

Tutorials

Exams
```

---

# 32. Data Requirements

Required models:

```
Course

Semester

Lecture

Assignment

Reading

Exam

Grade

FlashcardDeck

Note

Resource

StudySession
```

---

# 33. ViewModel Responsibilities

CourseDetailViewModel manages:

```
Load course data

Calculate progress

Fetch upcoming events

Manage tabs

Update course information

Generate recommendations
```

---

# 34. SwiftUI Structure

Recommended:

```
Features/

└── CourseDetail/

    ├── CourseDetailView.swift

    ├── CourseHeaderView.swift

    ├── CourseTabView.swift

    ├── CourseOverviewView.swift

    ├── CourseProgressCard.swift

    ├── CourseQuickActions.swift

    └── CourseDetailViewModel.swift
```

---

# 35. Navigation Architecture

Implementation:

```
NavigationStack

↓

CourseDetailView

↓

Internal Tab Navigation

↓

Feature Screens
```

---

# 36. Accessibility Requirements

Support:

- VoiceOver
- Dynamic Type
- Keyboard navigation
- Reduced Motion

---

Example:

VoiceOver:

```
SC302 Data Structures.

Progress 72 percent.

Current grade A minus.
```

---

# 37. iPad Requirements

Optimized for:

## Landscape

Primary mode.

Supports:

- Side-by-side sections.
- Keyboard workflows.
- Apple Pencil notes.

---

## Portrait

Supports:

- Vertical scrolling.
- Tab navigation.

---

## Stage Manager

Must resize gracefully.

---

# 38. Performance Requirements

The Course Detail page must:

- Load sections lazily.
- Avoid loading unnecessary relationships.
- Support large courses.
- Cache frequently accessed data.

---

# 39. Testing Checklist

```
□ Open course

□ Navigate tabs

□ Add content

□ Edit course

□ GoodNotes connection

□ Calendar integration

□ Empty states

□ Large course data

□ Dark Mode

□ Dynamic Type

□ VoiceOver

□ Stage Manager
```

---

# 40. Final Course Detail Architecture

```
Course Detail

        |

        ├── Overview

        ├── Lectures

        ├── Assignments

        ├── Readings

        ├── Grades

        ├── Flashcards

        ├── Notes

        ├── Resources

        └── Statistics
```

The Course Detail page is the core academic workspace of StudyHub, connecting organization, learning, and performance tracking into one unified course environment.