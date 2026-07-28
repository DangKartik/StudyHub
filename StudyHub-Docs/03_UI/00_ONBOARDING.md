# ONBOARDING

**Project:** StudyHub  
**Document:** 00_ONBOARDING.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

This document defines the first launch experience of StudyHub.

The onboarding system introduces users to StudyHub and guides them through initial setup.

The goal is not only to explain features, but to help students build their academic environment.

---

# 2. Onboarding Philosophy

StudyHub follows Apple's onboarding principle:

> Introduce value first, request permissions later.

Users should understand:

- Why StudyHub exists.
- How it improves their academic workflow.
- What data is needed.
- How personalization works.

---

# 3. Onboarding Goals

The onboarding experience should:

- Create a strong first impression.
- Explain the academic operating system concept.
- Set up the user's semester.
- Configure integrations.
- Personalize the dashboard.
- Avoid overwhelming users.

---

# 4. First Launch Experience

First launch flow:

```
App Opens

↓

Welcome Screen

↓

StudyHub Introduction

↓

Create Academic Profile

↓

Create First Semester

↓

Add First Course

↓

Configure Integrations

↓

Dashboard
```

---

# 5. Onboarding Principles

## Principle 1: Progressive Setup

Do not force users to configure everything immediately.

Required:

```
Account Setup

Semester

Course
```

Optional:

```
Calendar Integration

GoodNotes

AI Features

Notifications
```

---

## Principle 2: Show Value Before Permission

Incorrect:

```
Allow Calendar Access?

```

before explaining why.

---

Correct:

```
Connect your calendar to see lectures,
deadlines, and personal events together.

[Connect Calendar]
```

---

## Principle 3: Allow Skipping

Users can skip optional steps.

Example:

```
Set Up Later
```

---

# 6. Launch Screen

Purpose:

Create a premium first impression.

---

Design:

Centered:

```
StudyHub Logo

Academic Operating System

Loading
```

---

Duration:

```
Minimum possible
```

The launch screen should not delay app usage.

---

# 7. Welcome Screen

## Purpose

Introduce the app.

---

Layout:

```
StudyHub Logo

↓

StudyHub

Your complete academic operating system

↓

Organize.
Learn.
Improve.

↓

Get Started
```

---

Primary Action:

```
Get Started
```

---

Secondary Action:

```
Already have data?
Restore from iCloud
```

---

# 8. Product Introduction Screens

Optional introduction carousel.

Maximum:

```
3 screens
```

---

## Screen 1

Title:

```
Plan Your Semester
```

Description:

```
Manage courses, lectures, assignments,
and deadlines in one place.
```

Visual:

Calendar + Course cards

---

## Screen 2

Title:

```
Learn Smarter
```

Description:

```
Use active recall and spaced repetition
to improve your understanding.
```

Visual:

Flashcards

---

## Screen 3

Title:

```
Understand Your Progress
```

Description:

```
Track study habits, grades,
and academic growth.
```

Visual:

Statistics dashboard

---

# 9. User Profile Setup

Purpose:

Personalize StudyHub.

---

Fields:

```
Name

University

Degree Program

Year of Study
```

---

Example:

```
Name:
Kartik

University:
NTU

Year:
2
```

---

# 10. Semester Creation

The first required setup step.

---

Screen:

```
Create Your First Semester
```

---

Fields:

```
Semester Name

Academic Year

Start Date

End Date
```

---

Example:

```
Fall 2026

August 2026

December 2026
```

---

Primary Action:

```
Create Semester
```

---

# 11. Course Creation

After creating a semester.

---

Screen:

```
Add Your First Course
```

---

Fields:

```
Course Name

Course Code

Instructor

Credits / AU

Color
```

---

Example:

```
Object Oriented Design

SC2002

Dr. Zhang

3 AU
```

---

Actions:

```
Add Course

Add Later
```

---

# 12. Calendar Permission Setup

Purpose:

Connect academic schedule.

---

Before Permission:

Show:

```
Connect Your Calendar

Combine:

• Lectures
• Deadlines
• Personal Events

into one schedule.
```

---

Action:

```
Connect Calendar
```

---

Permission:

Use:

```
EventKit
```

---

If denied:

Show:

```
You can enable this later in Settings.
```

---

# 13. Google Calendar Setup

Optional.

---

Screen:

```
Connect Google Calendar
```

---

Benefits:

```
Import existing events

Sync schedules

Avoid conflicts
```

---

Actions:

```
Connect

Skip
```

---

# 14. GoodNotes Integration Setup

Optional.

---

Screen:

```
Connect GoodNotes
```

---

Explain:

```
Open handwritten notes directly
from your lectures.
```

---

Actions:

```
Connect GoodNotes

Later
```

---

# 15. Apple Pencil Setup

Optional.

---

Screen:

```
Optimize for Apple Pencil
```

---

Enable:

```
Handwritten notes workflow

Drawing support

Annotation tools
```

---

Actions:

```
Enable

Skip
```

---

# 16. AI Assistant Setup

Optional.

---

Screen:

```
Enable AI Study Assistant
```

---

Features:

```
Summaries

Flashcard generation

Quiz generation

Concept explanations
```

---

Important:

Explain privacy.

Example:

```
Your data is only used according
to your privacy settings.
```

---

Actions:

```
Enable AI

Not Now
```

---

# 17. Notification Setup

Purpose:

Configure reminders.

---

Screen:

```
Stay On Track
```

---

Options:

```
Lecture reminders

Assignment deadlines

Flashcard reviews

Exam reminders
```

---

Action:

```
Enable Notifications
```

---

# 18. Completion Screen

After setup:

```
You're Ready

Your academic workspace
has been created.

Start organizing your semester.
```

---

Primary Action:

```
Open StudyHub
```

---

# 19. First Dashboard Experience

The first dashboard should be personalized.

Show:

```
Welcome, [Name]

Your semester:

Fall 2026

Add more courses to continue building your workspace.
```

---

Avoid showing empty dashboards without guidance.

---

# 20. Skip Handling

Users may skip setup.

If skipped:

Dashboard displays:

```
Complete Setup

Add semester

Add courses

Connect calendar
```

---

# 21. Returning User Launch

Existing users:

Skip onboarding.

Flow:

```
App Opens

↓

Restore Data

↓

Dashboard
```

---

# 22. iCloud Restore Flow

If previous data exists:

Show:

```
Previous StudyHub data found

Restore your academic workspace?
```

Actions:

```
Restore

Start Fresh
```

---

# 23. Error States

Examples:

## Calendar Connection Failed

```
Unable to connect calendar.

Try again later.
```

---

## iCloud Restore Failed

```
Unable to restore data.

Your local data remains safe.
```

---

# 24. Loading States

During onboarding:

Use:

- Progress indicators
- Skeletons
- Native loading states

Never freeze the screen.

---

# 25. Accessibility Requirements

Onboarding supports:

- VoiceOver
- Dynamic Type
- Reduce Motion
- High Contrast

---

All buttons require:

- Labels
- Hints
- Proper traits

---

# 26. iPad Design Requirements

Onboarding supports:

## Landscape

Centered content:

```
Maximum width:

600pt
```

---

## Portrait

Full width layout.

---

## Stage Manager

Window must resize correctly.

---

# 27. SwiftUI Implementation

Recommended structure:

```
Features/

└── Onboarding/

    ├── OnboardingView.swift

    ├── OnboardingViewModel.swift

    ├── WelcomeView.swift

    ├── SemesterSetupView.swift

    ├── CourseSetupView.swift

    └── IntegrationSetupView.swift
```

---

# 28. ViewModel Responsibilities

OnboardingViewModel manages:

- Current onboarding step
- User profile
- Permissions
- Setup completion
- Persistence

---

Example:

```
isOnboardingComplete
```

stored in:

```
UserDefaults / SwiftData
```

---

# 29. Analytics Events

Track:

```
Onboarding Started

Semester Created

Course Added

Calendar Connected

Onboarding Completed
```

---

# 30. Testing Checklist

Before release:

```
□ New user flow works

□ Returning user skips onboarding

□ Permissions denied handled

□ iCloud restore tested

□ Dynamic Type tested

□ VoiceOver tested

□ Portrait tested

□ Landscape tested

□ Stage Manager tested
```

---

# 31. Onboarding Architecture Summary

```
Introduction

↓

Personalization

↓

Academic Setup

↓

Integration Setup

↓

Dashboard
```

The onboarding experience should make students immediately understand that StudyHub is not another planner, but their complete academic operating system.