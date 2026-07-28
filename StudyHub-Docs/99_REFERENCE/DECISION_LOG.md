# DECISION LOG

**Project:** StudyHub  
**Document:** DECISION_LOG.md  
**Version:** 1.0  
**Status:** Reference  
**Owner:** Product + Engineering Team  

---

# 1. Purpose

This document records important architectural, product, design, and engineering decisions made during StudyHub development.

The purpose is to:

```
Preserve Context

Avoid Repeated Discussions

Explain Tradeoffs

Guide Future Development
```

---

# 2. Decision Format

Each decision follows:

```
Decision ID

Date

Decision

Context

Options Considered

Reasoning

Impact
```

---

# 3. Decision Principles

StudyHub decisions should prioritize:

```
User Value

Simplicity

Maintainability

Scalability

Privacy

Native Experience
```

---

# DECISION-001

## Decision

Use SwiftUI as the primary UI framework.

---

## Context

StudyHub is designed primarily for Apple's ecosystem.

The application requires:

```
iPhone Support

iPad Support

Future macOS Support

Modern UI Architecture
```

---

## Options Considered

### UIKit

Pros:

```
Mature Framework

Large Ecosystem

Fine Control
```

Cons:

```
More Boilerplate

Slower Development

Less Modern
```

---

### SwiftUI

Pros:

```
Declarative UI

Cross Platform Support

Faster Development

Modern Apple Framework
```

Cons:

```
Some Limitations

Newer Framework
```

---

## Decision Reasoning

SwiftUI provides the best balance between:

```
Development Speed

Apple Integration

Future Compatibility
```

---

## Impact

All UI components will be built using:

```
SwiftUI

SwiftUI Components

SwiftUI Navigation
```

---

# DECISION-002

## Decision

Use MVVM architecture.

---

## Context

StudyHub requires:

```
Many Features

Complex State

Maintainable Codebase
```

---

## Options Considered

### MVC

Pros:

```
Simple

Traditional
```

Cons:

```
Large View Controllers

Poor Scalability
```

---

### MVVM

Pros:

```
Clear Separation

Better Testing

Reusable Logic
```

Cons:

```
More Files

Requires Discipline
```

---

## Decision Reasoning

MVVM provides better separation between:

```
UI

Business Logic

Data
```

---

## Impact

Structure:

```
View

↓

ViewModel

↓

Service

↓

Repository

↓

Storage
```

---

# DECISION-003

## Decision

Use SwiftData for local persistence.

---

## Context

StudyHub requires offline-first functionality.

Data includes:

```
Courses

Assignments

Notes

Flashcards

Statistics
```

---

## Options Considered

### Core Data

Pros:

```
Mature

Powerful
```

Cons:

```
More Complexity
```

---

### SwiftData

Pros:

```
Modern Swift Integration

Simpler Models

SwiftUI Friendly
```

Cons:

```
Newer Framework
```

---

## Decision Reasoning

SwiftData aligns with Apple's modern development direction.

---

## Impact

Local data layer uses:

```
SwiftData Models

Queries

Persistence Layer
```

---

# DECISION-004

## Decision

Adopt offline-first architecture.

---

## Context

Students need access to academic information anywhere.

Possible situations:

```
No Internet

Poor Connection

Travel

Campus Network Issues
```

---

## Decision

Local data is the primary source.

Flow:

```
User Action

↓

Local Storage

↓

Cloud Sync
```

---

## Impact

Users can:

```
View Courses Offline

Study Without Internet

Access Notes Anywhere
```

---

# DECISION-005

## Decision

Use CloudKit for synchronization.

---

## Context

StudyHub needs Apple ecosystem synchronization.

Target devices:

```
iPhone

iPad

Mac
```

---

## Options Considered

### Custom Backend

Pros:

```
Complete Control

Cross Platform
```

Cons:

```
Higher Cost

More Maintenance
```

---

### CloudKit

Pros:

```
Apple Native

Secure

Integrated With iCloud
```

Cons:

```
Apple Ecosystem Focused
```

---

## Decision Reasoning

StudyHub is initially Apple-first.

CloudKit provides:

```
Reliable Sync

Privacy

Low Infrastructure Complexity
```

---

# DECISION-006

## Decision

Follow Apple's Human Interface Guidelines.

---

## Context

StudyHub should feel native.

---

## Decision

Follow:

```
Apple HIG

SF Symbols

Native Components

Accessibility Standards
```

---

## Impact

Design system uses:

```
Apple Typography

Semantic Colors

Native Interactions
```

---

# DECISION-007

## Decision

Use a student-centered product strategy.

---

## Context

Many productivity apps focus on task management.

StudyHub focuses on:

```
Learning

Retention

Academic Success
```

---

## Decision

Prioritize:

```
Learning Features

Study Workflow

Knowledge Management
```

over generic productivity features.

---

## Impact

Roadmap focuses on:

```
Active Recall

Spaced Repetition

AI Learning
```

---

# DECISION-008

## Decision

Build AI features gradually.

---

## Context

AI is powerful but requires:

```
Privacy Protection

Accuracy

User Trust
```

---

## Decision

AI evolution:

```
AI Assistant

↓

AI Tutor

↓

AI Learning Coach

↓

Personalized Learning System
```

---

## Impact

AI will not replace learning.

It will enhance learning.

---

# DECISION-009

## Decision

Use semantic design tokens.

---

## Context

The application requires:

```
Dark Mode

Accessibility

Consistency
```

---

## Decision

Avoid hardcoded values.

Use:

```
Color Tokens

Typography Tokens

Spacing Tokens
```

---

## Impact

Design changes become easier.

---

# DECISION-010

## Decision

Prioritize privacy by design.

---

## Context

StudyHub handles personal academic information.

Examples:

```
Notes

Study History

AI Conversations
```

---

## Decision

Follow:

```
Minimal Data Collection

Secure Storage

User Control
```

---

## Impact

Privacy is included from the beginning.

---

# DECISION-011

## Decision

Support iPad as a first-class device.

---

## Context

Students frequently use tablets for studying.

---

## Decision

Support:

```
Large Screens

Multitasking

Apple Pencil

Keyboard Input
```

---

## Impact

iPad experience will not simply be a scaled iPhone version.

---

# DECISION-012

## Decision

Design StudyHub as a long-term platform.

---

## Context

The product vision extends beyond a simple study tracker.

---

## Decision

Architecture should support:

```
More Devices

More Integrations

More AI Capabilities

More Users
```

---

## Impact

Avoid short-term architectural decisions.

---

# DECISION-013

## Decision

Defer creation of the `ChecklistItem` model during Phase 2 (Data Layer) implementation.

---

## Context

[04_SWIFTDATA_MODELS.md](../01_ARCHITECTURE/04_SWIFTDATA_MODELS.md) and [05_DATA_RELATIONSHIPS.md](../01_ARCHITECTURE/05_DATA_RELATIONSHIPS.md) both reference "Checklist Items" as an object owned by `Assignment`, but neither document defines:

```
Model properties

Relationships

Lifecycle behavior (e.g. ordering, completion tracking)
```

---

## Options Considered

### Infer a minimal model

Pros:

```
Unblocks Assignment ownership hierarchy immediately
```

Cons:

```
Invents a model not specified anywhere in documentation

Risk of mismatched shape once the real spec is written
```

---

### Defer until specified

Pros:

```
Avoids inventing undocumented models

Keeps the data layer aligned with documentation as source of truth
```

Cons:

```
Assignment checklist functionality is unavailable until a future phase
```

---

## Decision Reasoning

Documentation is the source of truth for StudyHub's architecture. Inventing a model shape without a formal specification risks diverging from future intent and creating rework.

---

## Impact

```
Assignment model implemented in Phase 2a without a checklist relationship

ChecklistItem model creation deferred until 04_SWIFTDATA_MODELS.md defines its properties and relationships
```

---

# DECISION-014

## Decision

App-lifetime state holders (`AppState`, `NavigationRouter`) are intentionally exempt from protocol-based dependency injection.

---

## Context

[07_DEPENDENCY_INJECTION.md §17](../01_ARCHITECTURE/07_DEPENDENCY_INJECTION.md) states "every major dependency should expose a protocol." The Phase 3A architecture audit found that `AppState` and `NavigationRouter` are both injected as concrete types (`AppState`, `NavigationRouter`) rather than as `any AppStateProtocol` / `any NavigationRouterProtocol`, unlike every Repository in `AppContainer`, which is exposed exclusively through its protocol.

---

## Options Considered

### Add a protocol to every dependency, including state holders

Pros:

```
Uniform DI pattern across the entire codebase

Matches the literal wording of 07_DEPENDENCY_INJECTION.md §17
```

Cons:

```
No practical swap-implementation need for a pure state container

Adds a protocol with a single production conformer and no real mock use case

Extra indirection for objects that are trivially constructible for previews/tests as-is
```

---

### Exempt pure app-lifetime state containers from protocol requirements

Pros:

```
Matches how AppState and NavigationRouter are actually used — once each, for the app's lifetime, with no alternate implementation ever needed

Keeps protocol abstraction reserved for dependencies that genuinely benefit from it
```

Cons:

```
Introduces an explicit exception to a stated architecture rule

Requires a documented boundary so the exception doesn't silently spread to Repositories/Services later
```

---

## Decision Reasoning

Protocol-oriented DI exists to support replaceable implementations (mocking, testing, future swaps — e.g. `CloudKitService` → `EnterpriseSyncService`). `AppState` and `NavigationRouter` are pure, single-instance state containers with no external system dependency and no plausible alternate implementation. Requiring a protocol for them adds ceremony without buying testability or flexibility.

The boundary is explicit: **protocols are required for replaceable infrastructure dependencies** (Repositories, Services, external integrations) **and not required for pure state containers/managers that exist only once for the app's lifecycle.**

---

## Impact

```
AppState and NavigationRouter remain concrete types injected directly by AppContainer

Any future app-lifetime Manager (ThemeManager, SessionManager, etc.) that is a pure state holder may follow the same exemption

Any dependency wrapping an external system, swappable backend, or requiring a mock for testing must still expose a protocol
```

---

# DECISION-015

## Decision

`AppState` is the single source of truth for the active semester after application initialization. Feature ViewModels consume `AppState.activeSemester` rather than independently calling `SemesterRepository.fetchActive()`.

---

## Context

`SemesterRepository` stores the active semester's identifier in `UserDefaults` and resolves it to a `Semester` via `fetchActive()`. `AppContainer` already performs this resolution once at launch and pushes the result into `AppState.activeSemester` (see `AppContainer.init()`).

Phase 3B's `HomeViewModel` was built to read `AppState.activeSemester` directly rather than calling `SemesterRepository.fetchActive()` again. The Phase 3B audit surfaced this as a deviation worth a recorded decision, since `SemesterRepository` was listed as an allowed dependency and its absence as an active call site could otherwise look like an oversight rather than a deliberate choice.

---

## The Lifecycle

```
AppContainer

↓ (once, at launch)

SemesterRepository.fetchActive()

↓

AppState.activeSemester

↓ (read-only)

Feature ViewModels
```

---

## Options Considered

### Each ViewModel calls SemesterRepository.fetchActive() independently

Pros:

```
Every ViewModel is self-sufficient and always reads the freshest UserDefaults-backed value

Matches the literal "Use: SemesterRepository" wording from the Phase 3B brief
```

Cons:

```
Duplicates a resolution AppContainer already performed

Every screen re-implements the same nil-handling for "no active semester"

Multiple ViewModels could theoretically disagree if the underlying value changed mid-session
```

---

### ViewModels read AppState.activeSemester; only AppContainer calls SemesterRepository.fetchActive()

Pros:

```
Single resolution point — matches Dependency Ownership rules in 07_DEPENDENCY_INJECTION.md

Active semester becomes one piece of shared, observable application state, consistent with 08_STATE_MANAGEMENT.md §7-8 ("Active semester" is an explicit AppState responsibility)

ViewModels stay focused on their own screen's data, not on re-deriving global state
```

Cons:

```
AppState.activeSemester only updates when something explicitly calls AppState.update(activeSemester:) — future semester-switching UI must remember to update AppState, not just SemesterRepository
```

---

## Decision Reasoning

`SemesterRepository` remains the only thing that persists and resolves *which* semester is active. `AppState` is the observable, in-memory projection of that value for the rest of the app to read. This keeps semester resolution centralized in one place (`AppContainer` at launch, and eventually a semester-switcher ViewModel that calls both `SemesterRepository.setActive(_:)` and `AppState.update(activeSemester:)` together) rather than scattered across every feature that happens to need "the current semester."

---

## Impact

```
Feature ViewModels (HomeViewModel and future ones) read AppState.activeSemester, never call SemesterRepository.fetchActive() themselves

Any future UI that lets a user switch semesters must update both SemesterRepository (persistence) and AppState (observable state) together, or ViewModels reading AppState will go stale

SemesterRepository.fetchActive() has exactly one caller: AppContainer.init()
```

---

# DECISION-016

## Decision

Course archiving uses the same persistence pattern as Semester archiving. `Course` has an `isArchived` Boolean flag. Archived courses are excluded from active semester workflows.

---

## Context

[04_SWIFTDATA_MODELS.md](../01_ARCHITECTURE/04_SWIFTDATA_MODELS.md) documents `Course` without any archived/status field, while [05_COURSES.md §16](../03_UI/05_COURSES.md) describes course states (Active, Completed, Archived) and Phase 3D's scope explicitly requires an "Archive course" action. `Semester` already solved an equivalent problem with a documented, modeled `isArchived: Bool` property and a corresponding `SemesterRepository.archive(_:)` method.

---

## Options Considered

### Defer Course archiving until the model is formally specified

Pros:

```
Avoids inventing an undocumented field, consistent with the ChecklistItem precedent (DECISION-013)
```

Cons:

```
Phase 3D explicitly scopes "Archive course" as a required feature

No alternative persistence mechanism exists for this state
```

---

### Add isArchived: Bool to Course, mirroring Semester exactly

Pros:

```
Directly mirrors an already-approved, working pattern (Semester.isArchived + SemesterRepository.archive(_:))

Minimal model change — one Boolean property, default false, no new relationships

Unblocks the explicitly-scoped Phase 3D archive requirement
```

Cons:

```
Touches a Core model, which the project treats as a change requiring explicit approval
```

---

## Decision Reasoning

Since `Semester` already established the exact shape this problem needs (a Boolean archived flag plus a repository method that sets it and saves), extending the same pattern to `Course` is the smallest, most consistent way to satisfy Phase 3D's requirements without inventing new architecture. This was explicitly approved rather than applied unilaterally, consistent with the project's rule that Core model changes require sign-off.

---

## Impact

```
Course.swift gains isArchived: Bool = false

CourseRepository gains archive(_ course: Course) throws, implemented identically to SemesterRepository.archive(_:)

HomeViewModel filters archived courses out of course count, assignments due today, and upcoming assignments — "active semester workflows" exclude archived courses everywhere they are read
```

---

# DECISION-017

## Decision

Lecture completion tracking is deferred. `Lecture` remains a content entity only — it stores schedule and material information, not learning progress. Progress and mastery tracking will be introduced later as a separate model, not as fields bolted onto `Lecture`.

---

## Context

[07_LECTURES.md §23](../03_UI/07_LECTURES.md) describes a four-state completion model (Not Started → Attended → Reviewed → Mastered) tied to attendance, notes, recall, and mastery. The `Lecture` model has no status field of any kind — unlike `Course`/`Semester`, which each solved a similar problem with a single `isArchived: Bool` (DECISION-016, DECISION-015's precedents). Phase 3E's scope is limited to viewing, creating, editing, and deleting lecture records; nothing in this phase (or any shipped feature) yet reads or produces attendance, notes-taken, recall accuracy, or mastery data.

---

## Options Considered

### Add a minimal Bool (e.g. isCompleted) now, mirroring Course.isArchived

Pros:

```
Small, consistent with the Course/Semester precedent

Unblocks a simple "mark complete" affordance immediately
```

Cons:

```
Doesn't actually model what the doc describes — a single Bool can't represent Attended vs Reviewed vs Mastered

Would likely need to be replaced, not extended, once real progress tracking is built

No feature in this phase reads or writes it, so it would ship unused
```

---

### Defer entirely; treat Lecture as a content-only entity for now

Pros:

```
Avoids shipping a field that doesn't match the doc's actual model and would need rework later

Progress tracking spans attendance, notes, active recall, and flashcard mastery — none of which exist yet as features — so a dedicated model (or a relationship to StudySession/ActiveRecallQuestion data) is the more honest fit than a flag on Lecture

Keeps Lecture's responsibility narrow: schedule + material metadata, not learning state
```

Cons:

```
No completion UI in Phase 3E
```

---

## Decision Reasoning

Course and Semester archiving were both single-boolean, single-purpose states with an immediate, exercised feature behind them (excluding archived items from active workflows). Lecture completion as described in the doc is a multi-stage progression fed by data from features that don't exist yet (attendance, active recall, flashcard review). Bolting a Bool onto `Lecture` now would misrepresent that model and likely be replaced rather than built upon. This is treated as a future, separate concern rather than an extension of `Lecture`.

---

## Impact

```
Lecture.swift gains no new fields in Phase 3E

LectureViewModel/LectureListView/LectureFormView implement view/create/edit/delete only — no completion state, no sorting/filtering by status

When progress tracking is designed, it should be evaluated as its own model (or derived from StudySession/ActiveRecallQuestion data) rather than a status flag retrofitted onto Lecture
```

---

# Future Decisions

Future decisions should be added using:

```
DECISION-ID

Context

Options

Reasoning

Impact
```

---

# Decision Index

```
DECISION-001

SwiftUI


DECISION-002

MVVM Architecture


DECISION-003

SwiftData


DECISION-004

Offline First


DECISION-005

CloudKit


DECISION-006

Apple HIG


DECISION-007

Student-Centered Product


DECISION-008

AI Evolution


DECISION-009

Design Tokens


DECISION-010

Privacy First


DECISION-011

iPad Support


DECISION-012

Platform Vision


DECISION-013

Defer ChecklistItem Model


DECISION-014

State Holder Protocol Exemption


DECISION-015

AppState as Active Semester Source of Truth


DECISION-016

Course Archiving Model


DECISION-017

Lecture Completion Tracking Deferred
```

---

# Final Principle

Good products are built through intentional decisions.

This decision log ensures StudyHub continues evolving with:

```
Clear Reasoning

Consistent Direction

Strong Engineering Foundations
```

Every future improvement should respect the principles established here.