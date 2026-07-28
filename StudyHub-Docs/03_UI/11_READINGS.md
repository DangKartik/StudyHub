# READINGS

**Project:** StudyHub  
**Document:** 11_READINGS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Readings section manages all academic reading materials associated with courses.

It allows students to organize, track, and understand:

- Textbook chapters.
- Research papers.
- Articles.
- Lecture notes.
- Documentation.
- Reference materials.

Readings transform passive consumption into active learning.

---

# 2. Reading Philosophy

Traditional workflow:

```
Receive Reading

↓

Read Once

↓

Forget
```

StudyHub workflow:

```
Reading Added

↓

Track Progress

↓

Capture Insights

↓

Create Notes

↓

Generate Recall

↓

Master Concepts
```

---

# 3. User Goals

Users should be able to:

- Organize readings by course.
- Track reading progress.
- Save important resources.
- Take notes.
- Highlight important concepts.
- Create flashcards.
- Link readings to lectures and assignments.

---

# 4. Navigation Flow

Primary:

```
Sidebar

↓

Courses

↓

Course Detail

↓

Readings

↓

Reading Detail
```

---

Secondary:

```
Lecture Detail

↓

Related Reading

↓

Reading Detail
```

---

```
Assignment Detail

↓

Reference Material

↓

Reading Detail
```

---

# 5. Readings List Screen

Displays all readings inside a course.

Layout:

```
┌────────────────────────────────┐
│ Readings                +      │
├────────────────────────────────┤
│                                │
│ Chapter 5                      │
│ Algorithms                     │
│ 80% Complete                   │
│                                │
├────────────────────────────────┤
│                                │
│ Research Paper                 │
│ Machine Learning               │
│ Not Started                    │
│                                │
└────────────────────────────────┘
```

---

# 6. Reading Categories

Readings can be categorized.

Types:

```
Textbook

Research Paper

Article

Documentation

Reference

Lecture Material
```

---

# 7. Reading Card

Each reading appears as a card.

Displays:

```
Title

Type

Course

Progress

Estimated Time

Status
```

---

Example:

```
Chapter 7

Graph Algorithms

Textbook

65%

2 Hours Remaining
```

---

# 8. Reading Card Actions

Tap:

```
Open Reading Detail
```

---

Long press:

```
Open

Edit

Duplicate

Mark Complete

Delete
```

---

# 9. Create Reading

Users create readings manually.

Primary action:

```
+
```

---

Form:

```
Create Reading
```

---

# 10. Reading Fields

Required:

```
Title

Course
```

---

Optional:

```
Author

Type

Source

URL

File

Chapter

Pages

Estimated Time

Due Date

Description
```

---

# 11. Reading Example

Input:

```
Title:

Introduction to Graph Theory


Type:

Textbook Chapter


Pages:

25-50


Estimated Time:

2 Hours
```

---

Result:

```
Introduction to Graph Theory

Chapter 3

40% Complete
```

---

# 12. Reading Detail Page

Selecting a reading opens a dedicated page.

Navigation:

```
Reading List

↓

Reading Detail
```

---

Contains:

```
Overview

Content

Notes

Highlights

Concepts

Flashcards

Statistics
```

---

# 13. Reading Header

Displays:

```
Title

Author

Course

Type

Progress

Status
```

---

Example:

```
Graph Theory Fundamentals

Discrete Mathematics

Textbook

75%

In Progress
```

---

# 14. Header Actions

Actions:

```
Edit

Open File

Start Reading

Create Flashcards

More
```

---

# 15. Reading Progress

Tracks completion.

Methods:

```
Pages Completed

Sections Completed

Time Spent

Manual Progress
```

---

Example:

```
Pages:

35 / 50


Progress:

70%
```

---

# 16. Reading Viewer

Supports:

```
PDF

Web Articles

Documents

Markdown

Text
```

---

Features:

```
Zoom

Search

Bookmarks

Highlights

Annotations
```

---

# 17. Highlighting System

Users can highlight important information.

Highlight types:

```
Important

Definition

Example

Question

Review Later
```

---

Example:

```
Yellow:

Important Concept


Blue:

Definition
```

---

# 18. Notes Integration

Users can attach notes to readings.

Supports:

```
Typed Notes

Handwritten Notes

Images

Equations

Links
```

---

Relationship:

```
Reading

↓

Notes

↓

Concepts
```

---

# 19. Apple Pencil Support

Supports:

```
Handwriting

Highlighting

Drawing

Annotations
```

---

Workflow:

```
Open Reading

↓

Annotate

↓

Save

↓

Review Later
```

---

# 20. GoodNotes Integration

Optional external notebook connection.

Action:

```
Open in GoodNotes
```

---

Stores:

```
Notebook Reference

Reading Association
```

---

# 21. Concepts Extraction

Users can save important concepts.

Example:

```
Concepts:

Dynamic Programming

Memoization

Optimal Substructure
```

---

Concepts connect to:

```
Flashcards

Active Recall

Notes
```

---

# 22. Flashcard Integration

Users can create cards from readings.

Actions:

```
Create Flashcard

Generate Flashcards

Review Cards
```

---

Flashcards inherit:

```
Course

Reading

Topic Tags
```

---

# 23. Active Recall Integration

Users can create questions.

Types:

```
Definition

Explanation

Comparison

Application

Problem Solving
```

---

Example:

Question:

```
What is dynamic programming?
```

Answer:

```
A method for solving problems by storing subproblem results.
```

---

# 24. Reading Statistics

Tracks:

```
Reading Time

Completion Rate

Highlights Created

Notes Created

Flashcards Created
```

---

Example:

```
Reading Time:

3h 20m


Highlights:

25
```

---

# 25. Due Dates

Readings can have deadlines.

Example:

```
Read Chapter 8

Due Monday
```

---

Connected with:

```
Calendar

Notifications

Dashboard
```

---

# 26. Notifications

Options:

```
Reading Reminder

Due Date Reminder

Review Reminder
```

---

Example:

```
Complete Chapter 5 before tomorrow.
```

---

# 27. Search

Search readings by:

```
Title

Author

Concept

Highlight

Notes
```

---

Example:

Search:

```
Recursion
```

Results:

```
Chapter 4

Lecture Notes

Research Paper
```

---

# 28. Filtering

Filters:

```
Completed

Incomplete

Textbook

Research Paper

Articles

Due Soon
```

---

# 29. Sorting

Sort by:

```
Title

Date Added

Progress

Due Date

Recently Opened
```

---

# 30. Empty State

No readings:

```
No Readings Yet

Add textbooks, papers, or resources.

[Add Reading]
```

---

# 31. Loading State

Display:

- Reading card skeletons.
- Progress placeholders.
- File loading indicators.

---

# 32. Error State

Example:

```
Unable to load reading.

Retry
```

---

# 33. Toolbar

Toolbar:

```
Leading:

Back


Center:

Readings


Trailing:

+

Search

Filter
```

---

# 34. ViewModel Responsibilities

ReadingViewModel manages:

```
Load readings

Create reading

Update progress

Track highlights

Manage notes

Create flashcards

Sync resources
```

---

# 35. SwiftUI Structure

Recommended:

```
Features/

└── Readings/

    ├── ReadingsView.swift

    ├── ReadingCard.swift

    ├── ReadingDetailView.swift

    ├── ReadingViewer.swift

    ├── HighlightView.swift

    ├── ReadingFormView.swift

    └── ReadingViewModel.swift
```

---

# 36. Navigation Architecture

```
Course Detail

↓

Readings

↓

Reading Detail

↓

Learning Tools
```

---

# 37. Data Requirements

Models:

```
Reading

Course

Highlight

Note

Resource

Flashcard

ActiveRecallQuestion

StudySession
```

---

# 38. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduce Motion.

---

VoiceOver example:

```
Chapter 5.

Graph Algorithms.

70 percent complete.

25 highlights.
```

---

# 39. iPad Requirements

Optimized for:

## Landscape

Supports:

- Reading.
- Notes.
- Split workflow.

---

## Portrait

Supports:

- Focused reading.

---

## Apple Pencil

Supports:

- Annotation.
- Handwriting.
- Highlighting.

---

# 40. Performance Requirements

Reading system must:

- Handle large PDFs.
- Load documents efficiently.
- Cache reading progress.
- Sync annotations reliably.

---

# 41. Testing Checklist

```
□ Create reading

□ Edit reading

□ Track progress

□ Open document

□ Add highlights

□ Add notes

□ Create flashcards

□ GoodNotes integration

□ Apple Pencil support

□ Calendar reminders

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 42. Final Reading Architecture

```
Reading

        |

        ├── Content

        ├── Highlights

        ├── Notes

        ├── Concepts

        ├── Flashcards

        ├── Active Recall

        └── Statistics
```

Readings transform academic material into structured knowledge that students can understand, review, and retain.