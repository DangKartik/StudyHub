# SPACING SYSTEM

**Project:** StudyHub  
**Document:** 02_SPACING_SYSTEM.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Design Team  

---

# 1. Purpose

This document defines the spacing system used throughout StudyHub.

Spacing establishes:

- Visual hierarchy
- Content grouping
- Information density
- Readability
- Touch-friendly interaction
- Consistent layout behavior

The goal is to create an interface that feels like a native Apple iPadOS application.

---

# 2. Spacing Philosophy

StudyHub follows the principle:

> Good spacing creates clarity. Empty space is a design tool, not wasted space.

The application should feel:

- Calm
- Organized
- Premium
- Easy to scan

---

# 3. Design Goals

The spacing system must provide:

- Consistent layouts
- Strong visual hierarchy
- Comfortable reading
- Efficient use of iPad screen space
- Support for different screen sizes

---

# 4. Base Spacing Unit

StudyHub uses an 8-point spacing system.

Primary unit:

```
8pt
```

All spacing values should be multiples of:

```
4pt

or

8pt
```

---

# 5. Spacing Scale

The official spacing scale:

```
0pt

4pt

8pt

12pt

16pt

20pt

24pt

32pt

40pt

48pt

64pt
```

---

# 6. Spacing Tokens

Implementation:

```
DesignSystem

↓

Spacing

↓

Tokens
```

Example:

```swift
enum Spacing {

    static let xSmall = 4

    static let small = 8

    static let medium = 16

    static let large = 24

    static let xLarge = 32

}
```

---

# 7. Spacing Categories

StudyHub spacing is divided into:

```
Micro Spacing

↓

Component Spacing

↓

Section Spacing

↓

Page Spacing
```

---

# 8. Micro Spacing

Used for small relationships.

Examples:

- Icon and text
- Label and value
- Small metadata

Values:

```
4pt

8pt
```

---

Example:

```
📅  Friday

10:30 AM
```

Spacing:

```
8pt
```

---

# 9. Component Spacing

Used inside reusable components.

Examples:

- Cards
- Buttons
- Rows
- Cells

Values:

```
12pt

16pt
```

---

Example:

Course Card:

```
-----------------

Course Name

Course Code

Instructor

-----------------
```

Internal padding:

```
16pt
```

---

# 10. Section Spacing

Used between major content groups.

Examples:

- Dashboard sections
- Course modules
- Settings groups

Values:

```
24pt

32pt
```

---

Example:

Dashboard:

```
Today's Schedule


24pt


Upcoming Assignments
```

---

# 11. Page Spacing

Used for overall screen layout.

Values:

```
32pt

40pt

48pt
```

---

# 12. iPad Layout Spacing

StudyHub is designed for iPad first.

Recommended:

## Sidebar

Horizontal padding:

```
16pt
```

---

## Main Content Area

Horizontal padding:

```
24pt - 32pt
```

---

## Large Dashboard Screens

Horizontal padding:

```
40pt
```

---

# 13. Card Spacing

Cards are one of the primary UI elements.

Rules:

Card internal padding:

```
16pt
```

Card-to-card spacing:

```
12pt

16pt
```

Card section spacing:

```
24pt
```

---

Example:

```
Course Card


16pt padding


Assignment Card


16pt spacing


Reading Card
```

---

# 14. List Spacing

StudyHub uses Apple-style list spacing.

Rows:

Minimum height:

```
44pt
```

Recommended:

```
52pt - 60pt
```

---

Between list sections:

```
24pt
```

---

# 15. Button Spacing

Buttons must remain touch friendly.

Minimum touch target:

```
44pt × 44pt
```

---

Button internal padding:

Horizontal:

```
16pt
```

Vertical:

```
10pt
```

---

# 16. Icon Spacing

Icons should have breathing room.

Examples:

Icon + Label:

```
8pt
```

Icon inside button:

```
12pt
```

---

# 17. Text Spacing

Typography and spacing work together.

---

Heading to Body:

```
8pt
```

---

Body to Metadata:

```
4pt
```

---

Section Title to Content:

```
16pt
```

---

# 18. Dashboard Spacing

The dashboard contains many information blocks.

Structure:

```
Greeting


32pt


Progress Overview


24pt


Today's Schedule


24pt


Upcoming Tasks


24pt


Study Recommendation
```

---

# 19. Calendar Spacing

Calendar prioritizes information density.

Rules:

Event rows:

```
12pt vertical padding
```

Between days:

```
16pt
```

Between calendar sections:

```
24pt
```

---

# 20. Notes Spacing

Notes require comfortable reading.

Rules:

Paragraph spacing:

```
12pt
```

Heading spacing:

```
16pt

24pt
```

Lists:

```
8pt between items
```

---

# 21. Flashcard Spacing

Flashcards require focus.

Card padding:

```
24pt
```

Question to Answer:

```
32pt
```

Actions:

```
16pt
```

---

# 22. Statistics Spacing

Statistics use cards and visual grouping.

Example:

```
Study Hours Card


24pt


Progress Chart


24pt


Weekly Summary
```

---

# 23. Modal and Sheet Spacing

Sheets follow Apple patterns.

Top padding:

```
24pt
```

Horizontal padding:

```
24pt
```

Bottom safe area respected.

---

# 24. Navigation Spacing

Sidebar:

Item height:

```
44pt
```

Between groups:

```
24pt
```

Sidebar padding:

```
16pt
```

---

# 25. Empty State Spacing

Empty states should feel balanced.

Structure:

```
Icon


16pt


Title


8pt


Description


24pt


Action Button
```

---

# 26. Safe Area Handling

Never ignore system safe areas.

Respect:

- iPad screen edges
- Keyboard
- Stage Manager
- Split View

---

# 27. Adaptive Layout

Spacing should adapt based on available width.

Example:

Compact width:

```
16pt margins
```

Regular width:

```
24-32pt margins
```

Large canvas:

```
40pt margins
```

---

# 28. Split View Spacing

When using multitasking:

StudyHub should maintain:

- Comfortable margins
- Readable cards
- Proper hierarchy

Avoid:

- Cramped layouts
- Tiny content

---

# 29. Stage Manager Support

Layouts should dynamically resize.

Rules:

- Components should not rely on fixed widths.
- Spacing should scale naturally.
- Content should reflow.

---

# 30. Spacing Anti-Patterns

Avoid:

## Too Little Space

Example:

```
Title
Subtitle
Button
```

without separation.

---

## Too Much Space

Example:

A simple list occupying an entire screen.

---

## Random Spacing

Avoid:

```
13pt

27pt

19pt
```

unless required.

---

# 31. SwiftUI Implementation

Recommended:

Use:

```swift
.padding(.medium)

.spacing(.large)
```

through custom tokens.

Avoid:

```swift
.padding(17)
```

---

# 32. Spacing Testing

Test:

- iPad portrait
- iPad landscape
- Split View
- Stage Manager
- Dynamic Type
- Dark Mode

---

# 33. Accessibility Requirements

Spacing must support:

- Larger text sizes
- Touch targets
- VoiceOver navigation
- Reduced visual complexity

---

# 34. Spacing Rules Summary

Mandatory rules:

- Follow the 8pt grid.
- Use spacing tokens.
- Maintain consistent padding.
- Prioritize readability.
- Support adaptive layouts.
- Avoid arbitrary values.
- Respect iPadOS conventions.
- Preserve touch-friendly targets.

---

# 35. Spacing Architecture Summary

StudyHub uses a structured spacing system:

```
Micro Spacing

↓

Component Spacing

↓

Section Spacing

↓

Page Spacing
```

This creates a consistent interface that feels:

- Premium
- Calm
- Organized
- Native to Apple platforms

The spacing system ensures StudyHub can display large amounts of academic information without becoming overwhelming.