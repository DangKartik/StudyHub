# SF SYMBOLS GUIDE

**Project:** StudyHub  
**Document:** SF_SYMBOLS_GUIDE.md  
**Version:** 1.0  
**Status:** Reference  
**Owner:** Design + Engineering Team  

---

# 1. Purpose

This document defines the usage guidelines for SF Symbols within StudyHub.

SF Symbols provide:

```
Consistent Iconography

Native Apple Design Language

Accessibility Support

Adaptive Appearance
```

---

# 2. SF Symbols Philosophy

Icons should:

- Communicate meaning quickly.
- Support text labels.
- Follow Apple's visual language.
- Avoid unnecessary decoration.

---

# 3. Symbol Usage Principles

Use symbols for:

```
Navigation

Actions

Status Indicators

Categories

Controls
```

---

Avoid using symbols for:

```
Replacing Important Text

Decorative Elements Only

Complex Concepts
```

---

# 4. Symbol Naming Convention

SF Symbols use descriptive names.

Format:

```
category.action
```

Examples:

```
book

calendar

magnifyingglass

bell
```

---

# 5. StudyHub Icon System

Main categories:

```
Navigation

Academic

Productivity

Learning

Statistics

Settings

System
```

---

# 6. Navigation Symbols

## Home

Symbol:

```
house
```

Usage:

```
Dashboard

Main Entry Point
```

---

## Courses

Recommended:

```
book.closed
```

Usage:

```
Course Library

Academic Content
```

---

## Calendar

Recommended:

```
calendar
```

Usage:

```
Schedule

Deadlines

Events
```

---

## Search

Recommended:

```
magnifyingglass
```

Usage:

```
Global Search
```

---

## Settings

Recommended:

```
gearshape
```

Usage:

```
Application Settings
```

---

# 7. Academic Symbols

## Lecture

Recommended:

```
person.3

rectangle.stack
```

Usage:

```
Lectures

Classes

Learning Material
```

---

## Assignment

Recommended:

```
doc.text
```

Usage:

```
Homework

Tasks

Submissions
```

---

## Reading

Recommended:

```
book.pages
```

Usage:

```
Articles

Papers

Books
```

---

## Notes

Recommended:

```
note.text
```

Usage:

```
Study Notes

Personal Knowledge
```

---

## Resources

Recommended:

```
folder
```

Usage:

```
Files

Materials

Links
```

---

# 8. Learning Feature Symbols

## Flashcards

Recommended:

```
rectangle.on.rectangle
```

Usage:

```
Flashcard Decks

Review Sessions
```

---

## Active Recall

Recommended:

```
brain.head.profile
```

Usage:

```
Memory Practice

Knowledge Testing
```

---

## Study Mode

Recommended:

```
timer
```

Usage:

```
Focus Sessions

Study Timer
```

---

## Pomodoro

Recommended:

```
clock
```

Usage:

```
Timed Sessions
```

---

# 9. Statistics Symbols

## Progress

Recommended:

```
chart.line.uptrend.xyaxis
```

Usage:

```
Learning Progress

Growth Tracking
```

---

## Analytics

Recommended:

```
chart.bar
```

Usage:

```
Statistics Dashboard
```

---

## Goals

Recommended:

```
target
```

Usage:

```
Study Goals

Milestones
```

---

# 10. AI Assistant Symbols

## AI

Recommended:

```
sparkles
```

Usage:

```
AI Features

Smart Suggestions
```

---

## Chat

Recommended:

```
message
```

Usage:

```
AI Conversation

Help
```

---

## Generation

Recommended:

```
wand.and.stars
```

Usage:

```
Content Generation

Summaries
```

---

# 11. Action Symbols

## Add

```
plus
```

Usage:

```
Create New Item
```

---

## Delete

```
trash
```

Usage:

```
Remove Data
```

---

## Edit

```
pencil
```

Usage:

```
Modify Content
```

---

## Save

```
square.and.arrow.down
```

Usage:

```
Save Information
```

---

## Share

```
square.and.arrow.up
```

Usage:

```
Export

Sharing
```

---

# 12. Status Symbols

## Completed

Recommended:

```
checkmark.circle
```

Usage:

```
Completed Tasks

Finished Sessions
```

---

## Warning

Recommended:

```
exclamationmark.triangle
```

Usage:

```
Important Alerts
```

---

## Error

Recommended:

```
xmark.circle
```

Usage:

```
Failed Actions
```

---

## Information

Recommended:

```
info.circle
```

Usage:

```
Helpful Information
```

---

# 13. Calendar Symbols

Events:

```
calendar.badge.clock
```

Deadlines:

```
calendar.badge.exclamationmark
```

Reminder:

```
bell
```

---

# 14. User Symbols

Profile:

```
person.circle
```

Account:

```
person.crop.circle
```

Students:

```
person.2
```

---

# 15. File Symbols

Document:

```
doc
```

PDF:

```
doc.richtext
```

Folder:

```
folder
```

Attachment:

```
paperclip
```

---

# 16. Symbol Weight

SF Symbols support weights:

```
Ultralight

Thin

Light

Regular

Medium

Semibold

Bold

Heavy

Black
```

---

Guideline:

Use:

```
Regular

Medium

Semibold
```

for most UI.

---

# 17. Symbol Scale

Available:

```
Small

Medium

Large
```

---

Use:

Small:

```
Inline Icons
```

Medium:

```
Buttons

Lists
```

Large:

```
Empty States

Feature Highlights
```

---

# 18. Symbol Colors

Use semantic colors:

```
.primary

.secondary

.accentColor

.tint
```

---

Avoid:

```
Hardcoded Colors
```

---

# 19. Accessibility

Every meaningful symbol requires:

```
Accessibility Label
```

Example:

```swift
Image(systemName: "calendar")
.accessibilityLabel("Calendar")
```

---

# 20. Animation

SF Symbols support:

```
Symbol Effects
```

Examples:

```
bounce

pulse

replace

appear

disappear
```

---

Use for:

```
Feedback

State Changes

Completion
```

---

Avoid:

```
Constant Animation
```

---

# 21. Symbol Consistency Rules

Always:

```
Use Existing SF Symbols First

Keep Meaning Consistent

Avoid Duplicate Meanings
```

---

Example:

Correct:

```
Calendar Icon

↓

All Calendar Features
```

Incorrect:

```
Different Calendar Icons Everywhere
```

---

# 22. Custom Icons

Create custom icons only when:

```
No SF Symbol Exists

Brand Identity Requires It

Complex Meaning Needed
```

---

Custom icons must match:

```
Stroke Style

Weight

Size

Visual Language
```

---

# 23. StudyHub Symbol Map

```
Home

house


Courses

book.closed


Calendar

calendar


Assignments

doc.text


Flashcards

rectangle.on.rectangle


Study Mode

timer


Statistics

chart.bar


AI

sparkles


Settings

gearshape
```

---

# 24. Review Checklist

Before adding a symbol:

```
□ Does SF Symbol Already Exist?

□ Does It Communicate Clearly?

□ Is It Accessible?

□ Is Weight Correct?

□ Is It Consistent?
```

---

# 25. Final Principle

SF Symbols are not decoration.

They are a communication system.

Every symbol in StudyHub should help users understand:

```
Where They Are

What They Can Do

What Happened
```

A consistent icon system makes StudyHub feel like a true Apple platform application.