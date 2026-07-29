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

# DECISION-018

## Decision

Course color customization will use hex string storage.

---

## Context

`Course.courseColor` is already typed as `String`, currently populated from a fixed 6-entry preset list (`CourseFormView.colorPresets`). [00_COLOR_SYSTEM.md §8](../02_DESIGN/00_COLOR_SYSTEM.md) requires arbitrary user-selected course colors ("Users can customize colors"), which the preset picker was always a placeholder for, not a final implementation (Phase 3D explicitly deferred `ColorPicker`/hex support, not rejected it).

---

## Options Considered

### Keep the fixed preset list

Pros:

```
Zero additional work

Simple, bounded set of colors to reason about
```

Cons:

```
Doesn't satisfy the documented "user-selected color" requirement

Users cannot pick a color outside the 6 presets
```

---

### Store color as a hex string, backed by a real ColorPicker

Pros:

```
Course.courseColor is already String — no SwiftData schema change, no migration

Satisfies the documented customization requirement directly

A single, reusable hex<->Color conversion utility replaces per-form preset-matching logic
```

Cons:

```
Existing preset-named strings ("blue", "green", ...) from earlier testing won't parse as hex and need a fallback
```

---

## Decision Reasoning

Since the underlying storage type never needs to change, this is a UI-layer improvement, not a data-layer one. No migration risk, and it closes a gap the color system doc already specifies. The preset picker was explicitly built as a placeholder in Phase 3D, not a permanent design.

---

## Impact

```
Add a Color hex conversion utility in Core/Extensions

Replace the preset Picker in CourseFormView with a ColorPicker bound through that conversion

Preserve fallback support for existing preset strings (unparseable values default to gray, same as today's behavior) — no data migration performed
```

---

# DECISION-019

## Decision

Course supports multiple instructors via plain field extension, not a new Professor entity.

---

## Context

`Course` already stores a single instructor's name and email (`instructor`, `email`), matching [05_COURSES.md §12](../03_UI/05_COURSES.md). Some university courses have a second professor (e.g., co-taught courses) with a separate email, which is not currently representable and is not described in any existing doc — this is a new requirement, not an implementation gap.

---

## Options Considered

### Introduce a Professor model with a relationship to Course

Pros:

```
Would support professors shared across multiple courses, richer professor-level data, and professor-level relationships
```

Cons:

```
Nothing in the docs or this requirement describes professors as shared/reused entities across courses

Adds a new model, repository, and CRUD surface to represent what is functionally two text fields

Unjustified complexity relative to the actual need
```

---

### Extend Course with a second instructor name/email pair

Pros:

```
Mirrors the existing instructor/email fields exactly — no new pattern to learn

No new repository methods — flows through the existing create/save methods like every other field

Non-breaking, additive, defaulted properties
```

Cons:

```
Does not scale gracefully past two instructors (acceptable — no requirement describes more than two)
```

---

## Decision Reasoning

Professors in StudyHub are per-course free-text contact records, not shared entities with independent identity — no course-to-course professor reuse is described anywhere. A dedicated model would model an identity relationship that doesn't exist in the product's requirements. Plain field extension matches the existing `instructor`/`email` precedent and keeps the change additive.

---

## Impact

```
Course.swift gains secondInstructor: String and secondInstructorEmail: String (both defaulted, mirroring instructor/email)

CoursesViewModel.createCourse/updateCourse and CourseFormView gain the corresponding parameters/fields

No CourseRepository changes — handled by the existing create/save methods

No new relationships, no new model
```

---

# DECISION-020

## Decision

Tutorial and Lab support will not be implemented as separate models. When built, they will share a generic `ClassSession` model with `Lecture`, distinguished by a `sessionType` field.

---

## Context

[03_FEATURE_SPECIFICATION.md](../00_FOUNDATION/03_FEATURE_SPECIFICATION.md) lists Labs and Tutorials as in-scope, alongside Lectures, as Course-level content. Neither [04_SWIFTDATA_MODELS.md](../01_ARCHITECTURE/04_SWIFTDATA_MODELS.md) nor [05_DATA_RELATIONSHIPS.md](../01_ARCHITECTURE/05_DATA_RELATIONSHIPS.md) defines a model for either — only `Lecture` exists. This is a genuine specification gap between the product requirements and the data architecture, not just a missing implementation.

`Lecture` (shipped in Phase 3E) holds title, topic, date, startTime, endTime, location, summary, notes, plus relationships to `ActiveRecallQuestion`, `Attachment`, optional `referencedFlashcards`, and `CalendarEventReference`. Structurally, a Tutorial or Lab is the same shape — a scheduled academic session with the same kind of content and tooling attached.

---

## Options Considered

### Duplicate Lecture into separate Tutorial and Lab models

Pros:

```
No refactor of the already-shipped Lecture feature

Each type can diverge independently if they ever need to
```

Cons:

```
Triples the maintenance surface: three repositories, three ViewModels, three Views for functionally identical structures

Every future integration (flashcard generation, active recall, calendar sync) must be built three times

Directly contradicts 04_SWIFTDATA_MODELS.md's own design principle: avoid duplicate data, keep models focused and cohesive
```

---

### Consolidate into a shared ClassSession model with a sessionType discriminator

Pros:

```
One repository, one ViewModel, one View family for all three session types

Future learning-tool integrations (flashcards, active recall) are built once, not three times

Matches the documented data-architecture design principles
```

Cons:

```
Requires refactoring the already-shipped Lecture feature — LectureRepository, Course.lectures, and the inverse relationships on ActiveRecallQuestion/Attachment/CalendarEventReference all need to migrate

Cost grows the longer it's deferred, since more Lecture-specific tooling is still pending (DECISION-017: flashcards and active recall integration are not yet built)
```

---

## Decision Reasoning

The two-model-vs-shared-model question is fundamentally an architecture decision, not a feature-addition — building Tutorial/Lab as copies of Lecture first and merging later is strictly more expensive than deciding up front, since it means migrating whatever gets built during the interim too. Given nothing about Lecture's remaining roadmap (Flashcards, Active Recall — both deferred) has landed yet, this is the cheapest point at which to make this call, even though the actual refactor is not happening now.

---

## Impact

```
No Tutorial or Lab implementation in Phase 3F

When this work is scheduled, Lecture must be generalized into ClassSession (sessionType: .lecture / .tutorial / .lab, plus title, topic, date, startTime, endTime, venue, instructor/TA information, notes) BEFORE Tutorial/Lab features are built — not after

This refactor should be scoped as its own phase, preceding any Tutorial/Lab feature work
```

---

# DECISION-021

## Decision

Reading Type/Category is deferred (no model change in Phase 3H). Resources will eventually support both Course-nested resources and a global Sidebar library, but Phase 3I will implement Course-nested only. `Resource.updatedAt` will be added in Phase 3I, not now.

---

## Context

The Phase 3H planning audit (Readings & Resources) surfaced three open items before Reading Management could start cleanly:

```
11_READINGS.md's Reading Card mockups show a type/category badge (Textbook, Research Paper, Article, ...), which Reading has no field for today

19_RESOURCES.md §4 documents Resources with a dual navigation shape — a top-level Sidebar library AND a Course-nested view — while SidebarDestination already reserves a .resources case with no content behind it yet

Resource is the only model in the app missing updatedAt, unlike every other model (Course, Semester, Lecture, Assignment, Reading, Quiz, Exam, ...)
```

All three are legitimate future needs, but none block Reading Management, and none should be decided implicitly by silently shipping (or silently skipping) them inside an unrelated phase.

---

## Options Considered

### Resolve all three now, inside Phase 3H

Pros:

```
Fewer future Core-model touches
```

Cons:

```
Reading Type/Category and Resource.updatedAt are Resource/Reading model changes unrelated to what Phase 3H actually needs to ship
Deciding Resource's navigation shape before Resource work even starts risks locking in an architecture no Resource UI has been built against yet
```

---

### Explicitly defer all three, record the intended direction, revisit at the start of the phase that actually needs them

Pros:

```
Keeps Phase 3H scoped to exactly what Reading Management requires — no model changes
Resource's navigation decision gets made when Resource UI is actually being designed, not speculatively
Resource.updatedAt lands as part of Phase 3I's own model touch, following the same one-decision-per-model-change discipline as isArchived/secondInstructor
```

Cons:

```
Three more items to track before they're resolved
```

---

## Decision Reasoning

Phase 3H (Reading Management) needs zero changes to `Reading` or `Resource` — the existing models already support title/author/pages/progress/dueDate/notes CRUD. Introducing a Type field, a navigation-shape commitment, or a timestamp field now would be scope creep unrelated to what's being built, and would each independently qualify as a Core model/architecture change requiring its own sign-off. Recording the intended direction here — without implementing it — keeps that discipline intact while ensuring none of the three items get lost.

---

## Impact

```
Reading.swift gains no Type/Category field in Phase 3H — Reading Card/List/Form ship without a type badge

SidebarDestination.resources remains reserved but unimplemented; Phase 3I will build Resources nested under Course only (Course → Resources, matching Lecture/Assignment/Reading), not as a top-level Sidebar destination

A future phase (Phase 3I or later, once Resource's global-library UI is actually scoped) must decide, before implementation: nested-only, Sidebar-only, or both — and only then wire SidebarDestination.resources to real content

Resource.swift gains no updatedAt field in Phase 3H — this is deferred to whichever phase first modifies Resource, tracked as an explicit follow-up rather than silently carried forward
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

## Noted for Future Scoping: Completed/Archived Semester Read-Only Mode

**Status:** Not implemented. Not yet approved as a decision — flagged here only so it isn't lost, per an explicit "note this for later, don't build it now" request.

**Issue:** Completed (archived) semesters currently expose the same course-level actions as active semesters — e.g., `CourseRowView`'s "Assignments" and "Lectures" entry points appear identically regardless of whether the course belongs to the active semester or a past, archived one (see `CoursesViewModel.otherSemesterCourses`, which already separates active-semester courses from other-semester courses but does not distinguish "other" from "archived/completed").

**Desired future direction:** Archived semesters should behave as read-only/historical records. Creation-oriented actions (Add Assignment, Add Lecture, Add Course, Archive/Unarchive, Delete, etc.) should not be exposed while browsing a completed semester's courses; viewing existing data should remain available.

**Why deferred:** This spans Courses, Assignments, and Lectures simultaneously and needs its own scoping pass — e.g., whether "read-only" is enforced at the View layer only or needs an explicit read-only flag threaded through the relevant ViewModels, and how it interacts with the existing active/other/archived course grouping. Not scoped, sized, or approved as part of any phase completed so far.

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


DECISION-018

Course Color Hex Storage


DECISION-019

Course Multiple Instructors


DECISION-020

Tutorial/Lab Deferred Pending ClassSession Refactor


DECISION-021

Reading Type Deferred; Resource Navigation and updatedAt Deferred to Phase 3I
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