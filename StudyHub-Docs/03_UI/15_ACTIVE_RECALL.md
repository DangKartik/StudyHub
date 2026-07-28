# ACTIVE RECALL

**Project:** StudyHub  
**Document:** 15_ACTIVE_RECALL.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Active Recall section provides a structured learning system where students test their understanding instead of passively reviewing information.

It helps students transform:

```
Information

↓

Understanding

↓

Recall

↓

Mastery
```

---

# 2. Active Recall Philosophy

Reading and highlighting create familiarity.

Active recall creates memory.

Traditional workflow:

```
Read Notes

↓

Review Notes Again

↓

Feel Familiar

↓

Forget
```

StudyHub workflow:

```
Learn Concept

↓

Generate Question

↓

Attempt Recall

↓

Check Understanding

↓

Improve Weak Areas
```

---

# 3. User Goals

Users should be able to:

- Create recall questions.
- Practice without seeing answers.
- Identify knowledge gaps.
- Review weak concepts.
- Connect questions with courses.
- Track improvement.

---

# 4. Navigation Flow

Primary:

```
Sidebar

↓

Active Recall
```

---

Course-based:

```
Course Detail

↓

Active Recall

↓

Question Set

↓

Review Session
```

---

Content-based:

```
Lecture

↓

Generate Recall

↓

Practice
```

---

# 5. Active Recall Dashboard

The dashboard provides:

```
Questions Due

Weak Topics

Recent Sessions

Accuracy
```

---

Layout:

```
┌────────────────────────────┐
│ Active Recall          +   │
├────────────────────────────┤
│                            │
│ Due Today                  │
│ 35 Questions               │
│                            │
├────────────────────────────┤
│ Weak Topics                │
│ Algorithms                 │
│                            │
├────────────────────────────┤
│ Recent Session             │
│ 85% Accuracy               │
│                            │
└────────────────────────────┘
```

---

# 6. Question Organization

Questions are organized by:

```
Course

Topic

Lecture

Reading

Concept

Deck
```

---

Example:

```
SC302

↓

Trees

↓

Binary Search Tree Questions
```

---

# 7. Recall Question Types

Supported question types:

```
Definition

Explanation

Comparison

Application

Problem Solving

Derivation

Code Understanding

Diagram Explanation
```

---

# 8. Create Recall Question

Primary action:

```
+
```

---

Options:

```
Create Question

Generate Questions

Import Questions
```

---

# 9. Question Fields

Required:

```
Question

Answer
```

---

Optional:

```
Hint

Explanation

Source

Difficulty

Tags
```

---

# 10. Question Example

Question:

```
Why do we use encapsulation in OOP?
```

---

Answer:

```
Encapsulation hides internal
implementation details and controls
access to object data.
```

---

Metadata:

```
Course:

SC2002


Topic:

Object Oriented Programming
```

---

# 11. Review Mode

The main learning experience.

Flow:

```
Start Session

↓

Show Question

↓

Think

↓

Reveal Answer

↓

Evaluate

↓

Next Question
```

---

# 12. Recall Interface

Example:

```
┌──────────────────────────┐
│                          │
│ Explain polymorphism.    │
│                          │
│                          │
│ Think before revealing  │
│                          │
└──────────────────────────┘
```

---

After reveal:

```
Answer:

Objects can take multiple
forms through a common interface.
```

---

# 13. Self Evaluation

After answering:

User selects:

```
Forgot

Hard

Good

Easy
```

---

This affects:

```
Review Scheduling

Difficulty

Performance Analytics
```

---

# 14. Spaced Recall Scheduling

Questions are scheduled using:

```
Recall Performance

Difficulty

Previous Attempts

Retention
```

---

Example:

```
Forgot

↓

Review Tomorrow


Easy

↓

Review Later
```

---

# 15. Question Difficulty

Levels:

```
Beginner

Intermediate

Advanced

Expert
```

---

Difficulty affects:

```
Recommendations

Review Frequency

Statistics
```

---

# 16. Weak Knowledge Detection

StudyHub identifies weak areas.

Based on:

```
Incorrect Answers

Low Confidence

Repeated Failures
```

---

Example:

```
Weak Topic:

Graph Traversal

Accuracy:

45%
```

---

# 17. Concept Linking

Questions connect to:

```
Courses

Lectures

Readings

Flashcards

Notes
```

---

Example:

```
Question

↓

Lecture 06

↓

Binary Trees

↓

Flashcards
```

---

# 18. AI Recall Generation

Optional AI features:

```
Generate Questions

Generate Explanations

Create Practice Test

Find Knowledge Gaps
```

---

Example:

Input:

```
Lecture Notes
```

Output:

```
15 Recall Questions

5 Difficult Concepts
```

---

# 19. Practice Tests

Users can create tests.

Options:

```
Number of Questions

Topic

Difficulty

Time Limit
```

---

Example:

```
SC302 Practice Test

20 Questions

30 Minutes
```

---

# 20. Statistics

Tracks:

```
Questions Answered

Accuracy

Retention

Weak Topics

Study Time
```

---

Example:

```
Questions:

250


Accuracy:

86%


Retention:

78%
```

---

# 21. Study Session Integration

Users can start:

```
Active Recall Session
```

---

Creates:

```
Study Session

↓

Question Set Reference

↓

Statistics Update
```

---

# 22. Search

Search questions by:

```
Question Text

Answer

Topic

Course

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
OOP Questions

Lecture 4 Recall
```

---

# 23. Filtering

Filters:

```
Due Today

Weak Areas

Incorrect

New

Mastered

Course
```

---

# 24. Sorting

Sort by:

```
Difficulty

Accuracy

Due Date

Recently Added

Topic
```

---

# 25. Empty State

No questions:

```
No Recall Questions Yet

Create questions from lectures,
notes, or readings.

[Create Question]
```

---

# 26. Loading State

Display:

- Question placeholders.
- Statistics skeleton.
- Loading indicators.

---

# 27. Error State

Example:

```
Unable to load questions.

Retry
```

---

# 28. Toolbar

Toolbar:

```
Leading:

Sidebar


Center:

Active Recall


Trailing:

+

Search

Filter
```

---

# 29. Keyboard Shortcuts

During review:

Reveal:

```
Space
```

Rate:

```
1 - Forgot

2 - Hard

3 - Good

4 - Easy
```

---

# 30. ViewModel Responsibilities

ActiveRecallViewModel manages:

```
Load questions

Create questions

Schedule reviews

Track answers

Calculate accuracy

Identify weak topics

Generate statistics
```

---

# 31. SwiftUI Structure

Recommended:

```
Features/

└── ActiveRecall/

    ├── ActiveRecallView.swift

    ├── QuestionCard.swift

    ├── RecallSessionView.swift

    ├── CreateQuestionView.swift

    ├── PracticeTestView.swift

    └── ActiveRecallViewModel.swift
```

---

# 32. Navigation Architecture

```
Sidebar

↓

Active Recall

↓

Question Set

↓

Review Session

↓

Statistics
```

---

# 33. Data Requirements

Models:

```
RecallQuestion

RecallSession

ReviewHistory

Course

Lecture

Reading

Concept

Flashcard

StudySession
```

---

# 34. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduced Motion.

---

VoiceOver example:

```
Question:

Explain inheritance.


Answer hidden.


Difficulty:

Medium.
```

---

# 35. iPad Requirements

Optimized for:

## Landscape

Supports:

- Question management.
- Practice tests.
- Keyboard shortcuts.

---

## Portrait

Supports:

- Focused recall sessions.

---

## Apple Pencil

Supports:

- Handwritten answers.
- Diagram explanations.

---

# 36. Performance Requirements

Active Recall must:

- Handle thousands of questions.
- Schedule efficiently.
- Load sessions quickly.
- Sync progress through iCloud.

---

# 37. Testing Checklist

```
□ Create question

□ Edit question

□ Delete question

□ Start recall session

□ Reveal answers

□ Rate difficulty

□ Spaced repetition

□ Practice tests

□ AI generation

□ Search

□ Filters

□ Statistics

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 38. Final Active Recall Architecture

```
Active Recall

        |

        ├── Questions

        ├── Review Sessions

        ├── Scheduling

        ├── Performance

        ├── Weak Areas

        └── Knowledge Mastery
```

Active Recall transforms StudyHub into a learning engine that helps students actively retrieve knowledge, identify weaknesses, and build long-term understanding.