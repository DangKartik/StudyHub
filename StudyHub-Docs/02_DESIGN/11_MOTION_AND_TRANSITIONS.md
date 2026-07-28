# MOTION AND TRANSITIONS

**Project:** StudyHub  
**Document:** 11_MOTION_AND_TRANSITIONS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the motion and transition system for StudyHub.

Motion creates a sense of:

- Spatial understanding
- Continuity
- Responsiveness
- Premium interaction quality

The goal is to make StudyHub feel like a first-party Apple application.

---

# 2. Motion Philosophy

StudyHub follows Apple's motion principles:

> Motion should explain relationships, not decorate the interface.

Every transition should answer:

- Where did this object come from?
- Where is it going?
- What changed?
- Why did it change?

---

# 3. Motion Goals

Motion should:

- Guide attention.
- Maintain context.
- Confirm actions.
- Reduce cognitive load.
- Improve navigation.

Motion should not:

- Distract students.
- Slow workflows.
- Create unnecessary complexity.

---

# 4. Motion Principles

## Principle 1: Continuity

Users should understand how screens and objects are connected.

Example:

Course Card:

```
Course List

↓

Course Detail
```

The transition should preserve the relationship.

---

## Principle 2: Hierarchy

Important changes should receive stronger motion.

Example:

Creating a new course:

Higher emphasis.

Changing a filter:

Lower emphasis.

---

## Principle 3: Responsiveness

Interactions should feel immediate.

Target:

```
User Action

↓

Immediate Feedback

↓

Animation
```

---

# 5. Motion Architecture

Motion system:

```
User Interaction

↓

State Change

↓

Transition System

↓

Visual Response
```

---

# 6. Motion Categories

StudyHub motion consists of:

```
Micro Motion

↓

Component Motion

↓

Navigation Motion

↓

Content Motion

↓

Learning Motion
```

---

# 7. Motion Tokens

All animations use centralized tokens.

Recommended:

```
Motion/

├── MotionTokens.swift

├── TransitionTokens.swift

└── SpringTokens.swift
```

---

# 8. Duration System

## Instant

Duration:

```
100ms
```

Used for:

- Button feedback
- Small state changes

---

## Fast

Duration:

```
200ms
```

Used for:

- Icons
- Toggles
- Selection changes

---

## Standard

Duration:

```
300ms
```

Used for:

- Cards
- Sheets
- Navigation

---

## Emphasized

Duration:

```
500ms
```

Used for:

- Major moments
- Achievements

---

# 9. Animation Curves

Preferred:

## Spring

Used for:

- Interactive objects
- Cards
- Drag operations

Example:

```
.spring()
```

---

## Ease In Out

Used for:

- Standard transitions

Example:

```
.easeInOut
```

---

Avoid:

```
.linear
```

unless representing continuous progress.

---

# 10. Navigation Transitions

StudyHub uses:

```
NavigationStack
```

as the default navigation system.

---

Navigation examples:

```
Dashboard

↓

Course

↓

Lecture

↓

Notes
```

---

Motion:

- Slide transition
- Fade relationship
- Native iPadOS behavior

---

# 11. Sidebar Transitions

StudyHub uses iPad-native sidebar navigation.

When selecting:

```
Courses

↓

Calendar

↓

Statistics
```

Motion:

- Selection indicator movement
- Content replacement transition

Duration:

```
200ms
```

---

# 12. Tab and Section Switching

When changing sections:

Example:

```
Assignments

↓

Flashcards
```

Use:

- Fade transition
- Content replacement

Avoid:

- Large page animations

---

# 13. Card Transitions

Cards are important StudyHub components.

Examples:

- Course cards
- Assignment cards
- Study statistics cards

---

Card states:

```
Collapsed

↓

Selected

↓

Expanded
```

---

Use:

```
matchedGeometryEffect
```

when appropriate.

---

# 14. Sheet Presentation

Sheets are used for:

- Creating courses
- Adding assignments
- Editing flashcards

---

Use native:

```
.sheet()
```

behavior.

---

Motion:

```
Bottom-up presentation

↓

Interactive dismissal
```

---

# 15. Create Flow Motion

Example:

Creating assignment:

```
+

↓

Create Sheet

↓

Save

↓

Assignment Appears
```

---

Motion:

1. Sheet appears.
2. User completes form.
3. New item fades into list.

---

# 16. Delete Motion

Deletion should communicate removal.

Example:

Deleting assignment:

```
Assignment

↓

Fade

↓

Removed
```

---

Avoid:

Sudden disappearance.

---

# 17. Drag and Drop Motion

Used for:

- Calendar events
- Task organization
- Resources

---

States:

```
Idle

↓

Dragging

↓

Placement

↓

Completed
```

---

Motion:

- Object follows finger/pointer.
- Destination highlights.
- Drop confirms.

---

# 18. Calendar Motion

Calendar is a major StudyHub feature.

Supported transitions:

## Week Change

Example:

```
Monday Week 1

↓

Monday Week 2
```

Motion:

Horizontal transition.

---

## Event Creation

```
Empty Slot

↓

Event Card
```

Motion:

Scale + fade.

---

# 19. Dashboard Motion

Dashboard should feel alive but calm.

On appearance:

```
Greeting

↓

Widgets

↓

Statistics
```

---

Use:

- Small staggered appearance
- Fade transitions

---

Avoid:

Every widget bouncing independently.

---

# 20. Progress Motion

Used for:

- Grade progress
- Study goals
- Course completion

---

Example:

```
25%

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

# 21. Chart Motion

Charts should reveal information gradually.

Examples:

Line chart:

```
Line draws
```

Bar chart:

```
Bars rise
```

---

Rules:

- Animate once.
- Avoid continuous movement.

---

# 22. Flashcard Motion

Flashcards use educational motion.

---

Flip:

```
Question

↓

Rotation

↓

Answer
```

---

Purpose:

Create mental separation between:

- Recall phase
- Feedback phase

---

Duration:

```
300ms
```

---

# 23. Active Recall Motion

Answer reveal:

```
Hidden Answer

↓

Reveal
```

Use:

- Fade
- Expand

Avoid:

Large movements.

---

# 24. Pomodoro Motion

Timer states:

```
Idle

↓

Running

↓

Completed
```

---

Running:

Minimal motion.

---

Completion:

Subtle celebration.

---

# 25. Achievement Motion

Used for:

- Study streaks
- Goals
- Milestones

---

Example:

```
7 Day Study Streak

↓

Success Animation
```

---

Rules:

Keep it premium.

Avoid game-like effects.

---

# 26. AI Feature Motion

AI generation:

```
Request

↓

Processing

↓

Result
```

---

Use:

- Subtle progress animation
- Sparkle indicator
- Fade result appearance

---

Avoid:

Overly futuristic animations.

---

# 27. Loading Motion

Loading uses:

- Skeleton shimmer
- Progress animation
- Fade transitions

---

Respect:

```
Reduce Motion
```

---

# 28. Empty State Motion

Empty states may animate:

Example:

```
Icon

↓

Text

↓

Button
```

---

Timing:

```
300ms
```

---

# 29. Search Motion

Search results should update smoothly.

Example:

```
Typing

↓

Filtering

↓

Results
```

---

Use:

- Fade
- Content replacement

---

# 30. Accessibility Motion Rules

Motion must support:

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

```
Movement

```

with:

```
Fade

Opacity Change

Instant Transition
```

---

# 31. Motion Performance

Motion must:

- Maintain 60 FPS.
- Avoid heavy effects.
- Use SwiftUI optimized animations.

---

Avoid:

- Blur-heavy animations.
- Complex particle effects.
- Constant animations.

---

# 32. Implementation Guidelines

Preferred:

```swift
withAnimation(.spring()) {

    state.toggle()

}
```

---

Transitions:

```swift
.transition(.opacity)
```

---

Matched Geometry:

Use only for meaningful relationships.

---

# 33. Motion Components

Recommended:

```
DesignSystem/

├── Motion/

│
├── MotionTokens.swift

├── Transitions.swift

├── SpringAnimations.swift

└── MotionModifiers.swift
```

---

# 34. Testing Requirements

Test:

```
□ iPad Pro

□ iPad Air

□ Landscape mode

□ Stage Manager

□ Split View

□ Reduce Motion

□ VoiceOver

□ External keyboard
```

---

# 35. Motion Anti-Patterns

Avoid:

## Excessive Animation

Example:

Every interaction animates.

---

## Slow Transitions

Example:

5-second navigation.

---

## Decorative Motion

Example:

Moving backgrounds.

---

## Hidden Meaning

Example:

Only animation explains a state change.

---

# 36. Motion Rules Summary

Mandatory:

- Motion must have purpose.
- Use consistent timing.
- Follow iPadOS patterns.
- Respect accessibility.
- Prioritize clarity.
- Never sacrifice performance.

---

# 37. Motion Architecture Summary

StudyHub motion system:

```
User Action

↓

Meaningful Transition

↓

Clear Understanding

↓

Premium Experience
```

The final experience should feel like an Apple-designed academic operating system: calm, responsive, and intelligent.