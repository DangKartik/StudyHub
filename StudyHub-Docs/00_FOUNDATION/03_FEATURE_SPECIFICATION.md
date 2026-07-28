# StudyHub Feature Specification

**Version:** 1.0  
**Status:** Functional Requirements Specification (FRS)  
**Owner:** Product Team

---

# Purpose

This document defines every functional feature of StudyHub.

It serves as the implementation specification for software engineers and AI coding agents.

Unless explicitly stated otherwise, all features described here are required for Version 1.0.

---

# Product Modules

StudyHub consists of the following primary modules:

1. Home Dashboard
2. Semester Management
3. Course Management
4. Calendar
5. Lecture Management
6. Assignment Management
7. Reading Tracker
8. Grade Tracker
9. Notes
10. Resources
11. Flashcards
12. Active Recall
13. Spaced Repetition
14. Study Mode
15. Pomodoro
16. Statistics
17. Quote Manager
18. Widgets
19. Notifications
20. Settings
21. AI Assistant

---

# 1. Home Dashboard

## Purpose

The dashboard is the first screen users see.

It should answer:

- What do I have today?
- What should I study?
- What is due next?
- How am I progressing?

---

## Dashboard Sections

### Greeting

Examples:

Good Morning, Kartik

Good Afternoon

Good Evening

Greeting changes automatically based on local time.

---

### Daily Quote

Displays one quote selected from the Quote Manager.

Requirements:

- One quote per day
- No repeats until all quotes have been shown
- Automatically rotates at midnight
- Empty state when no quotes exist

---

### Today's Schedule

Displays:

- Lectures
- Labs
- Tutorials
- Study Sessions
- Calendar Events

Sorted chronologically.

---

### Today's Tasks

Includes:

- Assignments due
- Readings due
- Flashcards due
- Active Recall reviews

---

### Upcoming Deadlines

Shows:

- Assignments
- Quizzes
- Exams

Sorted by nearest due date.

---

### Progress Rings

Displays:

- Weekly Study Goal
- Reading Progress
- Assignment Completion

Inspired by Apple Fitness.

---

### Study Statistics

Shows:

- Study Streak
- Hours Studied Today
- Weekly Hours
- Flashcards Reviewed
- Recall Accuracy

---

### Weekly Overview

Seven-day summary.

Includes:

- Study Hours
- Deadlines
- Lectures

---

### Quick Actions

Examples:

+ Course

+ Lecture

+ Assignment

+ Reading

+ Flashcards

Start Study Session

Start Pomodoro

---

### AI Recommendation

Examples:

"Review Calculus flashcards."

"Read Chapter 5 before tomorrow's lecture."

"Complete Assignment 2."

---

# 2. Semester Management

StudyHub supports unlimited semesters.

---

## Semester Fields

Name

Academic Year

Start Date

End Date

Archived Status

Color

Icon

Notes

---

## Semester Actions

Create

Edit

Duplicate

Archive

Delete

Restore

Switch Active Semester

---

## Rules

Exactly one semester is active.

Archived semesters are read-only by default.

Users may reactivate archived semesters.

Each semester contains independent data.

Nothing leaks across semesters unless explicitly shared.

---

# 3. Course Management

Each semester contains unlimited courses.

---

## Course Fields

Course Name

Course Code

Color

Instructor

Email

Office Hours

Credits

Description

Location

Linked GoodNotes Notebook

---

## Course Tabs

Overview

Lectures

Assignments

Readings

Labs

Tutorials

Quizzes

Exams

Resources

Notes

Flashcards

Grades

Statistics

---

## Course Actions

Create

Duplicate

Archive

Delete

Share

Edit

---

# 4. Calendar

StudyHub provides a unified academic calendar.

---

## Calendar Views

Day

Week

Month

Agenda

---

## Calendar Sources

StudyHub

Apple Calendar

Google Calendar

Personal

Shared

Work

Family

Holiday

---

## Calendar Features

Create events

Edit events

Delete events

Filter calendars

Search events

Color-coded events

Drag-and-drop rescheduling

Recurring events

Countdown support

---

# 5. Lecture Management

Each lecture belongs to one course.

---

## Lecture Fields

Title

Date

Time

Location

Topic

Objectives

Summary

Slides

Attachments

Personal Notes

Recording Link

Attendance

Tags

---

## Lecture Tabs

Overview

Notes

Active Recall

Flashcards

Resources

Attachments

GoodNotes

---

# 6. Assignment Management

Assignments belong to courses.

---

## Assignment Fields

Title

Description

Due Date

Priority

Status

Checklist

Attachments

Submission Link

Estimated Time

Actual Time

Grade

Feedback

---

## Status Values

Not Started

In Progress

Completed

Submitted

Late

---

# 7. Reading Tracker

Readings belong to courses.

---

## Reading Fields

Title

Author

Pages

Current Page

Estimated Time

Due Date

Priority

Progress

Highlights

Notes

Attachments

---

## Reading Statistics

Pages Completed

Estimated Remaining Time

Completion Percentage

Average Reading Speed

---

# 8. Grade Tracker

Automatically calculates grades.

---

## Assessment Fields

Name

Weight

Score

Maximum Score

Category

Feedback

Date

---

## Calculations

Current Grade

Weighted Grade

Remaining Weight

Required Score

Predicted Grade

---

# 9. Notes

Notes can exist under:

Course

Lecture

Reading

Assignment

General

---

## Features

Rich Text

Images

PDF Links

Apple Pencil Attachments

Markdown Export

Search

Tags

Pinning

Favorites

---

# 10. Resources

Supported Resources

PDF

Website

Video

Book

Research Paper

Image

Folder

---

Each resource supports:

Title

Type

URL

Tags

Course

Lecture

Notes

---

# 11. Flashcards

Supports:

Text

Images

Equations

Diagrams

Code Blocks

Audio (future)

---

## Card Types

Basic

Reversed

Image Occlusion

Definition

Fill in the Blank

Diagram Labeling

---

## Actions

Create

Duplicate

Edit

Delete

Suspend

Tag

Filter

Shuffle

---

# 12. Active Recall

Integrated into lectures.

Question Types:

Short Answer

Definition

Essay

Diagram

Multiple Choice

Explain Concept

Fill Blank

---

Each question tracks:

Attempts

Accuracy

Confidence

Review Date

---

# 13. Spaced Repetition

Inspired by Anki.

Buttons:

Again

Hard

Good

Easy

The scheduling algorithm determines the next review date.

Each review updates:

Ease Factor

Interval

Streak

Accuracy

---

# 14. Study Mode

Automatically generates study sessions.

Inputs include:

Upcoming exams

Assignments

Flashcards due

Weak topics

Readings

Lecture notes

---

Study sessions consist of:

Warm-up

Flashcards

Recall

Reading

Break

Review

Summary

---

# 15. Pomodoro

Presets:

25 / 5

50 / 10

90 / 20

Custom

Tracks:

Focus Time

Break Time

Interruptions

Completed Sessions

---

# 16. Statistics

Displays:

Daily

Weekly

Monthly

Semester

Lifetime

Metrics include:

Study Hours

Attendance

Assignments

Reading Progress

Flashcards

Recall Accuracy

Grades

Streak

---

# 17. Quote Manager

Users paste one quote per line.

StudyHub manages:

Random selection

No repeats

Editing

Deleting

Import

Export

Search

---

# 18. Widgets

Widgets include:

Today's Schedule

Quote

Study Streak

Assignments Due

Flashcards Due

Upcoming Exam

Quick Study

---

# 19. Notifications

Supports reminders for:

Lectures

Assignments

Readings

Flashcards

Pomodoro

Quizzes

Exams

Study Sessions

Users control reminder timing per category.

---

# 20. Settings

Includes:

Appearance

Accent Color

Calendar Permissions

Google Sign-In

Apple Calendar Sync

iCloud Sync

Apple Pencil

Notifications

Quote Manager

Export Data

About

Privacy

---

# 21. AI Assistant

Optional feature.

Capabilities include:

Summarize notes

Generate flashcards

Generate quizzes

Generate recall questions

Explain concepts

Find weak topics

Suggest study plans

Estimate preparation time

Generate revision sessions

The AI layer should remain modular so providers (Apple Intelligence, OpenAI, Anthropic, etc.) can be swapped without changing the rest of the application.

---

# Functional Requirements Summary

Every module should support:

- Create
- Read
- Update
- Delete (CRUD)
- Search
- Filtering
- Sorting
- Offline support
- iCloud synchronization
- Accessibility
- Dynamic Type
- Dark Mode
- Keyboard shortcuts where appropriate
- Context menus
- Native iPad interactions