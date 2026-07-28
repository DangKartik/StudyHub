# LECTURES

**Project:** StudyHub  
**Document:** 07_LECTURES.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Lectures section manages all lecture-related academic content inside a course.

A lecture is the fundamental learning unit in StudyHub.

Each lecture connects:

- Schedule information.
- Learning objectives.
- Course materials.
- Personal notes.
- Active recall.
- Flashcards.
- Resources.
- Study progress.

The goal is to transform a passive lecture record into an interactive learning workspace.

---

# 2. Lecture Philosophy

A lecture should represent the complete learning experience.

Traditional workflow:

```
Attend Lecture

↓

Take Notes

↓

Review Slides

↓

Create Flashcards

↓

Study Separately
```

StudyHub workflow:

```
Lecture

↓

Notes

↓

Concepts

↓

Active Recall

↓

Flashcards

↓

Review
```

---

# 3. User Goals

Users should be able to:

- Create lectures manually.
- Track lecture schedules.
- Organize lecture materials.
- Take notes.
- Review concepts.
- Generate flashcards.
- Track completion.
- Connect lectures with calendar events.

---

# 4. Navigation Flow

Entry:

```
Sidebar

↓

Courses

↓

Course Detail

↓

Lectures
```

---

Alternative:

```
Calendar

↓

Lecture Event

↓

Lecture Detail
```

---

# 5. Lectures List Screen

The Lectures screen displays all lectures for a course.

Layout:

```
┌─────────────────────────────────┐
│ Lectures                 +      │
├─────────────────────────────────┤
│                                 │
│ Lecture 01                      │
│ Introduction to Algorithms      │
│ Aug 15                          │
│ Completed                       │
│                                 │
├─────────────────────────────────┤
│ Lecture 02                      │
│ Arrays and Lists                │
│ Aug 22                          │
│ Not Reviewed                    │
│                                 │
└─────────────────────────────────┘
```

---

# 6. Lecture Organization

Lectures are organized by:

```
Date

Lecture Number

Topic

Completion Status
```

---

Sorting options:

```
Newest First

Oldest First

Upcoming

Incomplete
```

---

# 7. Lecture Card

Each lecture appears as a card.

Displays:

```
Lecture Number

Topic

Date

Duration

Completion Status

Review Status
```

---

Example:

```
Lecture 05

Binary Trees

15 September

2 Hours

Completed

Flashcards Due
```

---

# 8. Lecture Card Actions

Tap:

```
Open Lecture Detail
```

---

Long press:

```
Open

Edit

Duplicate

Create Flashcards

Delete
```

---

# 9. Create Lecture

Users manually create lectures.

Primary action:

```
+
```

---

Form:

```
Create Lecture
```

---

# 10. Lecture Fields

Required:

```
Topic

Date
```

---

Optional:

```
Lecture Number

Start Time

End Time

Location

Professor

Description

Objectives
```

---

# 11. Lecture Example

Input:

```
Lecture Number:

05


Topic:

Binary Trees


Date:

15 September


Duration:

2 Hours
```

---

Result:

```
Lecture 05

Binary Trees

15 September

2 Hours
```

---

# 12. Lecture Detail Page

Selecting a lecture opens a dedicated page.

Navigation:

```
Lectures List

↓

Lecture Detail
```

---

The Lecture Detail page contains:

```
Overview

Objectives

Concepts

Materials

Notes

Active Recall

Flashcards

Resources

Statistics
```

---

# 13. Lecture Header

Displays:

```
Lecture Number

Topic

Date

Course

Completion Status
```

---

Example:

```
Lecture 05

Binary Trees

SC302

Completed
```

---

# 14. Lecture Actions

Toolbar actions:

```
Edit

Mark Complete

Start Review

Create Flashcards

Open Notes
```

---

# 15. Learning Objectives

Purpose:

Define what the student should learn.

---

Example:

```
Learning Objectives:

• Understand tree traversal.

• Implement binary search trees.

• Analyze complexity.
```

---

Users can:

```
Add Objective

Edit Objective

Delete Objective
```

---

# 16. Key Concepts

Purpose:

Capture important ideas.

---

Example:

```
Key Concepts:

Binary Tree

Node

Traversal

Recursion
```

---

Each concept can link to:

```
Flashcards

Notes

Active Recall Questions
```

---

# 17. Lecture Materials

Supports:

```
Slides

PDFs

Images

Documents

Links
```

---

Actions:

```
Open

Preview

Annotate

Share
```

---

# 18. Apple Pencil Notes

Lecture supports handwritten notes.

Features:

```
Handwriting

Drawing

Highlighting

Annotations
```

---

Compatible with:

```
Apple Pencil

PDF Markup

GoodNotes
```

---

# 19. GoodNotes Integration

Each lecture can connect to GoodNotes.

Action:

```
Open in GoodNotes
```

---

Example:

```
SC302

Lecture 05 Notes

↓

GoodNotes Notebook
```

---

StudyHub stores:

```
Notebook Reference

Lecture Association
```

---

# 20. Personal Notes

Users can create notes inside StudyHub.

Supports:

```
Rich Text

Markdown

Images

Equations

Code Blocks
```

---

Notes are linked:

```
Lecture

↓

Notes

↓

Concepts
```

---

# 21. Active Recall Integration

Every lecture includes active recall.

Users can create:

```
Question Answer

Fill Blank

Definition

Explain Concept

Diagram Question
```

---

Example:

Question:

```
What is the time complexity of binary search?
```

Answer:

```
O(log n)
```

---

# 22. Flashcard Integration

Users can create flashcards from lecture content.

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

Lecture

Topic Tags
```

---

# 23. Lecture Completion Tracking

A lecture can have states:

```
Not Started

Attended

Reviewed

Mastered
```

---

Progress:

```
Attendance

↓

Notes

↓

Recall

↓

Mastery
```

---

# 24. Lecture Statistics

Displays:

```
Time Spent

Review Count

Flashcards Created

Recall Accuracy
```

---

Example:

```
Study Time:

3 Hours


Recall Accuracy:

82%
```

---

# 25. Calendar Integration

Lectures can sync with calendars.

Supported:

```
Apple Calendar

Google Calendar
```

---

Calendar event:

```
Lecture Topic

Time

Location

Course
```

---

# 26. Notifications

Users can enable:

```
Lecture Reminder

Preparation Reminder

Review Reminder
```

---

Example:

```
SC302 Lecture starts in 30 minutes.
```

---

# 27. Empty State

No lectures:

```
No Lectures Yet

Add lectures to organize your course schedule.

[Add Lecture]
```

---

# 28. Loading State

Display:

- Lecture card skeletons.
- Placeholder timeline.
- Loading indicators.

---

# 29. Error State

Example:

```
Unable to load lectures.

Retry
```

---

# 30. Search

Search inside lectures:

```
Topic

Concept

Notes

Materials
```

---

Example:

Search:

```
Recursion
```

Results:

```
Lecture 4

Lecture Notes

Flashcards
```

---

# 31. Toolbar

Toolbar:

```
Leading:

Back


Center:

Lectures


Trailing:

+

Search

Filter
```

---

# 32. Filtering

Filters:

```
Completed

Incomplete

Reviewed

Not Reviewed

Upcoming
```

---

# 33. ViewModel Responsibilities

LectureViewModel manages:

```
Load lectures

Create lecture

Update lecture

Delete lecture

Track progress

Create flashcards

Sync calendar
```

---

# 34. SwiftUI Structure

Recommended:

```
Features/

└── Lectures/

    ├── LecturesView.swift

    ├── LectureCard.swift

    ├── LectureDetailView.swift

    ├── LectureFormView.swift

    ├── LectureMaterialsView.swift

    └── LectureViewModel.swift
```

---

# 35. Navigation Architecture

Flow:

```
Course Detail

↓

Lectures

↓

Lecture Detail

↓

Learning Tools
```

---

# 36. Data Requirements

Models:

```
Lecture

Course

Note

Resource

Flashcard

ActiveRecallQuestion

StudySession
```

---

# 37. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduce Motion.

---

VoiceOver example:

```
Lecture 5.

Binary Trees.

Completed.

Two hours duration.
```

---

# 38. iPad Requirements

Optimized for:

## Landscape

Supports:

- Lecture list.
- Detail navigation.
- Notes workflow.

---

## Portrait

Supports:

- Single column reading.

---

## Apple Pencil

Supports:

- Handwritten notes.
- PDF annotation.
- Drawing.

---

# 39. Performance Requirements

The lecture system must:

- Support hundreds of lectures.
- Load materials lazily.
- Cache frequently accessed lectures.
- Sync efficiently through iCloud.

---

# 40. Testing Checklist

```
□ Create lecture

□ Edit lecture

□ Delete lecture

□ Mark completion

□ Add objectives

□ Add notes

□ Create flashcards

□ GoodNotes integration

□ Calendar sync

□ Apple Pencil support

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 41. Final Lecture Architecture

```
Course

↓

Lecture

↓

Learning Content

    ├── Notes

    ├── Materials

    ├── Active Recall

    ├── Flashcards

    └── Statistics
```

Lectures are the bridge between academic organization and active learning inside StudyHub.