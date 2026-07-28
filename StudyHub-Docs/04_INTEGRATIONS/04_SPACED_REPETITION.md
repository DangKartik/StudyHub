# SPACED REPETITION INTEGRATION

**Project:** StudyHub  
**Document:** 04_SPACED_REPETITION.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + Engineering Team  

---

# 1. Purpose

The Spaced Repetition system integrates scientifically proven memory techniques into StudyHub.

It manages when students should review information to maximize long-term retention.

The system powers:

- Flashcard scheduling.
- Knowledge retention.
- Review reminders.
- Active recall sessions.

---

# 2. Spaced Repetition Philosophy

Learning is not about reading information repeatedly.

Effective learning requires:

```
Learn

↓

Forget Slightly

↓

Recall

↓

Strengthen Memory
```

StudyHub automates this process.

Traditional workflow:

```
Create Flashcards

↓

Review Randomly

↓

Forget Important Topics
```

StudyHub workflow:

```
Create Knowledge

↓

AI Schedules Review

↓

Student Recalls

↓

Memory Strength Improves
```

---

# 3. User Goals

Users should be able to:

- Review information at the optimal time.
- Track memory strength.
- Prioritize difficult concepts.
- Build long-term knowledge.
- Prepare efficiently for exams.

---

# 4. Spaced Repetition Engine

The system manages:

```
Cards

Review History

Difficulty

Memory Strength

Next Review Date
```

---

# 5. Supported Algorithms

Initial support:

```
SM-2 Algorithm
```

---

Future support:

```
FSRS Algorithm

Adaptive AI Scheduling

Custom Learning Models
```

---

# 6. Flashcard Lifecycle

A flashcard follows:

```
Created

↓

Learning

↓

Reviewing

↓

Mature

↓

Mastered
```

---

# 7. Card States

## New

Never reviewed.

```
State:

New
```

---

## Learning

Recently introduced.

```
State:

Learning
```

---

## Review

Regular repetition cycle.

```
State:

Review
```

---

## Mature

Strong memory connection.

```
State:

Mature
```

---

# 8. Review Scheduling

The system calculates:

```
Next Review Date

Review Interval

Difficulty Adjustment

Memory Stability
```

---

Example:

```
Today:

Review Card


After Success:

Review Tomorrow


After More Success:

Review Next Week
```

---

# 9. Review Ratings

After answering:

User selects:

```
Again

Hard

Good

Easy
```

---

Meaning:

## Again

Memory failed.

```
Decrease Interval
```

---

## Hard

Difficult recall.

```
Small Increase
```

---

## Good

Successful recall.

```
Normal Increase
```

---

## Easy

Very strong recall.

```
Large Increase
```

---

# 10. Review Session

Flow:

```
Start Review

↓

Show Question

↓

User Recalls

↓

Reveal Answer

↓

Rate Difficulty

↓

Schedule Next Review
```

---

# 11. Daily Review Queue

Dashboard displays:

```
Cards Due Today

Overdue Cards

New Cards
```

---

Example:

```
Today's Review

45 Cards Due

20 New

25 Review
```

---

# 12. Integration With Flashcards

Spaced repetition powers:

```
Flashcard System

Active Recall

Study Mode

Statistics
```

---

Relationship:

```
Flashcard

↓

Review History

↓

Scheduling Algorithm

↓

Future Review
```

---

# 13. AI Flashcard Integration

AI can generate cards.

Flow:

```
Lecture Notes

↓

AI Processing

↓

Flashcards Created

↓

Spaced Repetition Scheduling
```

---

# 14. Course-Based Scheduling

Reviews are organized by:

```
Course

Topic

Difficulty

Exam Importance
```

---

Example:

```
SC302

Graphs

High Difficulty

Review Tomorrow
```

---

# 15. Exam Mode

Before exams:

System adapts.

Inputs:

```
Exam Date

Course Importance

Weak Topics
```

---

Output:

```
More Frequent Reviews

Priority Topics

Practice Questions
```

---

# 16. Memory Strength Tracking

Each card tracks:

```
Stability

Difficulty

Retention Rate

Review Count
```

---

Example:

```
Polymorphism Card

Retention:

92%
```

---

# 17. Forgetting Curve Visualization

Statistics display:

```
Memory Decay

Review Effect

Improvement
```

---

Example:

```
Without Review:

Memory ↓


With Review:

Memory ↑
```

---

# 18. AI Adaptive Learning

Future capability:

AI adjusts:

```
Review Frequency

Difficulty

Question Style

Learning Strategy
```

---

Example:

```
You struggle with recursion.

Recommended:

Review every 2 days.
```

---

# 19. Notification Integration

Spaced repetition connects with:

```
Push Notifications

Widgets

Calendar
```

---

Example:

```
45 cards are waiting.

Start your review session.
```

---

# 20. Widget Integration

Displays:

```
Cards Due

Review Streak

Memory Score
```

---

Example:

```
Flashcards Due

32

Start Review
```

---

# 21. Statistics Integration

Tracks:

```
Cards Reviewed

Retention Rate

Review Streak

Mastery Progress
```

---

# 22. Data Model Requirements

Models:

```
Flashcard

Deck

ReviewHistory

SchedulingData

MemoryProfile
```

---

Example:

```
Flashcard

|

├── Question

├── Answer

├── Difficulty

├── Next Review

└── History
```

---

# 23. Local Storage

Stored locally using:

```
SwiftData
```

---

Stores:

```
Cards

Review History

Scheduling Information
```

---

# 24. iCloud Sync

Syncs:

```
Flashcards

Decks

Review Progress

Scheduling Data
```

---

# 25. Offline Support

Spaced repetition works offline.

Available:

```
Review Cards

Update Progress

Schedule Reviews
```

---

Sync occurs later.

---

# 26. Service Architecture

Recommended:

```
Services/

└── SpacedRepetition/

    ├── SchedulerService.swift

    ├── SM2Algorithm.swift

    ├── ReviewManager.swift

    ├── MemoryCalculator.swift

    └── ReviewQueueService.swift
```

---

# 27. ViewModel Responsibilities

SpacedRepetitionViewModel manages:

```
Generate Review Queue

Start Sessions

Process Ratings

Update Scheduling

Track Progress
```

---

# 28. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Haptic feedback.

---

VoiceOver example:

```
Flashcard.

Question:

What is inheritance?

Reveal answer.
```

---

# 29. Performance Requirements

System must:

- Generate queues quickly.
- Handle thousands of cards.
- Sync efficiently.
- Calculate schedules locally.

---

# 30. Testing Checklist

```
□ Create flashcard

□ Schedule review

□ Review card

□ Rate difficulty

□ Update interval

□ Handle overdue cards

□ Exam mode

□ AI generated cards

□ Statistics update

□ Offline review

□ iCloud sync

□ Accessibility
```

---

# 31. Final Architecture

```
Spaced Repetition

        |

        ├── Scheduling Engine

        ├── Review Queue

        ├── Memory Tracking

        ├── Flashcard Integration

        ├── AI Adaptation

        ├── Notifications

        └── Statistics
```

Spaced Repetition transforms StudyHub from a simple note-taking platform into a long-term knowledge retention system designed around how humans actually learn.