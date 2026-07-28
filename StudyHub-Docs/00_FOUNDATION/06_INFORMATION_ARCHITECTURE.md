# StudyHub Information Architecture

**Version:** 1.0  
**Status:** Information Architecture (IA) Specification  
**Owner:** Product Team

---

# Purpose

This document defines the complete structure of StudyHub.

It specifies:

- Global hierarchy
- Navigation hierarchy
- Data relationships
- Screen hierarchy
- Parent-child relationships
- Object ownership
- Cross-module interactions

This document is the single source of truth for how information is organized throughout the application.

---

# Design Philosophy

The application's architecture follows one simple principle:

> Every piece of information has exactly one logical home.

Users should never wonder where something belongs.

Everything should feel natural.

---

# Core Hierarchy

```
StudyHub
│
├── Home
│
├── Calendar
│
├── Semesters
│
├── Courses
│
├── Assignments
│
├── Readings
│
├── Flashcards
│
├── Study Mode
│
├── Statistics
│
├── Resources
│
├── Quotes
│
└── Settings
```

---

# Root Object

The root object of the application is:

```
StudyHub
```

Everything belongs to StudyHub.

StudyHub owns:

- Settings
- Semesters
- Quotes
- Calendar Connections
- AI Configuration
- Widgets
- Notifications

---

# Semester Hierarchy

```
Semester
│
├── Courses
├── Calendar Events
├── Statistics
├── Flashcards
├── Notes
├── Resources
└── Study History
```

Semesters are completely isolated.

Changing semesters changes the entire working context.

---

# Semester Lifecycle

```
Create

↓

Active

↓

Archive

↓

Restore

↓

Delete
```

Exactly one semester is active.

---

# Course Hierarchy

```
Course
│
├── Overview
├── Lectures
├── Assignments
├── Readings
├── Labs
├── Tutorials
├── Quizzes
├── Exams
├── Gradebook
├── Flashcards
├── Notes
├── Resources
└── Statistics
```

Everything academic belongs to a course.

---

# Course Ownership

A Course owns:

- Lectures
- Assignments
- Readings
- Labs
- Tutorials
- Quizzes
- Exams
- Resources
- Flashcards
- Notes
- Grades

Deleting a course removes every child object after user confirmation.

---

# Lecture Hierarchy

```
Lecture
│
├── Overview
├── Notes
├── Attachments
├── Active Recall
├── Flashcards
├── Resources
└── GoodNotes Link
```

Lectures represent individual teaching sessions.

---

# Lecture Relationships

Lecture

↓

Generates

↓

Notes

↓

Flashcards

↓

Study Sessions

↓

Statistics

---

# Assignment Hierarchy

```
Assignment
│
├── Description
├── Checklist
├── Attachments
├── Rubric
├── Progress
├── Notes
└── Submission
```

Assignments belong to exactly one course.

---

# Reading Hierarchy

```
Reading
│
├── Metadata
├── Progress
├── Notes
├── Highlights
└── Attachments
```

Readings belong to exactly one course.

---

# Flashcard Hierarchy

```
Flashcard
│
├── Front
├── Back
├── Images
├── Tags
├── Statistics
└── Review History
```

Flashcards belong to one course.

Optionally linked to:

- Lecture
- Reading
- Note

---

# Active Recall Hierarchy

```
Lecture

↓

Active Recall

↓

Questions

↓

Attempts

↓

Review History
```

Questions remain connected to their lecture.

---

# Grade Hierarchy

```
Course

↓

Assessment

↓

Grade

↓

Weight

↓

Statistics
```

Grades never exist independently.

Every grade belongs to an assessment.

---

# Resource Hierarchy

```
Course

↓

Resources

↓

PDF

Website

Book

Video

Paper

Folder
```

Resources may optionally reference:

Lecture

Assignment

Reading

---

# Calendar Hierarchy

```
Calendar

│

├── StudyHub Calendar

├── Apple Calendar

├── Google Calendar

├── Personal

├── Work

├── Family

└── Shared
```

These calendars appear merged.

Internally they remain separate.

---

# Event Ownership

Events may belong to:

StudyHub

Apple Calendar

Google Calendar

StudyHub events may sync externally.

External events remain owned by their original source.

---

# Quote Hierarchy

```
Quote Collection

↓

Quote

↓

History

↓

Random Selection Queue
```

Quotes are global.

Not semester-specific.

---

# Statistics Hierarchy

Statistics aggregate information from:

Assignments

↓

Readings

↓

Flashcards

↓

Study Sessions

↓

Grades

↓

Attendance

↓

Calendar

Statistics never own data.

They only summarize.

---

# Study Mode Hierarchy

```
Study Mode

│

├── Generated Session

├── Pomodoro

├── Flashcards

├── Active Recall

├── Reading

└── Summary
```

Study Mode never stores permanent content.

It consumes existing data.

---

# Dashboard Hierarchy

```
Dashboard

│

├── Greeting

├── Daily Quote

├── Today's Schedule

├── Tasks

├── Deadlines

├── Progress

├── Statistics

├── Quick Actions

└── Recommendation
```

Dashboard never owns data.

Everything displayed is derived.

---

# Notes Hierarchy

Notes may belong to:

Course

Lecture

Reading

Assignment

General

```
Notes

↓

Sections

↓

Images

↓

Links

↓

Attachments
```

---

# GoodNotes Relationship

```
Course

↓

GoodNotes Notebook

↓

Lecture

↓

Open Notebook
```

StudyHub stores only references.

GoodNotes remains responsible for handwritten content.

---

# AI Hierarchy

```
AI Assistant

│

├── Summary

├── Quiz Generation

├── Flashcard Generation

├── Explanation

├── Weak Topic Detection

└── Study Recommendation
```

AI never owns permanent data.

Generated content becomes user-owned after creation.

---

# Widget Hierarchy

Widgets display information from:

Dashboard

↓

Statistics

↓

Assignments

↓

Calendar

↓

Flashcards

Widgets never modify data.

Read-only.

---

# Notification Hierarchy

Notifications may originate from:

Lecture

Assignment

Reading

Quiz

Exam

Study Session

Flashcard Review

Notifications reference existing objects.

---

# Settings Hierarchy

```
Settings

│

├── Appearance

├── Notifications

├── Calendar

├── Google

├── Apple

├── iCloud

├── Apple Pencil

├── Quotes

├── AI

├── Data

└── About
```

Settings are global.

---

# Data Relationships

```
Semester

↓

Course

↓

Lecture

↓

Flashcards

↓

Review History
```

```
Semester

↓

Course

↓

Assignment
```

```
Semester

↓

Course

↓

Reading
```

```
Semester

↓

Course

↓

Resources
```

Everything academic flows downward.

Nothing should bypass the hierarchy.

---

# Cross References

Certain objects may reference one another.

Examples:

Assignment

↓

Reading

Lecture

↓

Resource

Flashcard

↓

Lecture

Study Session

↓

Flashcards

These are references only.

Ownership never changes.

---

# Object Ownership Rules

Each object has exactly one owner.

Example

```
Semester

owns

Course
```

Course owns Lecture.

Lecture owns Active Recall.

Active Recall owns Review Attempts.

This avoids ambiguity.

---

# Global Search Scope

Search indexes:

Courses

Lectures

Assignments

Readings

Resources

Notes

Flashcards

Quotes

Search results should display the parent object for context.

Example

```
Flashcard

↓

Course

↓

Semester
```

---

# Filtering Hierarchy

Every module supports filtering.

Examples

Assignments

↓

Priority

↓

Status

↓

Course

↓

Due Date

Flashcards

↓

Tag

↓

Course

↓

Review Due

↓

Difficulty

---

# Tagging System

Tags are optional.

Supported on:

Notes

Flashcards

Resources

Readings

Assignments

Tags are global within the active semester.

---

# Archiving Rules

Archiving preserves data.

Archived objects become read-only unless restored.

Supported:

Semester

Course

Resource

Notes (future)

Assignments cannot be archived.

Completed assignments remain visible.

---

# Deletion Rules

Deletion removes:

Object

↓

Children

↓

Relationships

↓

Statistics References

Users receive confirmation before permanent deletion.

---

# Data Isolation

The following are isolated per semester:

Courses

Assignments

Lectures

Flashcards

Notes

Statistics

Grades

Resources

Study Sessions

Review History

---

# Global Objects

The following exist outside semesters:

Settings

Quotes

Calendar Connections

Appearance

AI Configuration

Notification Preferences

Widgets

App Preferences

---

# Information Architecture Summary

```
StudyHub

│

├── Global Objects
│
│   ├── Settings
│   ├── Quotes
│   ├── AI
│   ├── Widgets
│   └── Calendar Connections
│
└── Active Semester
    │
    ├── Courses
    │   │
    │   ├── Lectures
    │   ├── Assignments
    │   ├── Readings
    │   ├── Resources
    │   ├── Notes
    │   ├── Flashcards
    │   ├── Grades
    │   └── Statistics
    │
    ├── Calendar
    │
    ├── Study Mode
    │
    └── Semester Statistics
```

---

# Architectural Principles

1. Every object has one owner.

2. Parent objects control child objects.

3. Derived information is never duplicated.

4. Statistics summarize existing data.

5. Dashboard aggregates information.

6. Search indexes all user-created content.

7. Semesters isolate academic data.

8. Global settings remain available regardless of semester.

9. The hierarchy should scale to thousands of objects without requiring structural changes.

10. Every future feature must fit naturally into this information architecture before implementation.