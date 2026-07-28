# TYPOGRAPHY

**Project:** StudyHub  
**Document:** 01_TYPOGRAPHY.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the typography system for StudyHub.

Typography establishes:

- Visual hierarchy
- Information readability
- Academic focus
- Content organization
- Accessibility support

The goal is to create typography that feels like a first-party Apple application.

---

# 2. Typography Philosophy

StudyHub follows the principle:

> Typography should organize information before decorating it.

The user should immediately understand:

- What is important.
- What requires action.
- What is supporting information.
- What belongs together.

---

# 3. Typography Goals

The typography system must provide:

- Excellent readability
- Support for large amounts of information
- Dynamic Type compatibility
- Clear hierarchy
- Native iPadOS appearance
- Accessibility support

---

# 4. Font Family

StudyHub uses Apple's system fonts.

Primary fonts:

```
SF Pro Display

SF Pro Text

SF Mono
```

---

# 5. SF Pro Display

Used for:

- Large titles
- Dashboard headings
- Important numbers
- Hero sections

Examples:

```
Good Morning, Kartik

Your Academic Overview

85% Progress
```

---

# 6. SF Pro Text

Used for:

- Body content
- Lists
- Descriptions
- Notes
- Forms

Examples:

```
Assignment description

Lecture objectives

Course information
```

---

# 7. SF Mono

Used for:

- Code snippets
- Technical content
- Course programming information

Examples:

```
SC2002

Python

Swift
```

---

# 8. SwiftUI Typography System

StudyHub uses:

```swift
Font
```

with:

```swift
.font(.largeTitle)

.font(.title)

.font(.headline)

.font(.body)
```

---

# 9. Typography Scale

StudyHub follows Apple's Dynamic Type scale.

---

# Large Title

Usage:

- Main dashboard greeting
- Major screen titles

Example:

```
Good Morning
```

SwiftUI:

```swift
.largeTitle
```

---

# Title

Usage:

- Section headers
- Important pages

Example:

```
Assignments
```

SwiftUI:

```swift
.title
```

---

# Title 2

Usage:

- Secondary page headings

Example:

```
Course Overview
```

SwiftUI:

```swift
.title2
```

---

# Title 3

Usage:

- Card headings
- Subsections

Example:

```
Upcoming Deadlines
```

SwiftUI:

```swift
.title3
```

---

# Headline

Usage:

- Important labels
- Navigation items

Example:

```
Machine Learning
```

SwiftUI:

```swift
.headline
```

---

# Subheadline

Usage:

- Supporting labels

Example:

```
Due Friday
```

SwiftUI:

```swift
.subheadline
```

---

# Body

Usage:

Primary reading text.

Examples:

- Notes
- Descriptions
- Explanations

SwiftUI:

```swift
.body
```

---

# Callout

Usage:

- Highlighted information
- Important messages

Example:

```
Exam in 3 days
```

SwiftUI:

```swift
.callout
```

---

# Footnote

Usage:

Small metadata.

Examples:

```
Updated 2 hours ago
```

SwiftUI:

```swift
.footnote
```

---

# Caption

Usage:

Smallest supporting text.

Examples:

```
12 cards reviewed
```

SwiftUI:

```swift
.caption
```

---

# 10. StudyHub Custom Text Styles

StudyHub defines custom semantic styles.

---

# Dashboard Greeting

Purpose:

Main home screen greeting.

Example:

```
Good Morning
Kartik
```

Properties:

- Large
- Friendly
- Spacious

---

# Academic Number Style

Used for:

- Grades
- Study hours
- Streaks
- Statistics

Example:

```
42 Hours
```

Properties:

- Large numeric emphasis
- Medium weight

---

# Card Title Style

Used for:

- Course cards
- Assignment cards
- Reading cards

Properties:

- Semibold
- Compact

---

# Metadata Style

Used for:

- Dates
- Times
- Categories

Properties:

- Secondary color
- Smaller size

---

# 11. Font Weight System

StudyHub uses Apple semantic weights.

---

# Regular

Usage:

Normal information.

Example:

```
Lecture description
```

---

# Medium

Usage:

Slight emphasis.

Example:

```
Course code
```

---

# Semibold

Usage:

Important labels.

Example:

```
Assignment Name
```

---

# Bold

Usage:

Rarely used.

Examples:

- Important achievements
- Critical deadlines

---

# 12. Typography Hierarchy

Every screen follows:

```
Screen Title

↓

Section Title

↓

Card Title

↓

Primary Information

↓

Supporting Metadata
```

---

Example:

```
Assignments

↓

Upcoming

↓

Machine Learning Project

↓

Due Friday 11:59 PM

↓

40% Complete
```

---

# 13. Dashboard Typography

The dashboard uses stronger hierarchy.

Example:

```
Good Morning

↓

Today's Schedule

↓

3 Lectures

↓

CS2002

↓

10:30 AM
```

---

# 14. Course Typography

Course pages use:

```
Course Name

Course Code

Instructor

Content Sections
```

Hierarchy:

```
Title

↓

Headline

↓

Body

↓

Caption
```

---

# 15. Notes Typography

Notes prioritize readability.

Rules:

- Comfortable line spacing.
- Larger body text.
- Minimal distractions.

Support:

- Markdown rendering
- Rich text
- Apple Pencil annotations

---

# 16. Flashcard Typography

Flashcards require learning focus.

Front:

```
Large Question Text
```

Back:

```
Answer Content

Explanation

Examples
```

---

# 17. Statistics Typography

Statistics emphasize numbers.

Examples:

```
24

Study Hours
```

```
87%

Flashcard Accuracy
```

Numbers should visually dominate labels.

---

# 18. Calendar Typography

Calendar prioritizes:

- Time
- Event title
- Location
- Category

Example:

```
10:30

SC2002 Lecture

LT1
```

---

# 19. Accessibility

Typography must support:

- Dynamic Type
- VoiceOver
- Larger accessibility sizes
- Reduced text clipping

---

# 20. Dynamic Type Rules

Never hardcode:

```swift
.font(.system(size: 30))
```

Prefer:

```swift
.font(.title)
```

or:

```swift
@ScaledMetric
```

---

# 21. Text Scaling

All important content must remain readable when users increase font size.

Components must:

- Expand vertically.
- Avoid fixed heights.
- Support wrapping.

---

# 22. Text Alignment Rules

Default:

```
Leading alignment
```

Use centered text only for:

- Empty states
- Hero sections
- Statistics

---

# 23. Line Height Rules

Avoid cramped text.

Use:

- Apple's default spacing.
- Additional spacing for notes and explanations.

---

# 24. Truncation Rules

Avoid unnecessary truncation.

Incorrect:

```
Machine Learn...
```

Preferred:

```
Multiple lines
```

---

# 25. Markdown and Rich Text

StudyHub supports rich content.

Examples:

- Lecture notes
- Reading notes
- AI explanations

Typography must support:

- Headers
- Lists
- Code blocks
- Equations

---

# 26. Localization Support

Typography must support:

- Different languages.
- Longer text.
- Dynamic expansion.

Never design assuming only English.

---

# 27. Typography Implementation

Recommended structure:

```
DesignSystem

↓

Typography

↓

TextStyles
```

Example:

```swift
enum StudyHubTextStyle {

    case dashboardTitle

    case cardTitle

    case metadata

}
```

---

# 28. Typography Testing

Test:

- Light Mode
- Dark Mode
- Dynamic Type
- iPad landscape
- Split View
- VoiceOver

---

# 29. Typography Rules Summary

Mandatory rules:

- Use SF Pro fonts.
- Support Dynamic Type.
- Follow Apple's hierarchy.
- Avoid excessive bold text.
- Prioritize readability.
- Never depend on fixed font sizes.
- Use typography to communicate importance.
- Support accessibility.

---

# 30. Typography Architecture Summary

StudyHub typography combines Apple's native typography system with custom academic-focused styles.

The system provides:

- Clear hierarchy
- Premium appearance
- Comfortable reading
- Accessibility support
- Consistent UI across the entire application

The goal is for StudyHub to feel like an Apple-designed academic operating system.