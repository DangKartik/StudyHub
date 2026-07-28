# COLOR SYSTEM

**Project:** StudyHub  
**Document:** 00_COLOR_SYSTEM.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the color system for StudyHub.

The color system establishes:

- Brand identity
- Light Mode appearance
- Dark Mode appearance
- Semantic colors
- Status indicators
- Course categorization
- Data visualization colors
- Accessibility requirements

The goal is to create a visual language that feels like a first-party Apple application.

---

# 2. Color Philosophy

StudyHub follows the principle:

> Colors should communicate meaning, not decoration.

Colors should help users understand:

- What requires attention.
- What is completed.
- What is upcoming.
- What belongs together.
- What needs action.

The application should remain calm and professional.

---

# 3. Design Goals

The color system must provide:

- High readability
- Accessibility compliance
- Dark Mode support
- Visual hierarchy
- Emotional calmness
- Academic focus

---

# 4. Apple-Inspired Design Direction

StudyHub takes inspiration from:

- Apple Calendar
- Apple Notes
- Apple Reminders
- Apple Health
- Apple Journal

The design language:

```
Minimal

+

Functional

+

Meaningful

+

Adaptive
```

---

# 5. Color Architecture

StudyHub colors are divided into:

```
Brand Colors

↓

Semantic Colors

↓

Academic Colors

↓

Interface Colors

↓

Visualization Colors
```

---

# 6. Brand Identity Colors

StudyHub's primary identity color represents:

- Learning
- Focus
- Progress
- Intelligence

---

# Primary Brand Color

Name:

```
StudyHub Blue
```

Purpose:

- Primary actions
- Selected states
- Navigation
- Links
- Progress indicators

Light Mode:

```
Blue 500
```

Dark Mode:

```
Blue 400
```

Usage:

```
Button

Navigation Selection

Active Course

Progress Ring
```

---

# Secondary Brand Color

Name:

```
StudyHub Indigo
```

Purpose:

- AI features
- Smart recommendations
- Advanced learning tools

Usage:

```
AI Assistant

Study Recommendations

Insights
```

---

# 7. Semantic Colors

Semantic colors communicate application state.

---

# Success Color

Meaning:

- Completed
- Correct
- Achieved
- Positive progress

Examples:

```
Assignment Completed

Flashcard Correct

Study Goal Reached
```

Color:

```
Green
```

---

# Warning Color

Meaning:

- Attention required
- Approaching deadline
- Missing information

Examples:

```
Assignment Due Soon

Incomplete Task
```

Color:

```
Orange
```

---

# Error Color

Meaning:

- Failed action
- Critical problem
- Invalid operation

Examples:

```
Sync Failed

Permission Denied

Invalid Input
```

Color:

```
Red
```

---

# Information Color

Meaning:

- Informational message
- Helpful guidance

Examples:

```
AI Suggestion

New Feature

Tip
```

Color:

```
Blue
```

---

# 8. Academic Category Colors

Academic content uses subtle colors.

These colors help users visually identify information.

---

# Courses

Each course can have a user-selected color.

Example:

```
Computer Science

Blue
```

```
Mathematics

Purple
```

```
Business

Green
```

---

Rules:

- Users can customize colors.
- Colors should not affect readability.
- Colors are secondary identifiers.

---

# Lectures

Default:

```
StudyHub Blue
```

Used for:

- Lecture events
- Course timeline
- Calendar blocks

---

# Assignments

Default:

```
Orange
```

Meaning:

Requires action.

---

# Exams

Default:

```
Red
```

Meaning:

High importance.

---

# Readings

Default:

```
Teal
```

Meaning:

Learning activity.

---

# Flashcards

Default:

```
Purple
```

Meaning:

Memory and revision.

---

# Study Sessions

Default:

```
Green
```

Meaning:

Progress and achievement.

---

# 9. Interface Colors

Interface colors define backgrounds and surfaces.

---

# Background Colors

## Light Mode

Primary background:

```
System Background
```

Secondary background:

```
Secondary System Background
```

Grouped background:

```
System Grouped Background
```

---

## Dark Mode

Primary background:

```
System Background Dark
```

Secondary background:

```
Secondary System Background Dark
```

---

# 10. Surface Colors

Used for:

- Cards
- Panels
- Sheets
- Widgets

Examples:

```
Card Background

Sidebar Background

Floating Panel
```

---

Rules:

Cards should not rely only on shadows.

Use:

- Material backgrounds
- Contrast
- Spacing

---

# 11. Text Colors

StudyHub follows Apple semantic text colors.

---

# Primary Text

Usage:

- Titles
- Important information

Example:

```
Course Name

Assignment Title
```

---

# Secondary Text

Usage:

- Supporting information

Example:

```
Due Tomorrow

Professor Name
```

---

# Tertiary Text

Usage:

- Metadata

Example:

```
Last Updated

Optional Details
```

---

# 12. Divider Colors

Used for:

- Separating sections
- Lists
- Tables

Rules:

Dividers should be subtle.

Avoid strong lines.

---

# 13. Transparency System

StudyHub uses layered transparency.

Inspired by Apple materials.

Examples:

```
Ultra Thin Material

Thin Material

Regular Material

Thick Material
```

Used for:

- Floating cards
- Sidebars
- Overlays
- Toolbars

---

# 14. Dark Mode Rules

Dark Mode is not a color inversion.

Rules:

Do:

- Reduce brightness.
- Preserve hierarchy.
- Maintain readability.

Avoid:

- Pure white backgrounds.
- Extremely bright colors.
- Excessive contrast.

---

# 15. Dynamic Color Support

Colors should adapt automatically.

Implementation:

Use:

```swift
Color.primary

Color.secondary

Color.accentColor
```

Avoid:

```swift
Color(red:0.2, green:0.4, blue:0.8)
```

unless defining design tokens.

---

# 16. SwiftUI Color Tokens

Recommended structure:

```
DesignSystem

↓

Colors

↓

Semantic Tokens
```

Example:

```swift
extension Color {

    static let studyHubBlue =
        Color("StudyHubBlue")

    static let success =
        Color("Success")

}
```

---

# 17. Color Asset Structure

Assets:

```
Assets.xcassets

├── Colors

│
├── StudyHubBlue

├── StudyHubIndigo

├── Success

├── Warning

├── Error

├── Reading

├── Flashcard

└── StudySession
```

---

# 18. Chart Colors

Charts require controlled palettes.

Rules:

- Avoid overly saturated colors.
- Maintain accessibility.
- Work in Dark Mode.

Chart examples:

```
Study Hours

Reading Progress

Grade Distribution

Flashcard Accuracy
```

---

# 19. Progress Colors

Progress indicators:

Completed:

```
Green
```

In Progress:

```
Blue
```

Remaining:

```
Gray
```

Overdue:

```
Red
```

---

# 20. Calendar Colors

Calendar events:

```
Lecture

Blue
```

```
Assignment

Orange
```

```
Exam

Red
```

```
Study Session

Green
```

```
Personal Event

User Selected
```

---

# 21. Accessibility Requirements

Colors must support:

- WCAG contrast standards
- VoiceOver labels
- Color blindness considerations

---

# 22. Never Depend Only on Color

Incorrect:

```
Red = Exam
```

Correct:

```
Red

+

Exam Icon

+

Exam Label

+

Notification
```

---

# 23. Color Usage Rules

## Do

- Use colors consistently.
- Use semantic meaning.
- Support Dark Mode.
- Maintain readability.

---

## Do Not

- Use random colors.
- Use gradients everywhere.
- Use colors only for decoration.
- Overload screens with colors.

---

# 24. Gradient Usage

Gradients are limited to:

- Dashboard hero areas
- AI features
- Achievement moments

Avoid:

- Every card having gradients.
- Heavy visual effects.

---

# 25. Design System Summary

StudyHub uses a semantic color system built around:

```
Brand Identity

↓

Academic Categories

↓

Status Communication

↓

Interface Hierarchy

↓

Data Visualization
```

The color system ensures StudyHub feels:

- Premium
- Calm
- Intelligent
- Academic
- Native to Apple platforms

The goal is a visual language where every color has a purpose.