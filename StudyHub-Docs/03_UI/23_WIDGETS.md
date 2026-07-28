# WIDGETS

**Project:** StudyHub  
**Document:** 23_WIDGETS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Widgets system provides quick access to important StudyHub information directly from the device home screen, lock screen, and system surfaces.

Widgets allow students to see important academic information without opening the application.

---

# 2. Widget Philosophy

The best productivity tools reduce friction.

Traditional workflow:

```
Unlock Device

↓

Open App

↓

Navigate

↓

Find Information
```

StudyHub workflow:

```
Unlock Device

↓

See Important Information

↓

Take Action
```

---

# 3. User Goals

Users should be able to:

- View academic progress quickly.
- See upcoming deadlines.
- Track study goals.
- Start study sessions quickly.
- Access important information.

---

# 4. Widget Platforms

Supported:

```
iPhone Home Screen

iPad Home Screen

Lock Screen

macOS Widgets
```

---

# 5. Widget Framework

Technology:

```
WidgetKit

SwiftUI

App Intents
```

---

# 6. Widget Categories

Available widgets:

```
Study Progress

Upcoming Tasks

Study Timer

Daily Goal

Flashcards

Quote Of The Day

Course Overview

Calendar
```

---

# 7. Widget Sizes

Supported:

```
Small

Medium

Large

Extra Large (iPad)
```

---

# 8. Small Widget

Purpose:

Quick glance information.

Example:

```
┌──────────────┐
│ Study Time   │
│              │
│ 3h 20m       │
└──────────────┘
```

---

Displays:

```
Single Metric

Short Status

Quick Action
```

---

# 9. Medium Widget

Purpose:

More detailed information.

Example:

```
┌────────────────────┐
│ Today's Progress   │
├────────────────────┤
│ Study: 3h          │
│ Tasks: 4 Complete  │
│ Goal: 75%          │
└────────────────────┘
```

---

# 10. Large Widget

Purpose:

Dashboard preview.

Displays:

```
Study Progress

Deadlines

Schedule

Statistics
```

---

Example:

```
┌────────────────────┐
│ Today's Overview   │
├────────────────────┤
│ Study Time         │
│ Upcoming Tasks     │
│ Current Course     │
│ Goal Progress      │
└────────────────────┘
```

---

# 11. Study Progress Widget

Purpose:

Show daily learning progress.

Displays:

```
Study Time

Daily Goal

Progress Ring

Streak
```

---

Example:

```
Today's Goal

3 / 5 Hours

60%
```

---

# 12. Upcoming Tasks Widget

Purpose:

Display important deadlines.

Displays:

```
Assignments

Exams

Readings

Tasks
```

---

Example:

```
Upcoming:

SC302 Assignment

Due Tomorrow
```

---

# 13. Study Timer Widget

Purpose:

Quickly start focused work.

Displays:

```
Current Timer

Session Status

Start Button
```

---

Example:

```
Focus Timer

25:00

Start
```

---

Actions:

```
Start Session

Pause

Resume
```

---

# 14. Daily Goal Widget

Purpose:

Track daily targets.

Displays:

```
Study Goal

Completion

Remaining Time
```

---

Example:

```
Daily Goal

2h / 4h

50%
```

---

# 15. Flashcard Widget

Purpose:

Encourage daily review.

Displays:

```
Cards Due

Review Progress

Quick Start
```

---

Example:

```
45 Cards Due

Start Review
```

---

# 16. Quote Widget

Purpose:

Display meaningful insights.

Displays:

```
Quote

Author

Source
```

---

Example:

```
"Stay hungry,
stay foolish."

— Steve Jobs
```

---

# 17. Course Widget

Purpose:

Provide quick course access.

Displays:

```
Current Course

Progress

Upcoming Work
```

---

Example:

```
SC302

75% Complete

2 Tasks Remaining
```

---

# 18. Calendar Widget

Purpose:

Show academic schedule.

Displays:

```
Classes

Deadlines

Events
```

---

Example:

```
Today:

10:00 AM

SC302 Lecture
```

---

# 19. Widget Interaction

Widgets support:

```
Tap Actions

Deep Links

App Intents
```

---

Examples:

Tap:

```
Assignment

↓

Assignment Detail Page
```

---

Tap:

```
Timer

↓

Start Study Session
```

---

# 20. Widget Configuration

Users can customize:

```
Course

Display Information

Time Range

Theme
```

---

Example:

```
Choose Course:

SC302
```

---

# 21. Widget Personalization

Widgets adapt based on:

```
Current Semester

Active Courses

Upcoming Deadlines

Study Habits
```

---

# 22. Smart Suggestions

Future capability:

Suggest widgets based on usage.

Example:

Before exams:

```
Recommended:

Exam Countdown Widget
```

---

# 23. Lock Screen Widgets

Supported:

```
Deadline Countdown

Study Streak

Daily Goal

Timer Status
```

---

Example:

```
Exam:

5 Days Remaining
```

---

# 24. macOS Widget Support

Desktop widgets display:

```
Study Progress

Calendar

Tasks

Statistics
```

---

# 25. Widget Data Source

Widgets receive data from:

```
Shared App Storage

SwiftData

App Group Container
```

---

# 26. Data Refresh

Refresh triggers:

```
Time Based Updates

App Updates

User Actions

Background Refresh
```

---

# 27. Offline Support

Widgets should work with:

```
Cached Data

Local Database

Last Known State
```

---

# 28. Empty State

Example:

```
No Data Available

Start studying to
see progress here.
```

---

# 29. Loading State

Widgets should show:

```
Placeholder Content

Loading Indicator
```

---

# 30. Error State

Example:

```
Unable to load data.

Open StudyHub
```

---

# 31. Widget Design Requirements

Widgets must:

- Follow Apple Widget guidelines.
- Provide glanceable information.
- Avoid excessive text.
- Prioritize important data.
- Maintain readability.

---

# 32. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- High contrast.
- Reduced Motion.

---

VoiceOver example:

```
Study Progress Widget.

Three hours completed.

Sixty percent of daily goal.
```

---

# 33. iPad Requirements

Optimized for:

## Landscape

Supports:

- Large widgets.
- Dashboard layouts.

---

## Portrait

Supports:

- Compact widgets.
- Quick information.

---

# 34. Performance Requirements

Widgets must:

- Load instantly.
- Consume minimal battery.
- Use efficient refresh cycles.
- Avoid heavy processing.

---

# 35. SwiftUI Structure

Recommended:

```
Widgets/

├── StudyProgressWidget.swift

├── TaskWidget.swift

├── TimerWidget.swift

├── FlashcardWidget.swift

├── QuoteWidget.swift

├── WidgetEntry.swift

├── WidgetProvider.swift

└── WidgetConfiguration.swift
```

---

# 36. Testing Checklist

```
□ Add widget

□ Remove widget

□ Configure widget

□ Tap actions

□ Deep links

□ Data refresh

□ Offline state

□ Lock screen widget

□ iPad widget

□ macOS widget

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 37. Final Widget Architecture

```
Widgets

        |

        ├── Study Progress

        ├── Tasks

        ├── Timer

        ├── Flashcards

        ├── Quotes

        ├── Calendar

        └── Course Overview
```

Widgets make StudyHub a constant learning companion by bringing important academic information directly into the user's everyday device experience