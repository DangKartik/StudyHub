# StudyHub

A native iPadOS academic workspace that brings a student's courses, lectures,
readings, notes, flashcards, active recall, and focused study sessions into
one connected app — built with SwiftUI and SwiftData.

Instead of splitting academic life across Notes, Files, a PDF reader, Anki,
and a separate timer app, StudyHub treats them as one connected data model:
a note knows which course and reading it came from, a flashcard can trace
back to the note it was generated from, and a study session tracks what
was actually accomplished across all of them.

## Status

Actively in development (started August 2026). This README describes what's
actually implemented — not the full long-term product vision.

## What's implemented

- **Academic data model** — Courses → Lectures → Readings → Notes →
  Flashcards, with relationship-aware deletion (e.g. deleting a Reading
  nullifies, rather than deletes, notes that reference it)
- **PDF reading system** (PDFKit) — Apple Pencil annotation via PencilKit
  (pencil-only input policy so fingers scroll and the pencil draws),
  full-text search, outline/section navigation, persistent bookmarks, and
  automatic reading-progress tracking derived from page position
- **Notes** — Markdown-based rich text, tagging (case-insensitive,
  dedupes empty/duplicate tags), and linking to a course/lecture/reading
- **Flashcards & Active Recall** — flip-to-reveal review, review-count and
  difficulty tracking, and a separate deliberate-retrieval-practice mode
- **Study Mode** — a session workspace combining reading, notes,
  flashcards, and active recall with a Pomodoro timer and an end-of-session
  summary (time spent, pages read, notes created, cards reviewed)

## Architecture

- **SwiftUI + SwiftData**, with SwiftData's reactive `@Query` keeping views
  in sync without manual refresh logic
- **Repository + dependency-injection pattern** — a central `AppContainer`
  provides repositories (Notes, Flashcards, Bookmarks, etc.) so persistence
  logic stays out of the views
- Fixed a couple of real reactive-state bugs along the way: a race
  condition between PDF page-change notifications and bookmark state, and
  a partial-match highlighting bug during incremental search

## Not yet built

Some parts of the original design exist only as data-model foundations or
architecture docs, not working features — most notably an AI study
companion, production CloudKit sync (the code is CloudKit-aware, but the
entitlements/provisioning aren't set up), and a full spaced-repetition
scheduler. `/StudyHub-Docs` documents the intended direction for these.

## Tech stack

Swift, SwiftUI, SwiftData, PDFKit, PencilKit, Git

## Documentation

`/StudyHub-Docs` contains the planning documentation used to guide
development — product requirements, architecture decisions, and per-screen
UI specs — kept as a working reference rather than a finished spec.

---

Personal project by [Kartik Dang](https://github.com/DangKartik), not
affiliated with any university or employer.
