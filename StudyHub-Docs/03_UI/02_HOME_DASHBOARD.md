# HOME DASHBOARD

**Project:** StudyHub  
**Document:** 02_HOME_DASHBOARD.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Home Dashboard is the central command center of StudyHub.

It is the first screen users see after launching the application.

Its purpose is to provide a complete academic overview:

- What is happening today.
- What needs attention.
- How the semester is progressing.
- What the user should study next.

The dashboard transforms StudyHub from a collection of tools into an academic operating system.

---

# 2. Dashboard Philosophy

StudyHub follows the principle:

> The dashboard should answer one question: "What should I focus on right now?"

The user should immediately understand:

- Today's schedule.
- Upcoming deadlines.
- Study priorities.
- Academic progress.
- Learning recommendations.

---

# 3. Dashboard Goals

The dashboard should:

- Reduce cognitive load.
- Surface important information.
- Encourage consistent studying.
- Provide quick access to common actions.
- Personalize the academic experience.

---

# 4. Dashboard Entry Point

Navigation:

```
App Launch

↓

Onboarding Complete

↓

Home Dashboard
```

---

# 5. Dashboard Layout

The dashboard is optimized for iPad landscape.

Primary layout:

```
┌───────────────────────────────────────────────┐
│ Greeting                          Quick Actions│
├───────────────────────────────────────────────┤
│ Today's Schedule              Study Progress  │
│                                                │
├───────────────────────────────────────────────┤
│ Tasks & Deadlines             Study Insights  │
│                                                │
├───────────────────────────────────────────────┤
│ Weekly Overview               Recommendation  │
└───────────────────────────────────────────────┘
```

---

# 6. Responsive Layout

## Landscape

Multi-column dashboard.

Example:

```
Left Column

Today's Information


Right Column

Progress + Insights
```

---

## Portrait

Single-column scrolling layout.

Order:

```
Greeting

Quote

Today's Schedule

Tasks

Deadlines

Progress

Recommendations

Statistics
```

---

# 7. Dashboard Components

The Home Dashboard contains:

```
Greeting Card

Daily Quote

Today's Schedule

Upcoming Tasks

Assignment Deadlines

Exam Countdown

Study Streak

Study Hours

Progress Rings

Weekly Overview

Quick Actions

Study Recommendation
```

---

# 8. Greeting Section

Purpose:

Create a personal experience.

---

Example:

```
Good morning, Kartik

Ready for a productive day?
```

---

Data:

```
User Name

Time of Day

Current Semester
```

---

Time-based greetings:

```
Morning:

Good morning


Afternoon:

Good afternoon


Evening:

Good evening
```

---

# 9. Daily Motivational Quote

Purpose:

Provide daily motivation.

---

Layout:

```
Quote

"Success is the sum of small efforts."

Author (optional)
```

---

Features:

- Random daily quote.
- No repetition until all quotes are shown.
- Editable through Quote Manager.

---

Actions:

```
Open Quotes

Edit Quote
```

---

# 10. Today's Schedule

Purpose:

Display today's academic timeline.

---

Includes:

```
Lectures

Tutorials

Labs

Study Sessions

Calendar Events
```

---

Example:

```
10:30 AM

SC302 Lecture

Data Structures


2:00 PM

Study Session

Flashcards Review
```

---

Actions:

Tap event:

```
Open Event Details
```

---

# 11. Schedule States

## Empty State

```
No Events Today

Enjoy your free time or plan a study session.
```

Action:

```
Add Event
```

---

## Loading State

Show:

- Skeleton timeline
- Placeholder cards

---

# 12. Today's Tasks

Purpose:

Show immediate priorities.

---

Includes:

```
Assignments

Readings

Flashcards Due

Study Goals
```

---

Example:

```
Complete Assignment 2

Due Tomorrow

70% Complete
```

---

Actions:

```
Complete Task

Open Details
```

---

# 13. Assignment Deadline Card

Purpose:

Prevent missed deadlines.

---

Displays:

```
Assignment Name

Course

Due Date

Priority

Completion Status
```

---

Example:

```
Machine Learning Report

SC402

Due Friday

High Priority
```

---

# 14. Exam Countdown

Purpose:

Create awareness of upcoming exams.

---

Example:

```
Database Systems Exam

12 Days Remaining
```

---

Visual:

Countdown card.

---

States:

```
Normal

Upcoming

Critical
```

---

# 15. Study Streak

Purpose:

Encourage consistency.

---

Displays:

```
🔥 14 Day Study Streak
```

---

Data:

Based on:

- Completed study sessions.
- Active recall sessions.
- Reading activity.

---

# 16. Study Hours

Purpose:

Show learning consistency.

---

Displays:

```
12.5 Hours

This Week
```

---

Comparison:

```
+20% compared to last week
```

---

# 17. Progress Rings

Inspired by Apple Activity Rings.

---

Tracks:

## Academic Progress

```
Semester Completion
```

---

## Learning Progress

```
Flashcards Reviewed
```

---

## Study Goal

```
Weekly Study Target
```

---

Example:

```
○ Semester

○ Learning

○ Study Goal
```

---

# 18. Weekly Overview

Purpose:

Provide weekly academic summary.

---

Displays:

```
Monday

Tuesday

Wednesday

Thursday

Friday

Weekend
```

---

Metrics:

```
Study Hours

Tasks Completed

Lectures Attended
```

---

Visualization:

Use:

```
Swift Charts
```

---

# 19. Quick Actions

Purpose:

Allow fast creation.

---

Component:

```
Quick Action Grid
```

---

Actions:

```
+ Add Assignment

+ Add Lecture

+ Start Study Session

+ Create Flashcard

+ Add Reading

+ Add Note
```

---

# 20. Study Recommendation

Purpose:

Provide intelligent suggestions.

---

Powered by:

- Upcoming deadlines.
- Weak topics.
- Spaced repetition.
- Study history.

---

Example:

```
Recommended:

Review Binary Trees

Reason:

Accuracy dropped below 70%
```

---

Actions:

```
Start Review
```

---

# 21. Academic Health Summary

Future expansion.

Displays:

```
Study Consistency

Workload

Performance

Learning Quality
```

---

Example:

```
Your academic health is strong.

You completed 85% of weekly goals.
```

---

# 22. Dashboard Interactions

Supported interactions:

## Tap

Open details.

---

## Long Press

Show context menu.

---

## Drag

Rearrange widgets.

---

# 23. Widget Customization

Users can customize dashboard.

Supported:

```
Show / Hide widgets

Reorder widgets

Change layout
```

---

Future:

```
Widget Marketplace
```

---

# 24. Dashboard Toolbar

Toolbar:

```
Leading:

Sidebar


Center:

StudyHub


Trailing:

+

Search

Profile
```

---

# 25. Search Integration

Global search available.

Search:

```
Courses

Assignments

Lectures

Notes

Flashcards
```

---

# 26. Navigation From Dashboard

Examples:

Tap course:

```
Dashboard

↓

Course Detail
```

---

Tap assignment:

```
Dashboard

↓

Assignment Detail
```

---

Tap study recommendation:

```
Dashboard

↓

Study Mode
```

---

# 27. Data Requirements

Dashboard requires:

```
User

Semester

Courses

Events

Assignments

Readings

StudySessions

Flashcards

Statistics
```

---

# 28. ViewModel Responsibilities

HomeDashboardViewModel manages:

- Loading dashboard data.
- Calculating summaries.
- Generating recommendations.
- Handling refresh.
- Managing widget visibility.

---

Example:

```
loadTodaySchedule()

calculateProgress()

generateRecommendation()

refreshDashboard()
```

---

# 29. SwiftUI Structure

Recommended:

```
Features/

└── Home/

    ├── HomeDashboardView.swift

    ├── HomeDashboardViewModel.swift

    ├── GreetingCard.swift

    ├── QuoteCard.swift

    ├── ScheduleCard.swift

    ├── ProgressCard.swift

    └── RecommendationCard.swift
```

---

# 30. Accessibility Requirements

Dashboard supports:

- VoiceOver.
- Dynamic Type.
- Reduced Motion.
- High Contrast.

---

Charts and progress rings require descriptions.

Example:

```
Semester progress:
75 percent complete.
```

---

# 31. Empty States

First-time users see:

```
Welcome to StudyHub

Add your first course to begin building your dashboard.
```

---

# 32. Loading States

Dashboard loading:

Use:

- Skeleton cards.
- Placeholder charts.
- Timeline placeholders.

---

Never show:

Blank screen.

---

# 33. Error States

Examples:

Calendar unavailable:

```
Unable to load calendar events.

Retry
```

---

Statistics unavailable:

```
Not enough study data yet.
```

---

# 34. iPad Requirements

Dashboard supports:

- Landscape mode.
- Portrait mode.
- Stage Manager.
- Split View.
- External keyboard.
- Apple Pencil.

---

# 35. Performance Requirements

Dashboard must:

- Load quickly.
- Avoid unnecessary calculations.
- Cache statistics.
- Update asynchronously.

---

# 36. Testing Checklist

```
□ First launch experience

□ Empty dashboard

□ Full semester data

□ Large number of courses

□ Dark Mode

□ Dynamic Type

□ VoiceOver

□ Stage Manager

□ Split View

□ Landscape

□ Portrait
```

---

# 37. Final Dashboard Architecture

```
User Opens App

↓

Home Dashboard

↓

Academic Overview

↓

Identify Priority

↓

Take Action

↓

Improve Learning
```

The Home Dashboard is the heart of StudyHub and should feel like a personal academic command center.