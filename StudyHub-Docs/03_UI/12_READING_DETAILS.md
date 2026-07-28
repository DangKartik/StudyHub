# READING DETAILS

**Project:** StudyHub  
**Document:** 12_READING_DETAILS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Reading Detail page is the dedicated learning workspace for a single academic reading.

It allows students to actively engage with learning material instead of simply storing files.

The Reading Detail page combines:

- Reading content.
- Progress tracking.
- Highlights.
- Notes.
- Concepts.
- Active recall.
- Flashcards.
- Study analytics.

---

# 2. Reading Detail Philosophy

Reading should become knowledge.

Traditional workflow:

```
Open PDF

↓

Read Pages

↓

Close File

↓

Forget
```

StudyHub workflow:

```
Read

↓

Understand

↓

Highlight

↓

Capture Concepts

↓

Create Recall

↓

Review

↓

Master
```

---

# 3. Navigation Flow

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

# 4. Reading Detail Page Design

The Reading Detail page opens as a dedicated full page.

It does NOT use a permanent detail pane.

---

Landscape:

```
┌─────────────────────────────────────────┐
│ ← Readings     Chapter 5           More │
├─────────────────────────────────────────┤
│ Reading Header                          │
├─────────────────────────────────────────┤
│ Content | Notes | Highlights | Recall   │
├─────────────────────────────────────────┤
│                                         │
│ Reading Workspace                       │
│                                         │
└─────────────────────────────────────────┘
```

---

# 5. Reading Header

Displays:

```
Reading Title

Course

Author

Type

Progress

Status
```

---

Example:

```
Introduction to Algorithms

SC302

Textbook Chapter

75%

In Progress
```

---

# 6. Header Actions

Available actions:

```
Edit Reading

Open File

Start Reading Session

Create Flashcards

More
```

---

# 7. Reading Navigation Tabs

Internal navigation:

```
Overview

Content

Notes

Highlights

Concepts

Active Recall

Flashcards

Statistics
```

---

# 8. Overview Tab

Default landing page.

Purpose:

Provide reading summary.

---

Contains:

```
Reading Information

Progress

Objectives

Key Concepts

Quick Actions
```

---

# 9. Reading Information

Displays:

```
Author

Source

Pages

Estimated Time

Due Date
```

---

Example:

```
Pages:

45-80


Estimated Time:

3 Hours


Due:

Monday
```

---

# 10. Reading Objectives

Purpose:

Define what the student should understand.

---

Example:

```
Objectives:

• Understand graph traversal.

• Learn BFS and DFS.

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

# 11. Reading Viewer

The main reading environment.

Supports:

```
PDF

Documents

Web Articles

Markdown

Text Files
```

---

Features:

```
Search

Zoom

Bookmarks

Highlights

Annotations

Page Navigation
```

---

# 12. Progress Tracking

Progress can be measured by:

```
Pages Completed

Sections Completed

Reading Time

Manual Progress
```

---

Example:

```
Pages:

60 / 100


Progress:

60%
```

---

# 13. Reading Sessions

Users can start focused reading.

Action:

```
Start Reading Session
```

---

Creates:

```
Study Session

↓

Reading Reference

↓

Time Tracking

↓

Statistics Update
```

---

# 14. Highlights System

Students can highlight important content.

Highlight categories:

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

Important


Blue:

Definition
```

---

# 15. Highlight Actions

Users can:

```
Create Highlight

Add Note

Convert to Flashcard

Create Question

Delete Highlight
```

---

# 16. Notes Workspace

Users can attach notes to readings.

Supports:

```
Rich Text

Markdown

Images

Equations

Code Blocks
```

---

Relationship:

```
Reading

↓

Notes

↓

Concepts

↓

Flashcards
```

---

# 17. Handwritten Notes

Supports:

```
Apple Pencil

Drawing

Handwriting

Annotation
```

---

Workflow:

```
Read

↓

Annotate

↓

Save

↓

Review
```

---

# 18. GoodNotes Integration

Optional external notebook support.

Action:

```
Open in GoodNotes
```

---

Stores:

```
Notebook Reference

Reading Association

Last Opened
```

---

# 19. Concept Extraction

Students can create concepts from readings.

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
Notes

Flashcards

Active Recall
```

---

# 20. Active Recall Section

Purpose:

Convert reading material into understanding.

---

Question Types:

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
What is memoization?
```

Answer:

```
Caching previous results to avoid repeated computation.
```

---

# 21. Flashcards Section

Reading-specific flashcards.

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

# 22. AI Assistance

Optional AI features.

Actions:

```
Summarize Reading

Generate Flashcards

Generate Recall Questions

Explain Difficult Concepts
```

---

Example:

Input:

```
Research Paper
```

Output:

```
Summary

Key Concepts

Flashcards

Questions
```

---

# 23. Bookmarks

Users can save important locations.

Bookmark stores:

```
Page Number

Title

Note
```

---

Example:

```
Page 42

Important Algorithm Explanation
```

---

# 24. Search

Search within reading:

```
Text

Highlights

Notes

Concepts

Flashcards
```

---

Example:

Search:

```
Recursion
```

Results:

```
Page 24

Highlight

Flashcard
```

---

# 25. Reading Statistics

Tracks:

```
Reading Time

Pages Read

Highlights Created

Notes Created

Flashcards Created

Review Accuracy
```

---

Example:

```
Reading Time:

4h 30m


Highlights:

35
```

---

# 26. Calendar Integration

Readings can have deadlines.

Calendar event:

```
Reading Title

Due Date

Course

Reminder
```

---

Supported:

```
Apple Calendar

Google Calendar
```

---

# 27. Notifications

Users can enable:

```
Reading Reminder

Due Date Reminder

Review Reminder
```

---

Example:

```
Complete Chapter 6 before tomorrow.
```

---

# 28. Empty States

## No Content

```
No Reading Material

Add a file or link to begin.
```

---

## No Notes

```
No Notes Yet

Capture your understanding here.
```

---

## No Highlights

```
No Highlights Yet

Highlight important concepts while reading.
```

---

# 29. Loading States

Display:

- Reading header skeleton.
- Document loading indicator.
- Placeholder content.

---

# 30. Error States

Example:

```
Unable to load reading.

Retry
```

---

# 31. Toolbar

Toolbar:

```
Leading:

Back


Center:

Reading Title


Trailing:

+

Search

More
```

---

# 32. Context Menu

Long press:

```
Edit Reading

Duplicate

Create Flashcards

Export Notes

Delete
```

---

# 33. ViewModel Responsibilities

ReadingDetailViewModel manages:

```
Load reading

Update progress

Manage highlights

Manage notes

Create flashcards

Create recall questions

Track statistics

Sync resources
```

---

# 34. SwiftUI Structure

Recommended:

```
Features/

└── ReadingDetail/

    ├── ReadingDetailView.swift

    ├── ReadingHeaderView.swift

    ├── ReadingViewer.swift

    ├── HighlightView.swift

    ├── NotesView.swift

    ├── ConceptView.swift

    ├── FlashcardsView.swift

    └── ReadingDetailViewModel.swift
```

---

# 35. Navigation Architecture

```
Course Detail

↓

Reading List

↓

Reading Detail

↓

Learning Components
```

---

# 36. Data Requirements

Models:

```
Reading

Course

Highlight

Bookmark

Note

Concept

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
Chapter 5.

Graph Algorithms.

60 percent complete.

35 highlights.
```

---

# 38. iPad Requirements

Optimized for:

## Landscape

Supports:

- Reading and notes workflow.
- External keyboard.
- Split view.

---

## Portrait

Supports:

- Focused reading mode.

---

## Apple Pencil

Supports:

- Annotation.
- Handwriting.
- Highlighting.

---

# 39. Performance Requirements

Reading Detail must:

- Handle large documents.
- Load pages efficiently.
- Save annotations reliably.
- Sync through iCloud.
- Avoid unnecessary memory usage.

---

# 40. Testing Checklist

```
□ Open reading

□ Edit reading

□ Read document

□ Track progress

□ Add highlights

□ Add bookmarks

□ Write notes

□ Create concepts

□ Generate flashcards

□ Create recall questions

□ GoodNotes integration

□ Calendar sync

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 41. Final Reading Detail Architecture

```
Reading Detail

        |

        ├── Overview

        ├── Content

        ├── Notes

        ├── Highlights

        ├── Concepts

        ├── Active Recall

        ├── Flashcards

        └── Statistics
```

The Reading Detail page transforms academic reading into an active learning process where information is captured, understood, and converted into long-term knowledge.