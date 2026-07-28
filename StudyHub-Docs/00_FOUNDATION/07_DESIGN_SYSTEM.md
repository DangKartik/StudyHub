# StudyHub Design System

**Version:** 1.0  
**Status:** Design System Specification  
**Owner:** Product Design Team

---

# Purpose

This document defines the complete visual language of StudyHub.

Every screen, component, interaction, animation, and layout should follow this design system.

The goal is consistency.

No screen should feel like it was designed independently.

---

# Design Philosophy

StudyHub should feel like:

- Apple Calendar
- Apple Notes
- Apple Health
- Apple Journal
- Apple Reminders

combined into one cohesive application.

Users should immediately recognize familiar interaction patterns.

The interface should feel:

- Calm
- Premium
- Spacious
- Native
- Elegant
- Fast

---

# Design Principles

## 1. Content First

The interface should never compete with the content.

The user's courses, lectures, assignments, and notes are always the primary focus.

---

## 2. Native Before Custom

Whenever SwiftUI provides a native control that meets the requirement, use it.

Avoid reinventing:

- Lists
- Menus
- Sheets
- Date Pickers
- Search
- Navigation
- Toolbars

---

## 3. Progressive Disclosure

Only show information when necessary.

Example

Dashboard

↓

Assignment Card

↓

Assignment Detail

↓

Checklist

↓

Submission Notes

Do not overwhelm the user.

---

## 4. Large Touch Targets

Minimum:

44 × 44 pt

Ideal:

52 × 52 pt

---

## 5. Consistency

Buttons always look identical.

Cards always behave identically.

Spacing is predictable.

Animations are predictable.

---

# Visual Identity

StudyHub is inspired by modern Apple applications.

Avoid:

- Neon colors
- Excessive gradients
- Heavy drop shadows
- Skeuomorphic effects
- Glass-heavy interfaces
- Cluttered dashboards

Instead prefer:

- Rounded cards
- Layered backgrounds
- Soft shadows
- System materials
- SF Symbols
- Plenty of whitespace

---

# Color System

The app should primarily rely on semantic system colors so it automatically adapts to:

- Light Mode
- Dark Mode
- Accessibility
- Future iOS updates

---

## Primary Colors

Background

```
systemBackground
```

Secondary Background

```
secondarySystemBackground
```

Grouped Background

```
systemGroupedBackground
```

---

## Text Colors

Primary

```
label
```

Secondary

```
secondaryLabel
```

Tertiary

```
tertiaryLabel
```

Placeholder

```
placeholderText
```

---

## Accent Color

Default

```
System Tint
```

Users may choose a custom accent.

Example options

Blue

Green

Orange

Purple

Pink

Indigo

Teal

---

## Semantic Colors

Success

Green

Warning

Orange

Error

Red

Information

Blue

Completed

Green

Upcoming

Blue

Overdue

Red

Paused

Gray

---

# Course Colors

Every course may have its own color.

Examples

Mathematics

Blue

Physics

Purple

Computer Science

Indigo

Business

Orange

Chemistry

Green

These colors appear throughout the app.

---

# Typography

Use Apple's San Francisco font exclusively.

Never use custom fonts.

---

## Hierarchy

Large Title

Navigation pages

Title

Major sections

Title 2

Cards

Headline

Card headers

Body

Main content

Callout

Secondary content

Footnote

Metadata

Caption

Supporting text

---

## Rules

Avoid bold everywhere.

Use weight intentionally.

Prefer hierarchy over color.

---

# Iconography

Use SF Symbols only.

Examples

Home

house.fill

Calendar

calendar

Courses

books.vertical.fill

Lecture

person.fill.viewfinder

Assignments

checklist

Readings

book.pages.fill

Flashcards

rectangle.stack.fill

Statistics

chart.bar.fill

Settings

gearshape.fill

Study Mode

brain.head.profile

Resources

folder.fill

Quotes

quote.opening

---

# Layout System

Use an 8-point spacing grid.

Spacing Values

4

8

12

16

20

24

32

40

48

64

Never invent random spacing.

---

# Corner Radius

Small

10

Medium

16

Large

22

Extra Large

28

Sheets

System default

Cards use medium radius.

---

# Elevation

Use minimal shadows.

Cards should appear layered rather than floating.

Prefer:

Material backgrounds

Subtle separation

Thin borders

Avoid large dark shadows.

---

# Card Design

Cards are the primary container.

Cards include

Padding

Rounded corners

Title

Optional subtitle

Optional trailing action

Optional progress

Optional badges

Cards animate slightly when tapped.

---

# Buttons

Primary Button

Filled

Accent Color

Secondary Button

Tinted

System Material

Tertiary Button

Borderless

Toolbar Button

System style

Destructive Button

Red

---

# Lists

Use SwiftUI List whenever possible.

Features

Swipe Actions

Context Menus

Edit Mode

Reordering

Search

Filtering

Selection

---

# Forms

Forms use native SwiftUI Form.

Fields

Text

Date

Time

Picker

Toggle

Stepper

Menu

Segmented Control

Validation should appear inline.

---

# Navigation

Primary navigation uses:

NavigationSplitView

Sidebar

↓

Content

↓

Detail

Large navigation titles.

Toolbar actions remain consistent.

---

# Toolbar

Common toolbar actions

+

Search

Filter

Sort

Edit

Share

Delete

Settings

Toolbar items should remain predictable across modules.

---

# Search

Native searchable modifier.

Features

Live filtering

Suggestions

Recent searches

Empty state

Clear button

---

# Empty States

Every module requires an empty state.

Example

Assignments

Icon

Checklist

Title

No Assignments

Description

Create your first assignment.

Primary Button

Add Assignment

Illustrations should remain simple.

---

# Progress Rings

Inspired by Apple Fitness.

Use for

Study Hours

Reading Progress

Assignments

Weekly Goals

Flashcard Reviews

Animated.

Accessible.

---

# Progress Bars

Used for

Reading

Assignment completion

Course progress

Upload progress

---

# Badges

Examples

Due Today

Tomorrow

Overdue

Completed

High Priority

AI Generated

Badges should remain small.

Never dominate the interface.

---

# Charts

Use Swift Charts.

Supported charts

Bar

Line

Area

Pie (only where appropriate)

Ring

Charts should support:

Dynamic Type

VoiceOver

Dark Mode

---

# Dashboard Layout

```
Greeting

↓

Quote

↓

Today's Schedule

↓

Tasks

↓

Deadlines

↓

Progress Rings

↓

Statistics

↓

Quick Actions

↓

Study Recommendation
```

Dashboard should scroll naturally.

Cards should not exceed comfortable reading width.

---

# Calendar Design

Views

Day

Week

Month

Agenda

Events inherit course colors.

Today is always highlighted.

Current time indicator is red.

---

# Course Screen

Top

Course Banner

↓

Statistics

↓

Tabs

↓

Content

Tabs remain pinned while scrolling.

---

# Lecture Screen

Overview

↓

Objectives

↓

Notes

↓

Active Recall

↓

Flashcards

↓

Attachments

↓

GoodNotes

---

# Assignment Screen

Top Summary

↓

Checklist

↓

Description

↓

Rubric

↓

Attachments

↓

Submission

↓

Notes

---

# Reading Screen

Header

↓

Progress

↓

Estimated Time

↓

Notes

↓

Highlights

↓

Attachments

---

# Flashcard Screen

Front

↓

Reveal

↓

Back

↓

Difficulty Buttons

Again

Hard

Good

Easy

Buttons remain fixed at bottom.

---

# Study Mode

Minimal interface.

Avoid distractions.

Focus timer remains visible.

Progress indicator visible.

Large typography.

---

# Settings

Grouped sections.

Native appearance.

No custom layouts.

Every setting explains itself.

---

# Sheets

Use native sheets.

Preferred heights

Medium

Large

Support drag-to-dismiss.

Unsaved changes require confirmation.

---

# Context Menus

Available on

Courses

Assignments

Readings

Flashcards

Resources

Examples

Edit

Duplicate

Move

Archive

Delete

---

# Swipe Actions

Leading

Complete

Pin

Favorite

Trailing

Edit

Delete

Archive

Keep swipe actions minimal.

---

# Animations

Animations communicate change.

Duration

0.2–0.35 seconds

Use spring animations for:

Card insertion

Completion

Reordering

Use fade animations for:

Loading

Empty states

Filtering

Respect Reduce Motion.

---

# Haptics

Light

Selection

Medium

Completion

Heavy

Destructive confirmation

Success

Assignment completed

Study session finished

---

# Loading States

Never display blank screens.

Use

ProgressView

Skeleton placeholders

Loading text

---

# Accessibility

Support

VoiceOver

Dynamic Type

Reduce Motion

Reduce Transparency

High Contrast

Switch Control

Keyboard Navigation

Apple Pencil

Every control requires:

Accessibility Label

Accessibility Value

Accessibility Hint

---

# Keyboard Shortcuts

⌘N

New Item

⌘F

Search

⌘S

Save (where applicable)

⌘,

Settings

Delete

Delete Selected

Escape

Dismiss Sheet

---

# Apple Pencil

Support

Handwriting attachments

Scribble

Hover (where available)

Drawing attachments

---

# Stage Manager

Layouts adapt smoothly.

Cards resize gracefully.

Sidebars remain usable.

Avoid fixed-width layouts.

---

# Dark Mode

Every component must support Dark Mode.

Avoid hardcoded colors.

Use semantic colors.

Charts remain readable.

Images adapt when appropriate.

---

# Responsive Layout

Small iPad

Single-column content where necessary.

Large iPad

Three-column NavigationSplitView.

Ultra-wide Stage Manager

Expanded cards

Additional statistics

Inspector panels (future)

---

# Design Checklist

Every screen should satisfy the following:

- Uses native navigation
- Uses semantic colors
- Supports Dynamic Type
- Supports Dark Mode
- Supports accessibility
- Uses 8-point spacing
- Uses SF Symbols
- Uses reusable components
- Avoids duplicated UI
- Feels consistent with every other screen

---

# Design System Summary

StudyHub's visual identity should communicate:

- Trust
- Simplicity
- Focus
- Professionalism
- Calm
- Intelligence

If a design decision makes the interface feel more complex than necessary, it should be reconsidered.

The design system exists to ensure that every feature, present and future, feels like part of one carefully crafted product rather than a collection of unrelated screens.