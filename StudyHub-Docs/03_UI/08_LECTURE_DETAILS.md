# LECTURE DETAILS

**Project:** StudyHub  
**Document:** 08_LECTURE_DETAILS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Lecture Detail page is the dedicated learning workspace for a single lecture.

It transforms a lecture from a calendar event into an interactive learning environment.

A lecture detail page combines:

- Lecture information.
- Learning objectives.
- Concepts.
- Notes.
- Materials.
- Active recall.
- Flashcards.
- Review tracking.
- Study statistics.

---

# 2. Lecture Detail Philosophy

A lecture should represent the complete learning cycle:

```
Attend

↓

Understand

↓

Record

↓

Recall

↓

Review

↓

Master
```

StudyHub connects every stage inside one workspace.

---

# 3. Navigation Flow

Primary flow:

```
Sidebar

↓

Courses

↓

Course Detail

↓

Lectures

↓

Lecture Detail
```

---

Secondary flows:

```
Calendar

↓

Lecture Event

↓

Lecture Detail
```

---

```
Flashcards

↓

Related Lecture

↓

Lecture Detail
```

---

# 4. Lecture Detail Page Design

The Lecture Detail page opens as a dedicated full page.

It does NOT open as a split detail pane.

---

Landscape:

```
┌─────────────────────────────────────────────┐
│ ← Lectures     Lecture 05              More  │
├─────────────────────────────────────────────┤
│ Lecture Header                              │
├─────────────────────────────────────────────┤
│ Overview | Notes | Recall | Flashcards      │
├─────────────────────────────────────────────┤
│                                             │
│ Content Area                                │
│                                             │
└─────────────────────────────────────────────┘
```

---

# 5. Lecture Header

The header provides context.

Displays:

```
Lecture Number

Topic

Course

Date

Duration

Completion Status
```

---

Example:

```
Lecture 05

Binary Trees

SC302 Data Structures

15 September 2026

2 Hours

Reviewed
```

---

# 6. Header Actions

Available actions:

```
Edit Lecture

Mark Complete

Start Study Session

Open GoodNotes

More
```

---

# 7. Lecture Status

A lecture progresses through learning states.

---

## Not Started

User has not interacted.

```
○ Not Started
```

---

## Attended

Lecture completed.

```
✓ Attended
```

---

## Reviewed

Notes and recall completed.

```
✓ Reviewed
```

---

## Mastered

High recall confidence.

```
⭐ Mastered
```

---

# 8. Lecture Navigation Tabs

Internal navigation:

```
Overview

Notes

Materials

Active Recall

Flashcards

Statistics
```

---

The selected tab is preserved when returning.

---

# 9. Overview Tab

The default lecture landing page.

Purpose:

Provide a complete summary.

---

Contains:

```
Learning Objectives

Key Concepts

Lecture Summary

Quick Actions

Review Progress
```

---

# 10. Learning Objectives

Purpose:

Define expected outcomes.

---

Example:

```
By the end of this lecture:

• Understand binary search trees.

• Implement tree traversal.

• Analyze complexity.
```

---

Actions:

```
Add Objective

Edit Objective

Delete Objective
```

---

# 11. Key Concepts

Purpose:

Capture important academic ideas.

---

Example:

```
Concepts:

Binary Tree

Node

Root

Traversal

Recursion
```

---

Each concept can connect to:

```
Notes

Flashcards

Recall Questions
```

---

# 12. Lecture Summary

Users can write a short summary.

Supports:

```
Rich Text

Markdown

Images

Equations
```

---

Example:

```
Binary trees store hierarchical data.
Traversal methods include DFS and BFS.
```

---

# 13. Notes Workspace

Purpose:

Allow students to capture lecture notes.

---

Supports:

## Typed Notes

```
Rich Text Editor

Markdown

Code Blocks

Equations
```

---

## Handwritten Notes

Using:

```
Apple Pencil

CanvasKit

PDF Annotation
```

---

# 14. GoodNotes Integration

Each lecture can connect to external handwritten notes.

Action:

```
Open in GoodNotes
```

---

Stored information:

```
GoodNotes Notebook ID

Lecture Reference

Last Opened Date
```

---

Workflow:

```
Lecture Detail

↓

Open GoodNotes

↓

Write Notes

↓

Return to StudyHub

↓

Review Progress
```

---

# 15. Materials Section

Stores lecture resources.

Supported:

```
PDF

Slides

Documents

Images

Links
```

---

Each material displays:

```
File Name

Type

Size

Date Added
```

---

Actions:

```
Open

Preview

Share

Delete
```

---

# 16. Active Recall Section

Purpose:

Convert passive notes into learning.

---

Supported question types:

```
Question Answer

Fill Blank

Definition

Explain Concept

Diagram

Image Question
```

---

Example:

Question:

```
What is the complexity of binary search?
```

Answer:

```
O(log n)
```

---

# 17. Active Recall Progress

Displays:

```
Questions Created

Questions Completed

Accuracy

Weak Topics
```

---

Example:

```
Recall Accuracy

82%

15 Questions Reviewed
```

---

# 18. Flashcards Section

Lecture-specific flashcards.

---

Displays:

```
Cards Created

Cards Due

Review Accuracy

Last Review
```

---

Actions:

```
Start Review

Create Card

Generate Cards
```

---

# 19. Flashcard Creation

Users can create:

```
Front

Back

Image

Equation

Tags
```

---

Example:

```
Front:

What is polymorphism?


Back:

Ability of objects to take multiple forms.
```

---

# 20. AI Assistance

Optional AI features.

Actions:

```
Summarize Lecture

Generate Flashcards

Generate Questions

Explain Concept
```

---

Example:

Input:

```
Lecture Notes
```

Output:

```
10 Flashcards

5 Recall Questions

Summary
```

---

# 21. Review System

The lecture tracks review activity.

Metrics:

```
Last Reviewed

Review Count

Recall Accuracy

Mastery Level
```

---

# 22. Study Session Integration

Users can start focused study.

Action:

```
Start Study Session
```

---

Creates:

```
Study Session

↓

Lecture Reference

↓

Statistics Update
```

---

# 23. Statistics Tab

Displays:

```
Time Spent

Review Frequency

Recall Accuracy

Flashcards Created

Completion Status
```

---

Example:

```
Total Study Time:

4h 30m


Recall Accuracy:

86%
```

---

# 24. Calendar Integration

Lecture details connect with calendar events.

Displays:

```
Lecture Time

Location

Reminder
```

---

Actions:

```
Edit Calendar Event

Add Reminder
```

---

# 25. Notifications

Supported reminders:

```
Before Lecture

After Lecture

Review Reminder

Flashcard Reminder
```

---

Example:

```
Review Lecture 05 tomorrow.
```

---

# 26. Empty States

## No Notes

```
No Notes Yet

Start writing notes for this lecture.

[Create Note]
```

---

## No Flashcards

```
No Flashcards Yet

Create cards to improve recall.
```

---

## No Materials

```
No Materials Added

Attach slides or resources.
```

---

# 27. Loading States

Display:

- Lecture header skeleton.
- Content placeholders.
- Loading cards.

---

# 28. Error States

Example:

```
Unable to load lecture.

Retry
```

---

# 29. Toolbar

Toolbar:

```
Leading:

Back


Center:

Lecture Topic


Trailing:

+

Search

More
```

---

# 30. Context Menu

Long press:

```
Edit Lecture

Duplicate

Create Flashcards

Export Notes

Delete
```

---

# 31. Search

Search inside lecture:

```
Notes

Concepts

Materials

Questions

Flashcards
```

---

# 32. ViewModel Responsibilities

LectureDetailViewModel manages:

```
Load lecture

Update content

Manage notes

Create recall questions

Create flashcards

Track progress

Sync integrations
```

---

# 33. SwiftUI Structure

Recommended:

```
Features/

└── LectureDetail/

    ├── LectureDetailView.swift

    ├── LectureHeaderView.swift

    ├── LectureOverviewView.swift

    ├── LectureNotesView.swift

    ├── LectureMaterialsView.swift

    ├── ActiveRecallView.swift

    ├── FlashcardsView.swift

    └── LectureDetailViewModel.swift
```

---

# 34. Navigation Architecture

```
Course Detail

↓

Lecture List

↓

Lecture Detail

↓

Learning Components
```

---

# 35. Data Requirements

Models:

```
Lecture

Course

Note

Resource

Flashcard

ActiveRecallQuestion

StudySession

ReviewHistory
```

---

# 36. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduced Motion.

---

VoiceOver example:

```
Lecture 5.

Binary Trees.

Reviewed.

15 flashcards available.
```

---

# 37. iPad Requirements

Optimized for:

## Landscape

Supports:

- Reading.
- Notes.
- Multi-window workflows.

---

## Portrait

Supports:

- Scrolling.
- Single content focus.

---

## Apple Pencil

Supports:

- Handwriting.
- Annotation.
- Drawing.

---

# 38. Performance Requirements

The Lecture Detail page must:

- Load content lazily.
- Handle large PDFs.
- Support long notes.
- Sync efficiently.
- Avoid unnecessary model loading.

---

# 39. Testing Checklist

```
□ Open lecture

□ Edit lecture

□ Add objectives

□ Add concepts

□ Write notes

□ Open GoodNotes

□ Add materials

□ Create recall questions

□ Create flashcards

□ Start study session

□ Track progress

□ Dark Mode

□ Dynamic Type

□ VoiceOver

□ Apple Pencil
```

---

# 40. Final Lecture Detail Architecture

```
Lecture Detail

        |

        ├── Overview

        ├── Notes

        ├── Materials

        ├── Active Recall

        ├── Flashcards

        ├── Study Sessions

        └── Statistics
```

The Lecture Detail page is the core learning environment where academic content becomes active knowledge.