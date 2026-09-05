# StudyHub

**A native iPadOS academic operating system** — courses, lectures, readings,
notes, flashcards, and focused study sessions in one connected app, built
with SwiftUI and SwiftData.

**Swift** · **SwiftUI** · **SwiftData** · **iPadOS** · Status: **Paused**

---

## Overview

Most students juggle five apps to manage their academic life — one for
notes, one for PDFs, one for flashcards, one for tasks, one for timing study
sessions. StudyHub treats these as **one connected data model** instead of
five disconnected tools: a note knows which course and reading it came
from, a flashcard can trace back to the note it was generated from, and a
study session tracks what was actually accomplished across all of them.

**Built:** August – September 2026 · **Status:** core features complete, no longer in active development · **Author:** solo project

## Table of Contents

- [Features](#features)
- [Engineering Highlights](#engineering-highlights)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [What's Not Yet Built](#whats-not-yet-built)
- [Documentation](#documentation)

## Features

- **Connected academic data graph** — Courses → Lectures → Readings →
  Notes → Flashcards, with relationship-aware deletion rules (deleting a
  Reading nullifies rather than destroys the Notes tied to it)
- **PDF reading subsystem** (PDFKit) — Apple Pencil annotation via
  PencilKit (pencil-only input, so fingers scroll and the pencil draws),
  full-text search, outline navigation, persistent bookmarks, and
  automatic progress tracking derived from page state
- **Markdown-based notes** — tagging (case-insensitive, dedupe-aware), and
  linking to a course, lecture, or reading
- **Flashcards & Active Recall** — flip-to-reveal review with
  difficulty/review-count tracking, plus a separate deliberate-retrieval
  practice mode
- **Study Mode** — a unified session workspace (reading + notes +
  flashcards + recall) with an integrated Pomodoro timer and an
  end-of-session summary

## Engineering Highlights

- Architected the app around a **repository + dependency-injection
  pattern** (a central `AppContainer`) to separate UI, business logic, and
  persistence, using SwiftData's reactive `@Query` to keep views in sync
  without manual refresh logic
- Managed development with **Git** — regular commits, versioning, and
  feature branches
- Debugged real reactive-state issues in production, including a **PDF
  bookmark/page-navigation race condition** and a **partial-match
  highlighting bug** in incremental search

## Architecture

```
Course → Lecture → Reading → Note → Flashcard
                      │         │
                  PDFProgress  Active Recall
                      │
                  Bookmark
```
SwiftUI View → ViewModel → Repository → SwiftData → Persistent Store

## Tech Stack

**Swift** · **SwiftUI** · **SwiftData** · **PDFKit** · **PencilKit** · **Git**

## What's Not Yet Built

This project was built to solve a specific set of personal academic
workflow problems, and development is now paused with that goal met. A few
parts of the original design were never taken past architecture docs or
data-model foundations — an AI study companion, production CloudKit sync
(the code is CloudKit-aware, but provisioning isn't set up), and a full
spaced-repetition scheduler. `/StudyHub-Docs` documents the intended
direction for these, in case development resumes.

## Documentation

[`/StudyHub-Docs`](./StudyHub-Docs) contains the planning documentation
used to guide development — product requirements, architecture decisions,
and per-screen UI specs.

---

**Kartik Dang**

[GitHub](https://github.com/DangKartik) · [LinkedIn](https://www.linkedin.com/in/dangkartik/)

Personal project, not affiliated with any university or employer.
