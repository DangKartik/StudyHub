# FLASHCARDS

**Project:** StudyHub  
**Document:** 14_FLASHCARDS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Flashcards section provides an active recall learning system integrated directly into courses, lectures, readings, and concepts.

It helps students convert academic material into memory through:

- Flashcard creation.
- Spaced repetition.
- Review sessions.
- Performance tracking.
- Knowledge retention.

---

# 2. Flashcard Philosophy

Flashcards are not just digital cards.

They are a learning loop.

Traditional workflow:

```
Read Notes

↓

Highlight Information

↓

Forget
```

StudyHub workflow:

```
Learn Concept

↓

Create Flashcard

↓

Review

↓

Recall

↓

Improve Memory
```

---

# 3. User Goals

Users should be able to:

- Create flashcards manually.
- Generate cards from content.
- Organize cards by course.
- Review cards efficiently.
- Track retention.
- Identify weak areas.
- Use spaced repetition.

---

# 4. Navigation Flow

Primary:

```
Sidebar

↓

Flashcards
```

---

Course-based:

```
Course Detail

↓

Flashcards

↓

Deck

↓

Review Session
```

---

Content-based:

```
Lecture

↓

Create Flashcards

↓

Flashcard Deck
```

---

# 5. Flashcards Overview

The Flashcards screen provides:

```
Due Cards

Active Decks

Review Statistics

Recent Activity
```

---

Layout:

```
┌─────────────────────────────┐
│ Flashcards             +    │
├─────────────────────────────┤
│                             │
│ Due Today                   │
│ 45 Cards                    │
│                             │
├─────────────────────────────┤
│ SC302 Deck                  │
│ 120 Cards                   │
│                             │
├─────────────────────────────┤
│ OOP Deck                    │
│ 80 Cards                    │
│                             │
└─────────────────────────────┘
```

---

# 6. Flashcard Organization

Flashcards are organized using:

```
Decks

Courses

Topics

Tags

Sources
```

---

Example:

```
SC302

↓

Trees

↓

Binary Search Trees
```

---

# 7. Flashcard Deck

A deck contains related flashcards.

Example:

```
SC302 Algorithms

120 Cards

75% Mastery
```

---

Deck information:

```
Name

Course

Number of Cards

Progress

Last Review
```

---

# 8. Deck Actions

Tap:

```
Open Deck
```

---

Long press:

```
Review

Edit

Rename

Duplicate

Delete
```

---

# 9. Create Flashcard

Primary action:

```
+
```

---

Options:

```
Create Card

Generate Cards

Import Cards
```

---

# 10. Flashcard Fields

Required:

```
Front

Back
```

---

Optional:

```
Image

Audio

Equation

Code

Tags

Source
```

---

# 11. Flashcard Example

Front:

```
What is polymorphism?
```

Back:

```
The ability of objects
to take multiple forms.
```

---

Metadata:

```
Course:

SC2002


Topic:

OOP
```

---

# 12. Flashcard Types

Supported:

```
Basic

Question Answer

Definition

Fill Blank

Image Occlusion

Code

Equation
```

---

# 13. Card Sources

Every flashcard can optionally link to:

```
Lecture

Reading

Assignment

Note

Concept
```

---

Example:

```
Flashcard

↓

Lecture 05

↓

Binary Trees
```

---

# 14. Review Mode

Review mode is the primary learning experience.

Flow:

```
Start Review

↓

Show Question

↓

Recall Answer

↓

Reveal Answer

↓

Rate Difficulty

↓

Next Card
```

---

# 15. Review Interface

Example:

```
┌─────────────────────────┐
│                         │
│ What is BFS?            │
│                         │
│                         │
│ Tap to reveal           │
│                         │
└─────────────────────────┘
```

---

After reveal:

```
Answer:

Breadth First Search

Uses queue-based traversal.
```

---

# 16. Difficulty Rating

After answering:

User selects:

```
Again

Hard

Good

Easy
```

---

The rating affects:

```
Next Review Date

Difficulty Score

Retention Prediction
```

---

# 17. Spaced Repetition

StudyHub uses spaced repetition principles.

Cards are scheduled based on:

```
Previous Performance

Difficulty

Review History

Recall Accuracy
```

---

Example:

```
Easy

↓

Review in 14 days


Hard

↓

Review tomorrow
```

---

# 18. Daily Review

Dashboard displays:

```
Cards Due Today

Estimated Time

Current Streak
```

---

Example:

```
45 Cards Due

20 Minutes
```

---

# 19. Study Session Integration

Users can start:

```
Flashcard Review Session
```

---

Creates:

```
Study Session

↓

Deck Reference

↓

Statistics Update
```

---

# 20. Progress Tracking

Tracks:

```
Cards Learned

Cards Mastered

Accuracy

Retention

Review Streak
```

---

Example:

```
Mastery

████████░░

80%
```

---

# 21. Mastery Levels

Cards have states:

```
New

Learning

Reviewing

Mastered
```

---

# 22. AI Flashcard Generation

Optional AI features:

```
Generate Cards From Lecture

Generate Cards From Notes

Generate Cards From Reading

Improve Existing Cards
```

---

Example:

Input:

```
Lecture Notes
```

Output:

```
20 Flashcards

10 Recall Questions
```

---

# 23. Search

Search flashcards by:

```
Question

Answer

Course

Topic

Tag
```

---

Example:

Search:

```
Inheritance
```

Results:

```
OOP Deck

Lecture 4 Cards
```

---

# 24. Filtering

Filters:

```
Due Today

New

Learning

Mastered

Weak Cards

Course
```

---

# 25. Sorting

Sort by:

```
Difficulty

Recently Added

Due Date

Course

Accuracy
```

---

# 26. Empty State

No flashcards:

```
No Flashcards Yet

Create cards from your lectures,
notes, or readings.

[Create Flashcard]
```

---

# 27. Loading State

Display:

- Deck skeletons.
- Card placeholders.
- Progress loading.

---

# 28. Error State

Example:

```
Unable to load flashcards.

Retry
```

---

# 29. Toolbar

Toolbar:

```
Leading:

Sidebar


Center:

Flashcards


Trailing:

+

Search

Filter
```

---

# 30. Keyboard Shortcuts

Supported:

Start Review:

```
Space
```

Reveal Answer:

```
Enter
```

Rate Card:

```
1 - Again

2 - Hard

3 - Good

4 - Easy
```

---

# 31. ViewModel Responsibilities

FlashcardsViewModel manages:

```
Load decks

Create cards

Update cards

Schedule reviews

Track performance

Calculate mastery

Generate statistics
```

---

# 32. SwiftUI Structure

Recommended:

```
Features/

└── Flashcards/

    ├── FlashcardsView.swift

    ├── DeckCard.swift

    ├── DeckDetailView.swift

    ├── FlashcardView.swift

    ├── ReviewSessionView.swift

    ├── CreateFlashcardView.swift

    └── FlashcardsViewModel.swift
```

---

# 33. Navigation Architecture

```
Sidebar

↓

Flashcards

↓

Deck

↓

Review Session

↓

Statistics
```

---

# 34. Data Requirements

Models:

```
Flashcard

FlashcardDeck

ReviewHistory

Course

Lecture

Reading

Concept

StudySession
```

---

# 35. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduced Motion.

---

VoiceOver example:

```
Question:

What is inheritance?


Answer available.

Difficulty:

Good.
```

---

# 36. iPad Requirements

Optimized for:

## Landscape

Supports:

- Deck management.
- Review workflow.
- Keyboard shortcuts.

---

## Portrait

Supports:

- Focused card review.

---

## Apple Pencil

Supports:

- Handwritten answers.
- Diagram questions.

---

# 37. Performance Requirements

Flashcards must:

- Support thousands of cards.
- Load reviews quickly.
- Schedule efficiently.
- Sync reliably with iCloud.

---

# 38. Testing Checklist

```
□ Create flashcard

□ Edit flashcard

□ Delete flashcard

□ Create deck

□ Review cards

□ Rate difficulty

□ Spaced repetition

□ AI generation

□ Search

□ Filters

□ Statistics

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 39. Final Flashcard Architecture

```
Flashcards

        |

        ├── Decks

        ├── Cards

        ├── Review Sessions

        ├── Spaced Repetition

        ├── Statistics

        └── Knowledge Tracking
```

Flashcards transform StudyHub from an organization tool into an active learning system designed for long-term knowledge retention.