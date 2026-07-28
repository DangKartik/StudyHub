# ANIMATIONS

**Project:** StudyHub  
**Document:** 05_ANIMATIONS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the animation system for StudyHub.

Animations establish:

- User understanding
- Interface feedback
- Spatial relationships
- Emotional quality
- Premium Apple-like experience

The goal is not to make StudyHub flashy.

The goal is:

> Every animation should explain a change, provide feedback, or improve usability.

---

# 2. Animation Philosophy

StudyHub follows Apple's animation principles:

```
Purposeful

↓

Natural

↓

Fast

↓

Subtle
```

Animations should feel:

- Smooth
- Responsive
- Calm
- Intelligent

---

# 3. Animation Goals

Animations should:

- Communicate state changes.
- Confirm user actions.
- Guide attention.
- Improve navigation.
- Create continuity.

Animations should NOT:

- Distract users.
- Slow down workflows.
- Add unnecessary decoration.

---

# 4. Animation Architecture

Animation system:

```
User Action

↓

State Change

↓

SwiftUI Animation

↓

Visual Feedback
```

---

# 5. Animation Categories

StudyHub animations are divided into:

```
Micro Interactions

↓

Component Animations

↓

Navigation Animations

↓

Data Animations

↓

Learning Animations
```

---

# 6. Animation Principles

## Principle 1: Immediate Feedback

Every important user action should receive feedback.

Examples:

- Button press
- Completing assignment
- Saving notes
- Reviewing flashcards

---

## Principle 2: Preserve Context

Animations should show where something came from and where it goes.

Example:

Opening a course:

```
Course Card

↓

Course Detail Page
```

The user should understand the transition.

---

## Principle 3: Respect User Focus

StudyHub is a productivity application.

Animations should never interrupt studying.

---

# 7. Animation Timing System

StudyHub uses Apple-like durations.

---

# Instant

Duration:

```
100ms
```

Used for:

- Button feedback
- Small state changes

---

# Quick

Duration:

```
200ms
```

Used for:

- Icons
- Toggles
- Small transitions

---

# Standard

Duration:

```
300ms
```

Used for:

- Cards
- Navigation
- Sheets

---

# Slow

Duration:

```
500ms+
```

Used for:

- Major visual moments
- Achievement animations

---

# 8. Animation Curves

Preferred:

```
.easeInOut
```

For:

- General transitions

---

```
.spring()
```

For:

- Interactive movement
- Cards
- Toggles

---

Avoid:

```
.linear
```

unless required.

---

# 9. SwiftUI Animation Rules

Preferred:

```swift
withAnimation {
    state.toggle()
}
```

---

For interactive elements:

```swift
.animation(
    .spring(),
    value: state
)
```

---

# 10. Button Animations

Buttons provide immediate feedback.

Examples:

- Press scale
- Color transition
- Loading state

---

Button press:

```
Scale

1.0

↓

0.97

↓

1.0
```

Duration:

```
100ms
```

---

# 11. Card Animations

Cards are a major StudyHub design element.

Used for:

- Courses
- Assignments
- Statistics
- Dashboard widgets

---

Card interactions:

```
Default

↓

Hover / Press

↓

Selected
```

---

Animation:

- Small elevation change
- Slight scale
- Material transition

---

# 12. Navigation Animations

Navigation should feel connected.

Examples:

- Sidebar selection
- Course opening
- Detail navigation

---

Rules:

Use:

- Native NavigationStack transitions
- Matched geometry where useful

Avoid:

- Custom page animations everywhere

---

# 13. Sidebar Animation

When selecting sidebar items:

Animation:

```
Selection Indicator

↓

Moves smoothly
```

Duration:

```
200ms
```

---

# 14. Sheet Animations

Used for:

- Creating courses
- Editing assignments
- Adding flashcards

Use:

```
Native iPadOS sheet presentation
```

---

Avoid:

- Custom modal replacements

---

# 15. Progress Animations

Used for:

- Study progress
- Grades
- Completion

Examples:

```
0%

↓

75%
```

---

Animation:

Smooth filling.

Duration:

```
500ms
```

---

# 16. Progress Ring Animation

Used for:

- Dashboard goals
- Study streak
- Semester progress

Behavior:

On appearance:

```
0

↓

Current Value
```

---

Rules:

- Animate once.
- Avoid repeated distracting animations.

---

# 17. Chart Animations

Charts should animate when data appears.

Examples:

- Study hours
- Grade trends
- Flashcard accuracy

---

Animation:

```
Data Points

↓

Visible Chart
```

Duration:

```
500ms
```

---

# 18. Completion Animations

Used for:

- Completing assignments
- Finishing study sessions
- Achieving streaks

---

Example:

Assignment completion:

```
Checkbox

↓

Checkmark

↓

Subtle celebration
```

---

Avoid:

- Excessive fireworks
- Gamification overload

---

# 19. Flashcard Animations

Flashcards require special interaction.

---

Flip Animation:

Front:

```
Question
```

↓

Rotate

↓

Back:

```
Answer
```

---

Recommended:

3D rotation effect.

Duration:

```
300ms
```

---

# 20. Active Recall Animations

When revealing answers:

Use:

- Fade
- Slide
- Material transition

Avoid:

- Large movements

---

# 21. Pomodoro Animations

Timer animations:

Used for:

- Start
- Pause
- Complete

---

Examples:

Timer starts:

```
Idle

↓

Running
```

---

Completion:

```
Timer Complete

↓

Subtle feedback
```

---

# 22. Loading Animations

Loading should communicate progress.

Types:

## Skeleton Loading

Preferred for:

- Lists
- Cards
- Dashboard

---

## Progress Indicator

Used for:

- Sync
- AI generation

---

# 23. AI Feature Animations

AI features require special handling.

Examples:

- Generate flashcards
- Summarize notes

---

Animation:

```
Request

↓

Processing

↓

Result
```

---

Use:

- Subtle shimmer
- Progress indicator

Avoid:

- Excessive AI branding effects

---

# 24. Quote Animations

Daily quote transition:

```
Old Quote

↓

Fade

↓

New Quote
```

Duration:

```
300ms
```

---

# 25. Calendar Animations

Calendar transitions:

Examples:

- Changing weeks
- Opening events

Use:

- Smooth movement
- Minimal delay

---

# 26. Search Animations

Search should feel instant.

Examples:

Typing:

```
Results update
```

Transition:

```
200ms fade
```

---

# 27. Empty State Animations

Empty states may include:

- Gentle icon movement
- Fade appearance

Example:

```
No Courses Yet

Icon appears

↓

Message appears

↓

Button appears
```

---

# 28. Reduce Motion Support

StudyHub must support:

```
Settings

↓

Accessibility

↓

Reduce Motion
```

---

When enabled:

Replace:

- Movement

with:

- Fade
- Instant transitions

---

# 29. Animation Accessibility

Animations must:

- Not communicate information only through motion.
- Work with VoiceOver.
- Not cause discomfort.
- Respect system settings.

---

# 30. Performance Rules

Animations must:

- Use SwiftUI native animations.
- Avoid expensive rendering.
- Avoid unnecessary continuous animations.

---

# 31. Avoided Animation Patterns

Do not use:

## Constant Motion

Example:

Always moving dashboard elements.

---

## Excessive Bounce

Example:

Every button bouncing.

---

## Long Transitions

Example:

5-second page animations.

---

## Decorative Motion

Example:

Moving backgrounds everywhere.

---

# 32. Animation Implementation Structure

Recommended:

```
DesignSystem/

↓

Animations/

├── AnimationTokens.swift

├── Transition.swift

└── Motion.swift
```

---

# 33. Animation Tokens

Example:

```swift
enum AnimationTokens {

    static let quick =
        Animation.easeInOut(duration: 0.2)

    static let standard =
        Animation.easeInOut(duration: 0.3)

    static let spring =
        Animation.spring()

}
```

---

# 34. Testing Requirements

Animations must be tested on:

- iPad Pro
- iPad Air
- Landscape mode
- Split View
- Stage Manager
- Reduce Motion mode

---

# 35. Animation Rules Summary

Mandatory rules:

- Every animation needs a purpose.
- Prefer native SwiftUI transitions.
- Keep animations subtle.
- Respect Reduce Motion.
- Use consistent timing.
- Never sacrifice performance.
- Avoid unnecessary decoration.

---

# 36. Animation Architecture Summary

StudyHub animation system creates a premium experience through:

```
User Action

↓

Meaningful Motion

↓

Clear Feedback

↓

Improved Understanding
```

The result should feel like an Apple-designed academic application: smooth, responsive, and focused.