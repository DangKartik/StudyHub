# EMPTY STATES

**Project:** StudyHub  
**Document:** 08_EMPTY_STATES.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the empty state design system for StudyHub.

Empty states appear when users have no content, no available data, or have not completed a setup process.

Examples:

- No courses created
- No assignments available
- No flashcards due
- No study sessions recorded
- No calendar events

The goal is to transform empty moments into helpful guidance.

---

# 2. Empty State Philosophy

StudyHub follows the principle:

> An empty state is not an absence of content. It is an opportunity to guide the user.

Empty states should:

- Explain what happened.
- Teach the user what to do next.
- Encourage action.
- Maintain a premium feeling.

---

# 3. Empty State Goals

Every empty state should provide:

- Clear explanation
- Helpful illustration or icon
- Primary action
- Optional secondary action
- Context-aware guidance

---

# 4. Empty State Structure

Every StudyHub empty state follows:

```
Icon / Illustration

↓

Title

↓

Description

↓

Primary Action

↓

Secondary Action (Optional)
```

---

# 5. Empty State Layout

Default spacing:

```
Icon

24pt

Title

8pt

Description

24pt

Action Button
```

---

# 6. Empty State Components

Reusable component:

```
StudyHubEmptyState
```

---

Properties:

```
icon

title

description

primaryAction

secondaryAction
```

---

Example:

```swift
StudyHubEmptyState(
    icon: "book",
    title: "No Courses Yet",
    description: "Add your first course to start organizing your semester."
)
```

---

# 7. Visual Design

Empty states should feel:

- Calm
- Encouraging
- Minimal
- Focused

Avoid:

- Large illustrations
- Excessive decoration
- Gamified visuals

---

# 8. Icon Guidelines

Use:

- SF Symbols
- Simple illustrations
- Semantic icons

Examples:

Courses:

```
book.closed
```

Assignments:

```
checklist
```

Calendar:

```
calendar
```

Flashcards:

```
rectangle.stack
```

---

# 9. Empty State Types

StudyHub supports:

```
First Launch Empty States

↓

Feature Empty States

↓

Search Empty States

↓

Error Empty States

↓

Filtered Empty States
```

---

# 10. First Launch Empty States

Purpose:

Guide new users.

Examples:

- No semesters
- No courses
- No data

---

Design:

Friendly onboarding.

Example:

```
Welcome to StudyHub

Your academic operating system.

Create your first semester to begin organizing your studies.

[Create Semester]
```

---

# 11. Semester Empty State

Scenario:

User has no semesters.

---

Title:

```
No Semesters Added
```

Description:

```
Create a semester to organize courses, assignments, grades, and study progress.
```

Primary Action:

```
Add Semester
```

Icon:

```
calendar.badge.plus
```

---

# 12. Course Empty State

Scenario:

Semester exists but has no courses.

---

Title:

```
No Courses Yet
```

Description:

```
Add your university courses to start tracking lectures, assignments, readings, and grades.
```

Primary Action:

```
Add Course
```

Icon:

```
books.vertical
```

---

# 13. Lecture Empty State

Scenario:

Course has no lectures.

---

Title:

```
No Lectures Added
```

Description:

```
Create lectures to organize topics, notes, slides, and active recall questions.
```

Primary Action:

```
Add Lecture
```

Icon:

```
person.crop.rectangle
```

---

# 14. Assignment Empty State

Scenario:

No assignments.

---

Title:

```
No Assignments
```

Description:

```
Track deadlines, progress, and submissions by adding your first assignment.
```

Primary Action:

```
Add Assignment
```

Icon:

```
checklist
```

---

# 15. Reading Empty State

Scenario:

No readings.

---

Title:

```
No Readings Added
```

Description:

```
Track textbooks, papers, and course materials with reading progress.
```

Primary Action:

```
Add Reading
```

Icon:

```
book.pages
```

---

# 16. Flashcard Empty State

Scenario:

No flashcards.

---

Title:

```
No Flashcards Yet
```

Description:

```
Create flashcards or generate them using AI to begin active recall practice.
```

Primary Action:

```
Create Flashcard
```

Secondary Action:

```
Generate with AI
```

Icon:

```
rectangle.stack
```

---

# 17. Active Recall Empty State

Scenario:

No questions available.

---

Title:

```
No Recall Questions
```

Description:

```
Add active recall questions to strengthen your understanding of this topic.
```

Primary Action:

```
Create Question
```

Icon:

```
brain
```

---

# 18. Calendar Empty State

Scenario:

No events.

---

Title:

```
Your Schedule Is Empty
```

Description:

```
Add lectures, study sessions, and deadlines to create your academic schedule.
```

Primary Action:

```
Add Event
```

Icon:

```
calendar
```

---

# 19. Study Mode Empty State

Scenario:

No recommended sessions.

---

Title:

```
No Study Plan Available
```

Description:

```
Complete more academic activities so StudyHub can recommend personalized study sessions.
```

Primary Action:

```
Start Planning
```

Icon:

```
bolt.fill
```

---

# 20. Statistics Empty State

Scenario:

No study data.

---

Title:

```
No Statistics Yet
```

Description:

```
Complete study sessions to see your academic progress and learning insights.
```

Primary Action:

```
Start Studying
```

Icon:

```
chart.bar
```

---

# 21. Quotes Empty State

Scenario:

No motivational quotes.

---

Title:

```
No Quotes Added
```

Description:

```
Add your favorite quotes and StudyHub will display one every day.
```

Primary Action:

```
Add Quote
```

Icon:

```
quote.opening
```

---

# 22. Search Empty State

Scenario:

No search results.

---

Title:

```
No Results Found
```

Description:

```
Try searching with different keywords or remove filters.
```

Primary Action:

```
Clear Search
```

Icon:

```
magnifyingglass
```

---

# 23. Filter Empty State

Scenario:

Filters remove all results.

---

Title:

```
No Matching Items
```

Description:

```
Try changing your filters to see more results.
```

Primary Action:

```
Reset Filters
```

Icon:

```
line.3.horizontal.decrease.circle
```

---

# 24. Offline Empty State

Scenario:

No network connection.

---

Title:

```
Offline Mode
```

Description:

```
Your local data is available. Some features will return when you reconnect.
```

Icon:

```
wifi.slash
```

---

# 25. Sync Empty State

Scenario:

No iCloud data.

---

Title:

```
Nothing Synced Yet
```

Description:

```
Your StudyHub data will appear here after synchronization.
```

Icon:

```
icloud
```

---

# 26. AI Feature Empty State

Scenario:

No AI history.

---

Title:

```
No AI History
```

Description:

```
Use AI tools to summarize notes, generate quizzes, and create flashcards.
```

Primary Action:

```
Try AI Assistant
```

Icon:

```
sparkles
```

---

# 27. Empty State Actions

Primary actions should:

- Solve the empty state.
- Be obvious.
- Use verbs.

Good:

```
Add Course

Create Flashcard

Start Studying
```

Avoid:

```
Continue

Proceed

Explore
```

---

# 28. Empty State Animations

Allowed:

- Fade in
- Gentle icon appearance
- Button transition

Duration:

```
300ms
```

---

Avoid:

- Constant movement
- Large animations
- Distracting effects

---

# 29. Accessibility Requirements

Every empty state must support:

- VoiceOver labels
- Dynamic Type
- High contrast
- Reduced motion

---

Example:

VoiceOver:

```
No Courses Yet.

Add your first course button.
```

---

# 30. Dark Mode Requirements

Empty states must use:

- Semantic colors
- System materials
- Accessible contrast

---

Avoid:

- Fixed background colors
- Image-only communication

---

# 31. Implementation Structure

Recommended:

```
DesignSystem/

├── Components/

│
└── EmptyState/

    ├── StudyHubEmptyState.swift

    ├── EmptyStateType.swift

    └── EmptyStateContent.swift
```

---

# 32. Testing Checklist

Before release:

```
□ Correct message displayed

□ Action solves the empty state

□ VoiceOver works

□ Dynamic Type supported

□ Dark Mode tested

□ Reduce Motion tested

□ iPad layouts tested
```

---

# 33. Empty State Rules Summary

Mandatory rules:

- Every empty screen requires guidance.
- Explain why content is missing.
- Provide a clear next action.
- Maintain Apple-quality simplicity.
- Avoid making users feel blocked.

---

# 34. Empty State Architecture Summary

StudyHub empty states follow:

```
No Data

↓

Explanation

↓

Guidance

↓

User Action

↓

Productive Experience
```

Empty states should turn moments of inactivity into opportunities for discovery and organization.