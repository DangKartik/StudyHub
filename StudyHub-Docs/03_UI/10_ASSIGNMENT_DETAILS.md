# ASSIGNMENT DETAILS

**Project:** StudyHub  
**Document:** 10_ASSIGNMENT_DETAILS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Assignment Detail page is the dedicated workspace for completing, managing, and tracking a single assignment.

It transforms assignments from simple deadlines into complete academic workflows.

The Assignment Detail page allows students to:

- Understand requirements.
- Plan execution.
- Track progress.
- Store materials.
- Manage submission.
- Connect grades.
- Review performance.

---

# 2. Assignment Detail Philosophy

An assignment is a process, not a notification.

Traditional workflow:

```
Deadline Appears

↓

Work Under Pressure

↓

Submit

↓

Forget
```

StudyHub workflow:

```
Assignment Created

↓

Plan Work

↓

Track Progress

↓

Complete Tasks

↓

Submit

↓

Analyze Result
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

Assignments

↓

Assignment Detail
```

---

Secondary:

```
Home Dashboard

↓

Assignment Card

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

# 4. Assignment Detail Page Design

The Assignment Detail page opens as a dedicated full page.

It does NOT open as a permanent detail pane.

---

Landscape:

```
┌──────────────────────────────────────────┐
│ ← Assignments     Assignment 2      More │
├──────────────────────────────────────────┤
│ Assignment Header                        │
├──────────────────────────────────────────┤
│ Overview | Tasks | Rubric | Files | Grade│
├──────────────────────────────────────────┤
│                                          │
│ Content Area                             │
│                                          │
└──────────────────────────────────────────┘
```

---

# 5. Assignment Header

The header provides immediate context.

Displays:

```
Assignment Name

Course

Due Date

Priority

Progress

Status
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

In Progress
```

---

# 6. Header Actions

Available actions:

```
Edit Assignment

Start Study Session

Mark Complete

Submit Assignment

More
```

---

# 7. Assignment Navigation Tabs

Internal navigation:

```
Overview

Tasks

Rubric

Files

Submission

Grade

Statistics
```

---

# 8. Overview Tab

Default landing page.

Purpose:

Provide assignment summary.

---

Contains:

```
Description

Requirements

Important Dates

Progress Summary

Quick Actions
```

---

# 9. Assignment Description

Stores assignment instructions.

Supports:

```
Rich Text

Markdown

Images

Links

Code Blocks

Equations
```

---

Example:

```
Implement a graph traversal algorithm.

Requirements:

• Breadth-first search

• Depth-first search

• Complexity analysis
```

---

# 10. Requirements Section

Purpose:

Convert assignment instructions into actionable items.

---

Example:

```
Requirements:

✓ Implement BFS

✓ Implement DFS

○ Write documentation

○ Submit report
```

---

Users can:

```
Add Requirement

Edit Requirement

Delete Requirement
```

---

# 11. Task Checklist

Purpose:

Break assignments into smaller steps.

---

Example:

```
☐ Understand problem statement

☐ Research approach

☐ Implement solution

☐ Test implementation

☐ Prepare submission
```

---

Features:

```
Create Task

Complete Task

Reorder Task

Delete Task
```

---

# 12. Progress Tracking

Progress is calculated from:

```
Completed Tasks

Time Spent

Manual Adjustment
```

---

Example:

```
Assignment Progress

███████░░░

70%
```

---

# 13. Estimated Time Tracking

Users can estimate workload.

Fields:

```
Estimated Hours

Actual Hours

Remaining Time
```

---

Example:

```
Estimated:

8 Hours


Completed:

5 Hours


Remaining:

3 Hours
```

---

# 14. Study Session Integration

Users can start focused work.

Action:

```
Start Assignment Session
```

---

Creates:

```
Study Session

↓

Assignment Reference

↓

Time Tracking

↓

Statistics Update
```

---

# 15. Priority Management

Assignments support:

```
Low

Medium

High

Urgent
```

---

Priority affects:

- Dashboard ranking.
- Recommendations.
- Notifications.

---

# 16. Rubric Section

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

Actions:

```
Add Criterion

Edit Criterion

Delete Criterion
```

---

# 17. File Attachments

Purpose:

Store assignment-related materials.

Supports:

```
PDF

Documents

Images

Code Files

Links
```

---

Each file displays:

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

# 18. Submission Section

Tracks assignment lifecycle.

---

States:

```
Not Started

In Progress

Ready

Submitted

Graded
```

---

Example:

```
Submission Status:

Submitted


Submitted On:

25 September 2026
```

---

# 19. Submission Information

Stores:

```
Submission Date

Submission Link

File

Confirmation

Notes
```

---

Example:

```
GitHub Repository:

github.com/project
```

---

# 20. Grade Section

Connects assignment to Grade Tracker.

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
Score:

92 / 100


Weight:

15%
```

---

# 21. Feedback Storage

Students can save:

```
Professor Feedback

Personal Reflection

Improvement Notes
```

---

Example:

```
Improve documentation quality
for future projects.
```

---

# 22. Calendar Integration

Assignments can create calendar events.

Calendar event contains:

```
Assignment Name

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

# 23. Notifications

Users can configure reminders.

Options:

```
1 Week Before

3 Days Before

1 Day Before

Custom
```

---

Example:

```
Assignment due tomorrow.
```

---

# 24. AI Assistance

Optional AI features.

---

Actions:

```
Break Into Tasks

Explain Requirements

Create Study Plan

Review Draft

Suggest Improvements
```

---

Example:

Input:

```
Assignment Description
```

Output:

```
Suggested Plan:

Day 1:
Research

Day 2:
Implementation

Day 3:
Testing
```

---

# 25. Statistics

Tracks assignment behavior.

Displays:

```
Time Spent

Completion Speed

Number of Sessions

Final Grade
```

---

Example:

```
Study Time:

9h 20m


Sessions:

6
```

---

# 26. Search

Search inside assignment:

```
Description

Tasks

Files

Notes

Feedback
```

---

# 27. Empty States

## No Tasks

```
No Tasks Added

Break this assignment into smaller steps.

[Add Task]
```

---

## No Files

```
No Files Attached

Add assignment materials.
```

---

## No Grade

```
No Grade Recorded Yet
```

---

# 28. Loading States

Display:

- Assignment header skeleton.
- Checklist placeholders.
- File loading indicators.

---

# 29. Error States

Example:

```
Unable to load assignment.

Retry
```

---

# 30. Toolbar

Toolbar:

```
Leading:

Back


Center:

Assignment Name


Trailing:

+

Search

More
```

---

# 31. Context Menu

Long press:

```
Edit Assignment

Duplicate

Archive

Share

Delete
```

---

# 32. ViewModel Responsibilities

AssignmentDetailViewModel manages:

```
Load assignment

Update information

Manage checklist

Manage files

Update progress

Track submission

Sync calendar

Update grade
```

---

# 33. SwiftUI Structure

Recommended:

```
Features/

└── AssignmentDetail/

    ├── AssignmentDetailView.swift

    ├── AssignmentHeaderView.swift

    ├── AssignmentOverviewView.swift

    ├── ChecklistView.swift

    ├── RubricView.swift

    ├── AttachmentView.swift

    ├── SubmissionView.swift

    ├── GradeView.swift

    └── AssignmentDetailViewModel.swift
```

---

# 34. Navigation Architecture

```
Course Detail

↓

Assignment List

↓

Assignment Detail

↓

Assignment Workflow
```

---

# 35. Data Requirements

Models:

```
Assignment

Course

ChecklistItem

Attachment

Rubric

Submission

Grade

StudySession

CalendarEvent
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
Assignment 2.

Data Structures Project.

Due Friday.

70 percent complete.
```

---

# 37. iPad Requirements

Optimized for:

## Landscape

Supports:

- Multi-column workflows.
- Keyboard input.
- External displays.

---

## Portrait

Supports:

- Focused assignment management.

---

## Apple Pencil

Supports:

- PDF annotation.
- Handwritten planning.

---

# 38. Performance Requirements

The Assignment Detail page must:

- Support large attachments.
- Handle long descriptions.
- Load sections lazily.
- Sync efficiently through iCloud.

---

# 39. Testing Checklist

```
□ Open assignment

□ Edit assignment

□ Add tasks

□ Complete tasks

□ Add rubric

□ Attach files

□ Track progress

□ Start study session

□ Submit assignment

□ Add grade

□ Calendar sync

□ Notifications

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 40. Final Assignment Detail Architecture

```
Assignment Detail

        |

        ├── Overview

        ├── Tasks

        ├── Rubric

        ├── Files

        ├── Submission

        ├── Grade

        └── Statistics
```

The Assignment Detail page turns academic deadlines into structured workflows that help students plan, execute, and improve their academic performance.