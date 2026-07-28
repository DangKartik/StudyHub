# ASSIGNMENTS

**Project:** StudyHub  
**Document:** 09_ASSIGNMENTS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Assignments section manages all academic assignments across courses and semesters.

It provides students with a complete assignment management workflow:

- Track upcoming work.
- Break assignments into tasks.
- Monitor progress.
- Store requirements.
- Attach files.
- Track submission status.
- Connect assignments with grades.

Assignments are not just deadlines; they are active academic workflows.

---

# 2. Assignment Philosophy

Traditional workflow:

```
Assignment Released

↓

Remember Deadline

↓

Complete Work

↓

Submit
```

StudyHub workflow:

```
Assignment

↓

Understand Requirements

↓

Create Plan

↓

Track Progress

↓

Submit

↓

Review Performance
```

---

# 3. User Goals

Users should be able to:

- Create assignments manually.
- Track deadlines.
- Add checklists.
- Store rubrics.
- Attach resources.
- Monitor completion.
- Track submission.
- Connect grades.

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

Assignments

↓

Assignment Detail
```

---

Secondary:

```
Home Dashboard

↓

Upcoming Assignment

↓

Assignment Detail
```

---

```
Calendar

↓

Deadline Event

↓

Assignment Detail
```

---

# 5. Assignment List Screen

Displays all assignments for a course.

Layout:

```
┌─────────────────────────────────┐
│ Assignments              +      │
├─────────────────────────────────┤
│                                 │
│ Machine Learning Report        │
│ Due Friday                     │
│ 70% Complete                   │
│                                 │
├─────────────────────────────────┤
│ Database Project               │
│ Due Next Week                  │
│ Not Started                    │
│                                 │
└─────────────────────────────────┘
```

---

# 6. Assignment Categories

Assignments are grouped by status.

---

## Upcoming

Future deadlines.

Example:

```
Due Tomorrow
```

---

## In Progress

Currently being worked on.

Example:

```
60% Complete
```

---

## Completed

Finished assignments.

Example:

```
Submitted
```

---

## Overdue

Past deadline.

Example:

```
2 Days Late
```

---

# 7. Assignment Card

Each assignment appears as a card.

Displays:

```
Assignment Title

Course

Due Date

Priority

Progress

Submission Status
```

---

Example:

```
Assignment 2

SC302

Due Friday

High Priority

75%

Not Submitted
```

---

# 8. Assignment Card Actions

Tap:

```
Open Assignment Detail
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

# 9. Create Assignment

Users create assignments manually.

Primary action:

```
+
```

---

Form:

```
Create Assignment
```

---

# 10. Assignment Fields

Required:

```
Title

Course

Due Date
```

---

Optional:

```
Description

Start Date

Priority

Weight

Estimated Time

Submission Status

Attachments

Rubric
```

---

# 11. Assignment Example

Input:

```
Title:

Data Structures Project


Course:

SC302


Due:

25 September


Priority:

High
```

---

Result:

```
Data Structures Project

Due 25 September

High Priority
```

---

# 12. Assignment Detail Page

Selecting an assignment opens a dedicated page.

Navigation:

```
Assignment List

↓

Assignment Detail
```

---

Contains:

```
Overview

Description

Checklist

Rubric

Attachments

Progress

Submission

Grade
```

---

# 13. Assignment Header

Displays:

```
Assignment Title

Course

Due Date

Priority

Progress
```

---

Example:

```
Assignment 2

Data Structures

SC302

Due Friday

High Priority

65% Complete
```

---

# 14. Assignment Actions

Toolbar actions:

```
Edit

Start Focus Session

Mark Complete

Submit

More
```

---

# 15. Assignment Description

Purpose:

Store assignment instructions.

Supports:

```
Rich Text

Markdown

Images

Links

Code Blocks
```

---

Example:

```
Implement a balanced binary tree.

Requirements:

- Insert operation
- Delete operation
- Complexity analysis
```

---

# 16. Assignment Checklist

Purpose:

Break large assignments into manageable tasks.

---

Example:

```
☐ Read requirements

☐ Design solution

☐ Implement code

☐ Test

☐ Submit
```

---

Features:

```
Add Task

Reorder Task

Complete Task

Delete Task
```

---

# 17. Progress Tracking

Progress is calculated from:

```
Checklist Completion

Time Spent

Manual Progress
```

---

Example:

```
Progress

███████░░░

70%
```

---

# 18. Priority System

Assignments support priority levels.

---

## Low

```
Green indicator
```

---

## Medium

```
Normal indicator
```

---

## High

```
Important indicator
```

---

## Urgent

```
Critical indicator
```

---

# 19. Rubric Management

Purpose:

Store grading criteria.

---

Example:

```
Implementation

40%


Documentation

30%


Testing

30%
```

---

Users can:

```
Add Criteria

Edit Criteria

Delete Criteria
```

---

# 20. Attachments

Assignments support:

```
PDF

Images

Documents

Links

Code Files
```

---

Each attachment displays:

```
Name

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

# 21. Submission Tracking

Tracks assignment lifecycle.

States:

```
Not Started

In Progress

Completed

Submitted

Graded
```

---

Example:

```
Status:

Submitted

Grade:

92%
```

---

# 22. Grade Integration

Assignments connect with Grade Tracker.

Stores:

```
Score

Maximum Score

Weight

Feedback
```

---

Example:

```
Assignment 2

92 / 100

Weight:

15%
```

---

# 23. Calendar Integration

Assignments can create calendar events.

Calendar event:

```
Assignment Name

Due Date

Course

Reminder
```

---

Sync:

```
Apple Calendar

Google Calendar
```

---

# 24. Notifications

Users can enable:

```
One Week Before

Three Days Before

One Day Before

Custom Reminder
```

---

Example:

```
Assignment due tomorrow.
```

---

# 25. Study Session Integration

Users can start focused work.

Action:

```
Start Study Session
```

---

Creates:

```
Study Session

↓

Assignment Reference

↓

Statistics Update
```

---

# 26. AI Assistance

Optional AI features:

```
Break assignment into tasks

Explain requirements

Generate study plan

Review draft
```

---

Example:

Input:

```
Assignment Description
```

Output:

```
Suggested checklist:

1. Research topic

2. Implement solution

3. Test
```

---

# 27. Empty State

No assignments:

```
No Assignments Yet

Create your first assignment.

[Add Assignment]
```

---

# 28. Loading State

Display:

- Assignment skeleton cards.
- Placeholder progress bars.
- Loading indicators.

---

# 29. Error State

Example:

```
Unable to load assignments.

Retry
```

---

# 30. Search

Search assignments by:

```
Title

Course

Description

Tags
```

---

Example:

Search:

```
Project
```

Results:

```
Database Project

ML Project
```

---

# 31. Filtering

Filters:

```
Upcoming

Completed

Overdue

High Priority

Not Submitted
```

---

# 32. Sorting

Sort by:

```
Due Date

Priority

Progress

Recently Added
```

---

# 33. Toolbar

Toolbar:

```
Leading:

Back


Center:

Assignments


Trailing:

+

Search

Filter
```

---

# 34. ViewModel Responsibilities

AssignmentViewModel manages:

```
Load assignments

Create assignment

Update assignment

Delete assignment

Calculate progress

Manage reminders

Sync calendar
```

---

# 35. SwiftUI Structure

Recommended:

```
Features/

└── Assignments/

    ├── AssignmentsView.swift

    ├── AssignmentCard.swift

    ├── AssignmentDetailView.swift

    ├── AssignmentFormView.swift

    ├── ChecklistView.swift

    └── AssignmentViewModel.swift
```

---

# 36. Navigation Architecture

```
Course Detail

↓

Assignments

↓

Assignment Detail

↓

Academic Workflow
```

---

# 37. Data Requirements

Models:

```
Assignment

Course

ChecklistItem

Attachment

Grade

StudySession

CalendarEvent
```

---

# 38. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduced Motion.

---

VoiceOver example:

```
Assignment 2.

Data Structures Project.

Due Friday.

70 percent complete.
```

---

# 39. iPad Requirements

Optimized for:

## Landscape

Supports:

- Assignment list.
- Detail workflow.
- Multitasking.

---

## Portrait

Supports:

- Focused task management.

---

## Apple Pencil

Supports:

- PDF annotation.
- Handwritten planning.

---

# 40. Performance Requirements

Assignment system must:

- Support thousands of assignments.
- Load efficiently.
- Handle attachments.
- Sync reliably.

---

# 41. Testing Checklist

```
□ Create assignment

□ Edit assignment

□ Delete assignment

□ Add checklist

□ Track progress

□ Add rubric

□ Add attachments

□ Submit assignment

□ Grade integration

□ Calendar sync

□ Notifications

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 42. Final Assignment Architecture

```
Assignment

        |

        ├── Description

        ├── Checklist

        ├── Rubric

        ├── Attachments

        ├── Submission

        ├── Grade

        └── Study Sessions
```

Assignments are treated as complete academic workflows rather than simple reminders, helping students plan, execute, and improve their academic performance.