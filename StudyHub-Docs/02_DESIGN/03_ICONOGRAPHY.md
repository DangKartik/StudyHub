# ICONOGRAPHY

**Project:** StudyHub  
**Document:** 03_ICONOGRAPHY.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the iconography system used throughout StudyHub.

Icons are a critical part of the StudyHub experience because the application contains a large academic ecosystem:

- Courses
- Lectures
- Assignments
- Readings
- Flashcards
- Study sessions
- Calendar events
- Statistics
- AI tools

The goal is to create an icon system that feels native to Apple's design language.

---

# 2. Iconography Philosophy

StudyHub follows the principle:

> Icons should improve recognition, navigation, and understanding. They should never replace clear communication.

Icons should be:

- Simple
- Recognizable
- Consistent
- Accessible
- Meaningful

---

# 3. Icon Design Direction

StudyHub uses Apple's:

```
SF Symbols
```

as the primary icon library.

Benefits:

- Native iPadOS appearance
- Automatic weight adaptation
- Dark Mode support
- Accessibility support
- Dynamic scaling

---

# 4. SF Symbols Usage

Preferred:

```swift
Image(systemName: "calendar")
```

Avoid:

- Custom icons unnecessarily
- Emoji as interface icons
- Decorative illustrations replacing actions

---

# 5. Icon Categories

StudyHub icons are grouped into:

```
Navigation Icons

↓

Academic Icons

↓

Action Icons

↓

Status Icons

↓

Learning Icons

↓

System Icons
```

---

# 6. Navigation Icons

Used in sidebar navigation.

---

## Dashboard

Symbol:

```
house
```

Purpose:

Main overview screen.

---

## Calendar

Symbol:

```
calendar
```

Purpose:

Unified academic schedule.

---

## Courses

Symbol:

```
books.vertical
```

Purpose:

Course management.

---

## Assignments

Symbol:

```
checklist
```

Purpose:

Task tracking.

---

## Readings

Symbol:

```
book
```

Purpose:

Reading tracker.

---

## Flashcards

Symbol:

```
rectangle.stack
```

Purpose:

Memory learning.

---

## Statistics

Symbol:

```
chart.bar
```

Purpose:

Academic analytics.

---

## Settings

Symbol:

```
gearshape
```

Purpose:

Application settings.

---

# 7. Academic Icons

Academic entities use consistent visual language.

---

# Course

Symbol:

```
book.closed
```

Meaning:

Academic subject.

---

# Lecture

Symbol:

```
person.crop.rectangle
```

Meaning:

Teaching session.

---

# Assignment

Symbol:

```
doc.text
```

Meaning:

Academic task.

---

# Reading

Symbol:

```
book.pages
```

Meaning:

Learning material.

---

# Quiz

Symbol:

```
questionmark.circle
```

Meaning:

Assessment.

---

# Exam

Symbol:

```
graduationcap
```

Meaning:

Major assessment.

---

# Lab

Symbol:

```
flask
```

Meaning:

Practical session.

---

# Tutorial

Symbol:

```
person.2
```

Meaning:

Group learning.

---

# Resource

Symbol:

```
paperclip
```

Meaning:

Attached material.

---

# 8. Learning Feature Icons

---

# Active Recall

Symbol:

```
brain
```

Meaning:

Knowledge retrieval.

---

# Spaced Repetition

Symbol:

```
arrow.clockwise
```

Meaning:

Repeated review.

---

# Flashcard Review

Symbol:

```
rectangle.stack.fill
```

Meaning:

Card practice.

---

# AI Assistant

Symbol:

```
sparkles
```

Meaning:

Intelligent assistance.

---

# Study Mode

Symbol:

```
bolt.fill
```

Meaning:

Focused learning mode.

---

# Pomodoro

Symbol:

```
timer
```

Meaning:

Focused study session.

---

# 9. Calendar Icons

Calendar events use recognizable symbols.

---

Lecture:

```
person.crop.rectangle
```

---

Assignment Deadline:

```
exclamationmark.circle
```

---

Exam:

```
graduationcap
```

---

Study Session:

```
timer
```

---

Personal Event:

```
calendar.badge.clock
```

---

# 10. Action Icons

Common actions:

---

# Add

Symbol:

```
plus
```

Usage:

Create new content.

Examples:

- Course
- Assignment
- Flashcard

---

# Edit

Symbol:

```
pencil
```

Usage:

Modify existing content.

---

# Delete

Symbol:

```
trash
```

Usage:

Remove content.

---

# Search

Symbol:

```
magnifyingglass
```

Usage:

Global search.

---

# Filter

Symbol:

```
line.3.horizontal.decrease.circle
```

Usage:

Filter content.

---

# Sort

Symbol:

```
arrow.up.arrow.down
```

Usage:

Change ordering.

---

# Share

Symbol:

```
square.and.arrow.up
```

Usage:

Export/share content.

---

# Download

Symbol:

```
arrow.down.circle
```

Usage:

Save resources.

---

# 11. Status Icons

Status icons communicate state.

---

Completed:

```
checkmark.circle.fill
```

---

Pending:

```
clock
```

---

Overdue:

```
exclamationmark.circle.fill
```

---

Locked:

```
lock
```

---

Synced:

```
checkmark.icloud
```

---

Syncing:

```
arrow.triangle.2.circlepath
```

---

Offline:

```
icloud.slash
```

---

# 12. Progress Icons

Used in statistics and dashboard.

---

Study Streak:

```
flame
```

---

Achievement:

```
star
```

---

Goal:

```
target
```

---

Progress:

```
chart.line.uptrend.xyaxis
```

---

# 13. Icon Sizes

StudyHub follows Apple sizing conventions.

---

Small

```
16pt
```

Used for:

- Metadata
- Inline indicators

---

Medium

```
20pt
```

Used for:

- List rows
- Buttons

---

Large

```
28pt
```

Used for:

- Cards
- Feature blocks

---

Hero

```
40pt+

```

Used for:

- Empty states
- Dashboard highlights

---

# 14. Icon Weight

Icons should match text hierarchy.

Recommended:

```
Regular

↓

Medium

↓

Semibold
```

Avoid mixing random weights.

---

# 15. Icon Colors

Icons use semantic colors.

Examples:

Calendar:

```
StudyHub Blue
```

Assignment:

```
Orange
```

Completed:

```
Green
```

Warning:

```
Red
```

---

# 16. Icon Placement

Rules:

## Leading Icons

Used for:

- Lists
- Navigation
- Categories

Example:

```
📚 Courses
```

---

## Trailing Icons

Used for:

- Actions
- Navigation arrows

Example:

```
Assignment >

```

---

## Center Icons

Used for:

- Empty states
- Feature introductions

---

# 17. Icon Accessibility

Every icon must have:

- Accessibility label
- Meaningful description
- VoiceOver support

Example:

Incorrect:

```
Image(systemName:"book")
```

Correct:

```
Accessibility label:

"Courses"
```

---

# 18. Icon Animation

Icons may animate for:

- Loading
- Completion
- Sync status

Examples:

Sync:

```
arrow.triangle.2.circlepath
```

animated rotation.

---

Avoid:

- Decorative animations
- Constant movement

---

# 19. Custom Icons

Custom icons are allowed only when:

- SF Symbols cannot represent the concept.
- The feature requires unique branding.

Examples:

Possible custom icons:

- StudyHub AI assistant
- Achievement badges
- Learning modes

---

# 20. Custom Icon Rules

Custom icons must:

- Match SF Symbols style.
- Support Dark Mode.
- Support accessibility.
- Have consistent stroke weight.

---

# 21. Icon Usage in Components

Components should define icon behavior.

Example:

```
CourseCard

├── Course Icon

├── Course Name

├── Course Code

└── Progress Indicator
```

---

# 22. Sidebar Icon Rules

Sidebar icons:

Size:

```
20pt
```

Alignment:

```
Leading aligned
```

Spacing:

```
12pt from text
```

---

# 23. Widget Icons

Widgets use simplified icons.

Examples:

Quote Widget:

```
quote.opening
```

Schedule Widget:

```
calendar
```

Flashcards Widget:

```
rectangle.stack
```

---

# 24. Icon Consistency Rules

Mandatory:

- Use SF Symbols whenever possible.
- Use one meaning per icon.
- Avoid unnecessary icons.
- Maintain consistent sizes.
- Support accessibility.

---

# 25. Anti-Patterns

Avoid:

## Too Many Icons

Example:

Every line having an icon.

---

## Ambiguous Icons

Example:

Using a random symbol for assignments.

---

## Decorative Icons

Example:

Adding icons only for visual style.

---

# 26. SwiftUI Implementation

Recommended:

```swift
Image(systemName: "calendar")
    .symbolRenderingMode(.hierarchical)
```

---

For colored icons:

```swift
.symbolRenderingMode(.multicolor)
```

---

# 27. Icon Testing

Test:

- Light Mode
- Dark Mode
- Dynamic Type
- VoiceOver
- iPad landscape
- Split View

---

# 28. Iconography Rules Summary

StudyHub icons must:

- Use SF Symbols first.
- Communicate meaning clearly.
- Support accessibility.
- Match Apple's visual language.
- Use semantic colors.
- Avoid unnecessary decoration.

---

# 29. Iconography Architecture Summary

StudyHub iconography creates a consistent visual vocabulary:

```
SF Symbols

↓

Academic Meaning

↓

Navigation

↓

Actions

↓

Status Communication
```

The result is an interface that feels native, polished, and immediately understandable to iPad users.