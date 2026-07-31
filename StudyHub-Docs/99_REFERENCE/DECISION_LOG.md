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

# DECISION-022

## Decision

Phase 3I implements Resource Management as a Course-nested feature only. A global Sidebar → Resources library remains planned but is not built now.

---

## Context

DECISION-021 already flagged that `19_RESOURCES.md §4` documents Resources with a dual navigation shape — a top-level Sidebar library and a Course-nested view — while `SidebarDestination` reserves a `.resources` case with no content behind it. Phase 3I needs to actually decide which of these to build, since Resource Management is starting now.

Every shipped academic feature so far (Lectures, Assignments, Readings) follows the same Course-nested shape:

```
Course
 ├── Lectures
 ├── Assignments
 ├── Readings
 └── Resources (new)
```

`ResourceRepository` already implements `fetch(forCourse:)`, matching this shape directly; it has no cross-course listing/filtering support today.

---

## Options Considered

### Build the global Sidebar library now, alongside the Course-nested view

Pros:

```
Matches 19_RESOURCES.md's "primary" navigation flow exactly
Uses the SidebarDestination.resources case that has sat unimplemented since it was added
```

Cons:

```
Requires cross-course search/filtering architecture that doesn't exist yet — no feature in the app currently loads data across every course in a semester (or across semesters) for a single list
Doubles this phase's scope for a UI surface with no existing repository support (fetchAll() exists but nothing shapes it for a searchable/filterable global list)
Every other academic feature (Lectures, Assignments, Readings) shipped nested-only first; building Resources differently breaks that precedent without a clear reason tied to Resources specifically
```

---

### Course-nested only, matching Lecture/Assignment/Reading exactly

Pros:

```
Matches the existing, proven Course → Feature pattern used by every prior phase
No new architecture required — ResourceRepository.fetch(forCourse:) already supports it
Keeps this phase's scope aligned with what Lecture/Assignment/Reading Management each shipped as their own "V1"
Global library remains explicitly possible later without re-architecting the nested view — it would be an additive Sidebar destination reading the same Resource data
```

Cons:

```
SidebarDestination.resources remains unimplemented for another phase
Users cannot browse resources across courses until the global library is built
```

---

## Decision Reasoning

Every academic content feature in StudyHub has shipped Course-nested first, matching the model's actual ownership shape (`Resource.course: Course?`) and requiring zero new repository or navigation architecture. Building a global library now would introduce cross-course loading/filtering that nothing else in the app does yet, inside the same phase that's supposed to ship basic Resource CRUD. Keeping the two concerns separate lets Resource Management V1 ship at the same scope as Lecture/Assignment/Reading V1, with the global library treated as its own future enhancement.

---

## Impact

```
Features/Resources/ResourceListView.swift is scoped to a single Course, loaded via ResourceRepository.fetch(forCourse:) — identical shape to ReadingListView/LectureListView/AssignmentListView

CoursesView.swift gains a fourth courseForResources: Course? navigation state and a "Resources" entry on CourseRowView, following the exact pattern already used for Lectures/Assignments/Readings — no shared Bool state, no new navigation architecture

SidebarDestination.resources remains reserved but unimplemented after Phase 3I

A future phase must design the global library's data-loading shape (search, filtering, cross-course aggregation) before SidebarDestination.resources can be wired to real content — not decided here
```

---

# DECISION-023

## Decision

Add `updatedAt: Date` to the `Resource` model, matching every other primary SwiftData model in the app.

---

## Context

`Resource` is the only model in `Core/Models` missing `updatedAt` — `Course`, `Semester`, `Lecture`, `Assignment`, `Reading`, `Quiz`, `Exam`, and others all carry both `createdAt` and `updatedAt`, matching `04_SWIFTDATA_MODELS.md §22`'s "every model should include id, createdAt, updatedAt" rule. This gap was noted but explicitly deferred in DECISION-021 ("Resource.swift gains no updatedAt field in Phase 3H"). Phase 3I now makes `Resource` editable user data for the first time (create/update/delete via `ResourceFormView`), which is the trigger point DECISION-021 anticipated for revisiting this.

---

## Options Considered

### Leave Resource without updatedAt

Pros:

```
Zero model change
```

Cons:

```
Resource becomes the one editable model in the app with no way to tell when it was last modified
Breaks the "every model has id/createdAt/updatedAt" convention documented in 04_SWIFTDATA_MODELS.md and followed by every other model
```

---

### Add updatedAt: Date, defaulted like every other model

Pros:

```
Matches existing convention exactly — same shape as Course.updatedAt, Lecture.updatedAt, etc.
Minimal, additive, defaulted property — no migration risk, consistent with every other Core model change this project has approved (isArchived, secondInstructor, Course.isArchived)
Lets ResourceViewModel.updateResource bump the timestamp on edit, same as the field is intended to be used elsewhere
```

Cons:

```
Touches a Core model, which per project convention requires this decision entry
```

---

## Decision Reasoning

This mirrors every previous additive Core-model decision in this log (DECISION-016 isArchived, DECISION-019 secondInstructor/secondInstructorEmail): a small, defaulted, non-breaking field that brings a model in line with an already-established, already-documented convention. Since Resource is only now becoming editable, this is the natural point to close the gap rather than carrying it forward again.

---

## Impact

```
Resource.swift gains updatedAt: Date = Date.now, both as a stored property and an init parameter (defaulted, matching every other model's pattern)

ResourceViewModel.updateResource(_:) sets resource.updatedAt = Date.now before calling resourceRepository.save(), since the repository's generic save() has no way to know which fields changed

04_SWIFTDATA_MODELS.md's Resource Model section is updated to list updatedAt alongside the existing properties

No other model gains attachments, tags, favorites, or categories as part of this change — those remain out of scope per Phase 3I's stated limits
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

## Approved Future Requirement: Reading Target/Scope Support

**Status:** Approved as a requirement. Not designed, not modeled, not implemented. Reading Management (Phase 3H) shipped without this — it is recorded here as a condition of Reading Tracker being considered feature-complete for Version 1, not as work to start now.

**Current limitation:** `Reading` only supports tracking progress through an entire material, via `pageCount` and `currentPage`. There is no way to scope a reading item to a specific chapter, page range, section, or other partial target.

**Problem:** Real-world reading assignments are frequently target-based rather than whole-book-based. Students are commonly asked to read a specific chapter, a page range, or a section — not an entire text.

Examples:

```
Read Chapter 5 of Introduction to Algorithms

Read pages 120-180 of Deep Learning

Complete Section 3.2 before the exam
```

**Future design direction:** A Reading item should eventually support a reading target/scope concept — for example, distinguishing:

```
Entire Material

Chapter

Page Range

Custom Section
```

The exact shape (new fields on `Reading`, a separate related model, or something else) is explicitly undecided and out of scope for this note — this entry only records that the requirement is approved, not how it will be built.

**Why deferred:** Phase 3H intentionally shipped the minimal, already-modeled Reading CRUD (title/author/pages/progress/due date/notes) with no model changes. Designing partial-target support requires its own scoping pass — including whether it needs a new model (Core model changes require their own `DECISION-0NN` entry and explicit sign-off per project convention) — and should not be decided implicitly while a different phase is in progress.

---

## Approved Requirement: Resource Viewing, Highlights & Annotations in Version 1

**Status:** Approved as a Version 1 scope requirement. Not a `DECISION-0NN` entry — the exact architecture (models, storage, viewer components) is explicitly not finalized. This entry records *that* the requirement is in scope, not *how* it will be built.

**Current state:** Phase 3I (Resource Management) shipped only the foundation — create, edit, delete, and store `title`/`type`/`url`/`notes`. Resources today are editable records only; nothing renders or opens their actual content.

**Why this isn't enough for Version 1:** Resources are a core study feature, not just a storage database. A student needs to open learning material, mark important sections, add personal notes, and interact with content — not just catalog it. Basic viewing, highlighting, and annotations are therefore required before Version 1 can be considered released, not optional polish for later.

**Approved Version 1 requirements:**

1. **Resource Viewing** — resources become viewable content, not only editable records:

   ```
   PDF: open inside StudyHub using an integrated PDF viewer, with basic document viewing

   Website: open inside an in-app browser/web view

   Video: open the linked video content

   Repository: open the repository page

   Book: connect with the Reading workflow where appropriate
   ```

   Navigation behavior: tapping a resource opens/views it; editing becomes a separate, explicit action (context menu, edit button, swipe action, or similar) rather than the tap target.

2. **Highlights Support** — highlighting important information inside a resource (e.g., PDF text), saving highlighted sections, and associating them with the resource. The exact implementation (PDFKit annotations, a custom storage model, or otherwise) is explicitly left undecided.

3. **Annotation Support** — basic notes/comments linked to highlighted sections, for storing personal explanations or thoughts while studying. Flagged for careful design since it may later connect to Active Recall, Flashcards, a Notes system, and knowledge-graph-style features — none of which exist yet.

**Explicitly deferred beyond Version 1:** AI-generated summaries, AI explanations, advanced tagging, cloud synchronization, collaborative annotations, advanced knowledge graph connections, cross-resource recommendations, and advanced file management.

**Why deferred (architecture, not requirement):** Viewing/highlighting/annotation each require infrastructure that doesn't exist today — a PDF viewer component, an in-app web view, and a highlight/annotation storage shape (new model(s), relationships, and possibly a shared "annotatable content" concept). None of that is designed yet. This entry exists so the requirement itself isn't lost or silently descoped while that design work is pending — actual implementation, including any new SwiftData models, requires its own scoping pass and a full `DECISION-0NN` entry before code is written, per the project's standing Core-model-change rule.

---

# DECISION-024

## Decision

Grade Tracker V1 uses weighted grading only, computed exclusively from `GradeCategory` entries. `GradeCategory` entries with no positive weight or no positive maximum score are excluded from both the weighted sum and the total-weight denominator — not counted as zero. The current grade is always a computed value, never stored on any model. `Quiz` and `Exam` scores are not part of this calculation in V1 — there is no automatic Quiz/Exam → GradeCategory rollup.

---

## Context

The Phase 3J planning audit found `GradeCategory` already shaped for exactly this (`weight`, `earnedScore`, `maximumScore`, all raw stored inputs, no stored percentage anywhere), but flagged several undecided questions before implementation could start: whether grading is weighted or unweighted, how "ungraded" entries should be handled, whether Quiz/Exam feed into the calculation, and whether the result should ever be persisted. `04_SWIFTDATA_MODELS.md §25` already establishes the general principle that derived values like "Current Grade" and "Weighted Grade" must not be stored — this decision applies that principle concretely to Grade Tracker's specific fields.

---

## Options Considered

### Unweighted simple average across all categories

Pros:

```
Simpler arithmetic
```

Cons:

```
Ignores GradeCategory.weight entirely, a field that already exists and is already documented (06_COURSE_DETAILS.md's "Assignments 20% / Midterm 30% / Final 50%" example)
Doesn't match how grades actually work in the real courses this app is modeling
```

---

### Weighted average, treating every category (including newly-created, not-yet-scored ones) as contributing a zero

Pros:

```
Simple — no filtering logic needed
```

Cons:

```
A brand-new category (created with default earnedScore = 0, maximumScore = 100) would immediately drag the current grade down to 0%, before the user has entered any real score — actively misleading
```

---

### Weighted average over graded categories only, computed on demand, Quiz/Exam excluded from the calculation

Pros:

```
Matches GradeCategory's existing fields with no model change beyond timestamps
A category isn't penalized for existing before it has a real score
Keeps Quiz/Exam as independently tracked, displayed records in V1 — avoids deciding the undecided Quiz/Exam → GradeCategory linkage question (explicitly out of scope per this phase's approval)
Matches 04_SWIFTDATA_MODELS.md §25's "derived data is computed, not stored" rule directly
```

Cons:

```
"Ungraded" has no explicit stored flag on GradeCategory (see Impact below for the concrete rule used)
```

---

## Decision Reasoning

`GradeCategory` already models weighted buckets, not a flat list — using its `weight` field is the only interpretation consistent with the model's own shape and with `06_COURSE_DETAILS.md`'s documented example. Excluding zero/misconfigured-weight or zero-maximum-score categories from the denominator (rather than counting them as zero) prevents a newly-added, not-yet-scored category from artificially cratering the displayed grade — a simple average-of-zero-scores approach would actively mislead students, which conflicts with the product's own stated goal of being a trustworthy academic tool. Leaving Quiz/Exam out of the calculation entirely keeps V1 scoped to what's approved, and avoids deciding the harder, explicitly-deferred question of how (or whether) individual assessments should roll up into a category automatically.

---

## Impact

```
GradesViewModel.currentGrade is a computed property, never a stored field on any model

Concrete "ungraded/excluded" rule: a GradeCategory is excluded from the calculation when weight <= 0 or maximumScore <= 0 — these are the only two fields available to make this determination without adding a new model field, which is out of scope for this decision

Formula: currentGrade = (Σ weight × (earnedScore / maximumScore)) / (Σ weight), over included categories only; nil when no categories qualify

Quiz.score and Exam scores (Exam has no score field at all) are not read by this calculation — both remain independently displayed, CRUD-only records in V1

Any future automatic Quiz/Exam → GradeCategory linkage, GPA rollup, letter-grade mapping, or prediction/trend feature requires its own future DECISION-0NN — none of that is authorized by this entry
```

---

# DECISION-025

## Decision

Add `createdAt: Date` and `updatedAt: Date` to `GradeCategory`, `Quiz`, and `Exam`, matching the convention already followed by every other primary SwiftData model in the app.

---

## Context

The Phase 3J planning audit found that `GradeCategory`, `Quiz`, and `Exam` are the only models in `Core/Models` missing **both** `createdAt` and `updatedAt` — a larger gap than `Resource`'s pre-Phase-3I state (which was missing only `updatedAt`, closed by DECISION-023). This violates `04_SWIFTDATA_MODELS.md §22`'s "every model should include id, createdAt, updatedAt" rule. Phase 3J is the first phase to make any of these three models user-editable, which is the same trigger condition DECISION-023 used for `Resource`.

---

## Options Considered

### Leave GradeCategory/Quiz/Exam without timestamps

Pros:

```
Zero model change
```

Cons:

```
These become the only editable models in the app with no way to tell when they were created or last modified
Breaks the documented, otherwise-universal id/createdAt/updatedAt convention
```

---

### Add createdAt and updatedAt to all three, defaulted like every other model

Pros:

```
Matches the exact shape used by every other model (Course, Semester, Lecture, Assignment, Reading, Resource)
Minimal, additive, defaulted properties — no migration risk
Lets GradesViewModel's update methods bump updatedAt on edit, same as Resource does today
```

Cons:

```
Touches three Core models at once, which per project convention requires this decision entry
```

---

## Decision Reasoning

This is the same reasoning already applied twice (DECISION-016 `isArchived`, DECISION-023 `Resource.updatedAt`): a small, defaulted, non-breaking field closing a gap against an already-documented, already-universal convention, applied at the moment the model actually becomes editable. Doing all three models together (rather than one at a time across future phases) is appropriate here since Grade Tracker V1 makes all three editable simultaneously.

---

## Impact

```
GradeCategory.swift, Quiz.swift, and Exam.swift each gain createdAt: Date = Date.now and updatedAt: Date = Date.now, as both stored properties and defaulted init parameters

GradesViewModel's update methods (updateGradeCategory, updateQuiz, updateExam) set updatedAt = Date.now before calling courseRepository.save() — the repository's save() has no way to know which fields changed, same pattern as ResourceViewModel.updateResource

04_SWIFTDATA_MODELS.md's Quiz/Exam/Grade Category Model sections should be updated to list both fields (tracked as a documentation follow-up, consistent with how DECISION-023 updated Resource's doc section)

No other fields are added — no isGraded flag, no letter-grade field, no GPA field
```

---

## Approved Requirement: Grade Tracker Assessment Hierarchy for Version 1

**Status:** Approved as a Version 1 requirement. Not a `DECISION-0NN` entry — the assessment model structure is explicitly not finalized. This entry records *that* the requirement is in scope, not *how* it will be built. The Phase 3J foundation remains unchanged; nothing here is implemented now.

**Current Phase 3J implementation:** Grade Tracker V1's foundation uses manual `GradeCategory` totals only — `GradeCategory` stores `weight`, `earnedScore`, and `maximumScore` as directly-entered numbers. `Quiz` and `Exam` exist as independent, Course-owned entities with no relationship to `GradeCategory`. `GradesViewModel.currentGrade` reads only `GradeCategory` values (per DECISION-024); Quiz and Exam scores are tracked and displayed but don't feed the calculation.

**Approved Version 1 requirement:** The final Grade Tracker V1 should support a proper assessment hierarchy where individual assessments belong to Grade Categories, with each assessment contributing automatically to its parent category's total — rather than a category's score being a single manually-entered number.

Target structure:

```
Course
 └── Grade Categories
        ├── Assignments
        ├── Quizzes
        ├── Midterms
        ├── Finals
        ├── Projects
        └── Other Assessments
```

Example:

```
Quiz Category (10%)
    Quiz 1: 10/10
    Quiz 2: 0/13.25
    Quiz 3: 15/20
```

The app should automatically calculate: assessment percentage, category percentage (derived from its assessments), weighted contribution, and overall current grade.

**Future Grade Tracker V1 should also support common university assessment types:** Quiz, Midterm, Final, Assignment, Project, Presentation, Other.

**Explicitly deferred to future design (not decided here):**

1. Assessment model structure.
2. How Quiz/Midterm/Final/Assignment/Project/Presentation/Other relate to `GradeCategory`.
3. Missing-grade handling — ignored vs. counted as zero.
4. Weighted calculation rules once categories are assessment-derived rather than manually entered.
5. A possible "what score do I need" calculator.

**Why deferred:** This changes the shape of the assessment/category relationship itself — today `Quiz`/`Exam` have no link to `GradeCategory` at all (DECISION-024 deliberately left this unlinked for V1's foundation). Introducing that link, plus a general "assessment type" concept covering Assignment/Project/Presentation/Other (types with no dedicated model today), is a Core model change and must go through its own scoping pass and a full `DECISION-0NN` entry before any code is written — consistent with every other Core model change in this project. The Phase 3J foundation (manual `GradeCategory` totals, unlinked `Quiz`/`Exam`) remains the shipped V1 behavior until that future decision is made.

---

# DECISION-026

## Decision

Phase 3K (Flashcard Management) ships as a CRUD-only foundation: create, edit, delete, and view flashcards scoped to a Course, with an optional Lecture reference via a simple picker. `Flashcard.updatedAt` is added to close the model's timestamp gap. Tags remain deferred — the existing `tags` field is untouched, with no UI. Review mode, spaced repetition, and AI generation are explicitly out of scope.

---

## Context

The Phase 3K planning audit found `Flashcard` and `FlashcardRepository` fully built since Phase 2 with zero UI consumers, and both relationship sides already wired: `Course.flashcards` (owned) and `Lecture.referencedFlashcards` (nullify, reference-not-owned, matching `05_DATA_RELATIONSHIPS.md §14`). The model also carries spaced-repetition fields (`difficulty`, `nextReviewDate`, `lastReviewed`, `reviewCount`, `easeFactor`, `interval`) and a `tags: [String]` field that no UI has ever touched. The audit also flagged `Flashcard` as the only remaining model missing `updatedAt` (it has `createdAt` only) — the same gap class already closed for `Resource` (DECISION-023) and `GradeCategory`/`Quiz`/`Exam` (DECISION-025).

---

## Options Considered

### Ship CRUD plus a first pass at spaced-repetition review mode together

Pros:

```
One phase instead of two
```

Cons:

```
Review mode (flip animation, Again/Hard/Good/Easy buttons, SM-2 interval math) is a materially different, larger UI surface than any CRUD form built in this project so far — no prior phase has built anything like it
Conflates "can the data exist" with "can you study it," the same split already made deliberately for Reading (Highlights/Annotations deferred) and Resource (Viewer deferred)
```

---

### CRUD-only foundation, matching every prior phase's V1 scope exactly

Pros:

```
Matches the established pattern for every feature shipped so far (Lecture, Assignment, Reading, Resource, Grade Tracker) — foundation first, richer interaction later
Flashcard and FlashcardRepository already fully support this scope with zero repository changes
Both Course and Lecture relationships already exist and need no model work beyond the timestamp fix
```

Cons:

```
Spaced-repetition fields (nextReviewDate, reviewCount, easeFactor, interval) ship unused for another phase
```

---

## Decision Reasoning

Every feature phase in this project has deliberately shipped a CRUD foundation before any richer, feature-specific interaction layer — Lecture before completion tracking, Reading before Highlights, Resource before its Viewer, Grade Tracker before the assessment hierarchy. Flashcard's review-mode surface is the largest such deferred layer yet (a full spaced-repetition study interface), making the CRUD/review split even more clearly warranted here than in prior phases. Including a simple, optional Lecture picker is in scope because both relationship sides already exist and it requires no new architecture — unlike tags, which would need its own UI/search design work better done alongside Study Mode, per the existing Lecture-linking precedent of only including what's already fully modeled.

---

## Impact

```
Flashcard.swift gains updatedAt: Date = Date.now, both as a stored property and a defaulted init parameter, matching every other model's convention

FlashcardsViewModel.updateFlashcard(_:) sets updatedAt = Date.now before calling flashcardRepository.save(), same pattern as ResourceViewModel/GradesViewModel

FlashcardFormView includes a simple optional Lecture picker (the course's own lectures, "None" option included) — no new relationship, no new repository method; uses the existing lecture: Lecture? property directly

Flashcard.tags is not surfaced in any UI this phase — left exactly as-is, no reads or writes

No review mode, flip animation, spaced repetition, SM-2 algorithm, difficulty buttons, due-review queue, or AI generation in Phase 3K — each requires its own future scoping pass and DECISION-0NN before implementation
```

---

# DECISION-027

## Decision

Phase 3L (Active Recall Management) ships as a CRUD-only foundation: create, edit, delete, and view Active Recall questions, Lecture-owned only (no Course relationship added). `ActiveRecallQuestion` gains `createdAt`/`updatedAt`. `QuestionType` selection is included in V1. Hint/Explanation/Source/Tags and the full Review Mode / spaced repetition / AI generation system are explicitly deferred.

---

## Context

The Phase 3L planning audit found `ActiveRecallQuestion` and `ActiveRecallRepository` fully built since Phase 2 with zero UI consumers. The model's only relationship is `lecture: Lecture?` (cascade-owned from `Lecture.activeRecallQuestions`, matching `05_DATA_RELATIONSHIPS.md §15` exactly) — there is no Course relationship, unlike `Flashcard`, which has both. The audit also found `ActiveRecallQuestion` missing both `createdAt` and `updatedAt` (the same gap class already closed for `Resource`, `GradeCategory`/`Quiz`/`Exam`, and `Flashcard`), and that `15_ACTIVE_RECALL.md` describes a full review system (Review Mode, Self-Evaluation, Spaced Recall Scheduling, Weak Knowledge Detection, AI Recall Generation, Study Session Integration) far beyond what the model or any other infrastructure currently supports.

---

## Options Considered

### Add a Course relationship so Active Recall can nest under Course like every other feature

Pros:

```
Matches the Course-nested navigation pattern used by Lectures, Assignments, Readings, Resources, Grades, and Flashcards
```

Cons:

```
Requires a new relationship not in the current model or 05_DATA_RELATIONSHIPS.md's documented shape ("Each Active Recall Question belongs to one Lecture")
Would contradict the already-approved, documented ownership model for no real benefit — the question is conceptually tied to a specific lecture's content, not the course broadly
```

---

### Keep Lecture-only ownership; nest navigation one level deeper (Course → Lecture → Active Recall)

Pros:

```
Matches the model and 05_DATA_RELATIONSHIPS.md exactly — no relationship change needed
Matches 15_ACTIVE_RECALL.md §4's own "Content-based" flow (Lecture → Generate Recall → Practice)
Zero risk of a Core model relationship change beyond the already-approved timestamp fix
```

Cons:

```
First feature to nest under Lecture rather than Course directly — a new navigation shape, not a copy-paste of the CourseRowView button pattern
```

---

### Ship CRUD plus a first pass at Review Mode together

Pros:

```
One phase instead of two
```

Cons:

```
Review Mode (reveal-answer flow, self-evaluation, spaced scheduling) is a materially different, larger UI surface than any CRUD form built so far — the same reasoning already applied to Flashcard's review mode (DECISION-026) and Reading's Highlights (approved future requirement)
Blocked on a real model gap: StudySession has no field referencing ActiveRecallQuestion at all (only an un-annotated flashcardsReviewed array), so Study Session Integration specifically cannot be built without further model work
```

---

## Decision Reasoning

This follows the same CRUD-foundation-first pattern applied to every feature phase in this project (Lecture, Assignment, Reading, Resource, Grade Tracker, Flashcard). Keeping Active Recall Lecture-only avoids inventing a relationship the documentation never specified, and matches the model exactly as built. Including `QuestionType` in V1 (rather than deferring it like Reading's Type field) is justified because the enum is fully defined, requires no model change, and is a required part of the question's identity per `15_ACTIVE_RECALL.md §9`'s example metadata — unlike Hint/Explanation/Source/Tags, which have no model fields at all and would require new Core model work to support.

---

## Impact

```
ActiveRecallQuestion.swift gains createdAt: Date = Date.now and updatedAt: Date = Date.now, both as stored properties and defaulted init parameters, matching every other model's convention

ActiveRecallViewModel's update method sets updatedAt = Date.now before calling activeRecallRepository.save(), same pattern as every other ViewModel this phase

Features/ActiveRecall/ActiveRecallFormView.swift exposes a Picker over all six QuestionType cases (Question Answer, Fill Blank, Definition, Diagram, Image, Essay); new questions default to .questionAnswer

Navigation nests one level deeper than every prior phase: Course → Lectures → Lecture → Active Recall. LectureListView.swift gains a per-lecture entry point and its own navigation state — not a CourseRowView button

Hint, Explanation, Source, and Tags are not added to the model and have no UI this phase

Review Mode, answer-reveal flow, self-evaluation, spaced repetition, SM-2 scheduling, AI generation, statistics, practice tests, and Study Session integration are all explicitly deferred — each requires its own future scoping pass and DECISION-0NN before implementation
```

---

# DECISION-028

## Decision

Phase 3M (Notes Management) introduces `Note` as a new first-class Core Model: `id`, `title`, `body` (plain `String`), `createdAt`, `updatedAt`, an optional `course: Course?` relationship, and an optional `lecture: Lecture?` relationship — no `reading`/`assignment`/`resource` relationship. Attachments are **required in V1**, implemented by reusing the existing `Attachment` model (already a Primary Model, already used by `Lecture`/`Assignment`/`Reading`) rather than inventing a new model or embedding file fields directly on `Note`. `Note` gains a `NoteRepositoryProtocol` with its own CRUD plus attachment sub-methods (`createAttachment`/`deleteAttachment`/`fetchAttachments(for:)`), mirroring the existing sub-entity pattern. GoodNotes material is represented as an `Attachment` (`type == "goodnotes"`, `url` holding the deep link) — V1 stores external references only, never imported file bytes. The editor stays plain-text (`TextEditor`); rich text, Markdown, AI features, cloud sync, collaboration, knowledge graph, note linking, advanced search, tags, pinning, and favorites are all deferred. Navigation is nested only: `Course → Notes` and `Lecture → Notes`; no global "All Notes" library in V1. The six existing `notes: String` fields (`Course`, `Lecture`, `Reading`, `Resource`, `Quiz`, `Exam`) are explicitly kept unchanged as lightweight metadata fields, distinct from the new `Note` entity.

---

## Context

The Phase 3M planning audit found no `Note` model, repository, or UI anywhere in the codebase — only six unrelated models each carrying a plain `notes: String` field. `03_FEATURE_SPECIFICATION.md §9` describes Notes as a richer, standalone concept ("can exist under: Course, Lecture, Reading, Assignment, General"; Rich Text, Images, PDF Links, Apple Pencil Attachments, Markdown Export, Search, Tags, Pinning, Favorites), and `04_SWIFTDATA_MODELS.md`'s Core Model Hierarchy diagram draws `Notes` as a child of `Lectures`, but the Primary Models table never lists it and no repository section exists for it — a real documentation gap.

This update revises that initial scope: attachments are now a required part of V1, not deferred. Re-auditing the codebase for attachment precedent found `Core/Models/Attachment.swift` already exists as a built, unused-by-any-UI Core Model (`id`, `filename`, `type`, `url`, `size`, `createdAt`) with optional `lecture`/`assignment`/`reading` relationships. Its CRUD already lives directly on the owning entity's repository — `LectureRepositoryProtocol`, `AssignmentRepositoryProtocol`, and `ReadingRepositoryProtocol` each expose `createAttachment`/`deleteAttachment`/`fetchAttachments(for:)` — with no dedicated `AttachmentRepository` and no UI consumer yet. `09_SERVICES.md` and `11_LOCAL_STORAGE.md` contain no file-storage or GoodNotes-service design at all; the only precedent for referencing external material is `Course.goodNotesNotebookID: String?`, a bare deep-link string.

---

## Options Considered

### Make Attachment support part of Note directly (embed file fields on the model)

Pros:

```
No relationship to design; simplest schema
```

Cons:

```
Contradicts the model that already exists and is reused by three other entities — would create a second, parallel way of representing "a file attached to something"
A Note could only ever have exactly the fields embedded (e.g. one URL), not a list of several attachments, which the stated use cases (slides + PDF book + reference doc + GoodNotes link, all on one note) require
```

---

### Invent a new, Note-specific attachment model

Pros:

```
Full control over Note-specific fields
```

Cons:

```
Duplicates Attachment's exact shape (filename/type/url/size/createdAt) for no new capability
Directly contradicts the instruction to decide on reuse before building anything new, and there is no gap in the existing Attachment model that would justify a second one
```

---

### Reuse the existing Attachment model, add a `note: Note?` relationship, and add attachment sub-methods to NoteRepositoryProtocol

Pros:

```
Matches the established sub-entity pattern exactly (Lecture/Assignment/Reading already do this)
Attachment already supports multiple files per parent (an array relationship), satisfying "slides + PDF + reference doc + GoodNotes link" on one note
GoodNotes references fit naturally as an Attachment with type == "goodnotes" and url holding the deep link — no special-cased field needed on Note
Zero new file-storage subsystem required: url remains a plain string reference, exactly as it already behaves for every other Attachment consumer, so this satisfies "do not implement arbitrary file storage" by construction
Leaves room for future deeper GoodNotes integration (e.g. a future GoodNotesService resolving/opening that url) without further model changes
```

Cons:

```
Attachment.swift needs one new optional relationship (note: Note?) plus a cascade-delete inverse on Note — a small, well-precedented Core change
```

---

## Decision Reasoning

Reusing `Attachment` is the only option consistent with "decide whether the existing/future Attachment architecture should be reused" and "do not implement arbitrary file storage without deciding the model structure" — the model, its string-reference convention, and its sub-entity repository pattern already exist and are already proven by three other features. Building a second attachment concept would fork that convention for no benefit. Representing GoodNotes material as a typed `Attachment` rather than a dedicated `Note.goodNotesReference` field keeps a student's attached material in one browsable list and avoids a one-off field whose meaning would need to be explained separately from every other attachment. Storing only external references (never imported file bytes) is the only thing the current architecture actually supports — no file-import or CloudKit-asset service exists in `09_SERVICES.md`/`11_LOCAL_STORAGE.md`, so anything beyond a string reference would require inventing a new subsystem outside this phase's scope. Restricting V1 relationships to `Course`/`Lecture` (no `Reading`/`Assignment`/`Resource`) follows the same CRUD-foundation-first, don't-build-ahead-of-a-real-decision pattern used in every prior phase this project.

---

## Impact

```
Core/Models/Note.swift (new): id, title, body, createdAt, updatedAt, course: Course?, lecture: Lecture?, attachments: [Attachment] (cascade delete, inverse of Attachment.note)

Core/Models/Attachment.swift: gains one new optional relationship, note: Note?, alongside its existing lecture/assignment/reading relationships. No other field changes — filename/type/url/size/createdAt stay as-is.

Core/Models/Course.swift and Core/Models/Lecture.swift: each gains an inverse notes: [Note] relationship (cascade delete), matching every other nested-feature pattern

Core/Repositories/NoteRepository.swift (new): NoteRepositoryProtocol with create/update(save)/delete/fetch(forCourse:)/fetch(forLecture:), plus createAttachment/deleteAttachment/fetchAttachments(for note:) mirroring Lecture/Assignment/Reading's existing sub-entity shape

Features/Notes/NotesViewModel.swift, NoteListView.swift, NoteFormView.swift (new): plain-text TextEditor body only; no rich text, Markdown, or AI features

Navigation: courseForNotes on CoursesView/CourseRowView and lectureForNotes on LectureListView/LectureRowView, following the exact per-parent pattern used since Phase 3H; no global "All Notes" destination in V1

GoodNotes material is stored as an Attachment (type == "goodnotes", url = deep link) attached to a Note — no new field on Note, no file-import mechanism

Course.notes, Lecture.notes, Reading.notes, Resource.notes, Quiz.notes, Exam.notes are explicitly unchanged — they remain separate, lightweight metadata fields, not superseded by Note

Reading, Assignment, and Resource relationships on Note, a global Notes library, rich text/Markdown, AI summaries/generation, cloud sync, collaboration, knowledge graph, note linking, advanced search, tags, pinning, and favorites are all explicitly deferred — each requires its own future scoping pass and DECISION-0NN before implementation
```

---

# DECISION-029

## Decision

A dedicated FileService is deferred. Phase 3N.1.1's PDF import workflow uses a minimal, non-DI utility (`Core/Utilities/AttachmentFileImporter`) instead — a plain namespace with one static function, no protocol, no AppContainer registration. This also supersedes part of DECISION-028's stated V1 scope: DECISION-028 said Attachments "store external references only, never imported file bytes" and that there was "no file-import mechanism" — Phase 3N.1.1 deliberately introduces real file copying into app-owned storage for `.pdf`-typed Attachments and Resources, superseding that specific clause.

---

## Context

3N.1.1 needed to replace manually-typed file paths with a native `.fileImporter` for PDF attachments and PDF resources. `Attachment.url`/`Resource.url` were already free-typed strings with no validation, matching DECISION-028's "external references only" design — but that design assumed no file-import mechanism would exist. Introducing `.fileImporter` requires copying the picked file into app-owned storage, since a security-scoped picker URL isn't safely reusable as a stored path across launches without bookmark management. A full FileService (protocol, DI registration, mock implementation, AppContainer wiring) was considered for this and explicitly ruled premature — only one feature currently needs file-copy behavior.

---

## Options Considered

### Introduce a full FileService now

Pros:

```
Matches the Service-layer pattern used by every other external-system integration in this app

Positions the app for future file-management needs (image import, document management, export/import, backup) without a later migration
```

Cons:

```
Protocol, DI registration, AppContainer wiring, and a mock implementation for a single call site is unjustified complexity relative to the actual need

No second feature exists yet to prove the abstraction boundary is even correct — building it now risks guessing wrong
```

---

### Minimal non-DI utility in Core/Utilities, defer FileService

Pros:

```
Satisfies the immediate requirement (copy a picked file into app storage, return a stable path) with the smallest possible footprint

Matches this project's own repeated reasoning for avoiding premature abstraction (e.g. DECISION-019's rejection of a Professor model for two text fields)

Core/Utilities is already a documented, reserved location for exactly this kind of helper, unused until this phase
```

Cons:

```
If multiple features need file-copy behavior later, this utility will need to be replaced by a real Service — a known, accepted future migration, not a surprise
```

---

## Decision Reasoning

Introducing Service-layer ceremony for a single call site is unjustified complexity relative to the actual need. A plain utility satisfies the requirement with the smallest footprint, consistent with how this project has repeatedly chosen minimal, additive solutions over speculative infrastructure.

---

## Impact

```
Future phases will likely need a dedicated FileService once multiple features require shared file-management logic — e.g. image imports, broader document management, export/import, backup handling, or general file lifecycle management

When that need becomes real (not hypothetical), a FileService should be introduced following the same protocol + DI pattern already used by every other Service in this app

Until then, AttachmentFileImporter remains the single, minimal, non-DI file-copy utility

DECISION-028's "no file-import mechanism" clause is understood as superseded for .pdf-typed Attachments/Resources specifically — every other Attachment/Resource kind (Link, GoodNotes, Website, Video, Repository, Book, Document, Image, Other) still stores external references only, exactly as DECISION-028 described
```

---

# DECISION-030

## Decision

When creating a note from a Course Notes page, users may optionally associate the note with a specific Lecture instead of the Course directly. If no Lecture is selected, the note remains a Course-level note (`note.course` set, matching existing behavior). If a Lecture is selected, the note is created as a Lecture-level note (`note.lecture` set) instead. Lecture Notes pages are unaffected — notes created there continue to belong exclusively to that Lecture, with no Course option.

---

## Context

Course Notes creation (`NotesViewModel.createNote`, scoped via `NotesViewModel.Scope.course`) currently always sets `note.course`, with no way to target a specific Lecture at creation time — a user wanting a Lecture-scoped note has to navigate into that Lecture's own Notes screen first. Since Phase 3N.1.1, Course Notes aggregation (`NoteRepository.fetch(forCourseIncludingLectures:)`) already surfaces Lecture-owned notes alongside Course-owned ones, so a Lecture-owned note created this way is already visible from the Course Notes screen without any further change — this decision only concerns *where a new note's ownership is set at creation time*, not visibility.

---

## Options Considered

### Require navigating into a Lecture's own Notes screen to create a Lecture-scoped note (status quo)

Pros:

```
No change required
Keeps Course Notes creation simple and single-purpose
```

Cons:

```
Extra navigation friction for a common case — students frequently want to record a note "for Lecture 5" while already browsing the Course's Notes

Course Notes aggregation already made Lecture notes visible from this screen, but not creatable from it — an inconsistent affordance
```

---

### Add an optional Lecture picker to Course Notes creation, mirroring the existing Flashcards pattern

Pros:

```
Directly matches an already-shipped, proven pattern — FlashcardsViewModel.availableLectures + FlashcardFormView's Picker("Lecture", selection:) — no new interaction pattern introduced

Removes the navigation friction described above

No SwiftData model change — Note.course and Note.lecture already both exist as independent optionals

No repository change — NoteRepository.create(_:) already inserts whatever relationship is set, and fetch(forCourseIncludingLectures:) already surfaces the result correctly
```

Cons:

```
None identified — small, additive View/ViewModel change with an existing precedent to follow
```

---

## Decision Reasoning

The second option directly reuses an already-approved, already-shipped interaction pattern (Flashcards' optional Lecture picker) rather than inventing a new one, and closes a real, identified inconsistency: Course Notes aggregation (Phase 3N.1.1) already displays Lecture notes but offered no way to create one from that screen. Since both relationships already exist on `Note` and neither the repository nor the aggregation logic needs to change, this is a pure View/ViewModel-layer decision with no architectural cost.

---

## Impact

```
No SwiftData model changes — Note.course and Note.lecture already exist as independent optionals

No repository changes — NoteRepository.create(_:) and fetch(forCourseIncludingLectures:) both already support this without modification

NotesViewModel.createNote gains an optional lecture parameter; when scope is .course and a lecture is provided, note.lecture is set instead of note.course

NotesViewModel gains an availableLectures computed property, mirroring FlashcardsViewModel.availableLectures exactly

NoteFormView's creation form gains a Lecture picker, shown only when creating from Course scope, defaulting to "None" (Course-level)

Lecture Notes pages (NotesViewModel.Scope.lecture) are unaffected — notes created there continue to set note.lecture only, with no Course option

Course Notes aggregation (fetch(forCourseIncludingLectures:)) requires no change — it already surfaces Lecture-owned notes regardless of how they were created
```

---

# DECISION-031

## Decision

A Note has exactly one primary academic owner: Course, Lecture, or Reading — never more than one simultaneously. When a Note is linked to a Reading, that ownership is not also considered Course ownership, even though the Reading itself belongs to a Course — Reading-owned notes are never duplicated into `fetch(forCourseIncludingLectures:)` or any other Course-level aggregation.

---

## Context

Phase 3.1 (Notes Foundation) adds `Note.reading: Reading?` alongside the existing `Note.course`/`Note.lecture` optionals (DECISION-028/030). `NoteRepository.swift`'s existing invariant, documented at `fetch(forCourseIncludingLectures:)`, already assumed strict two-way exclusivity ("a Note is ever only `note.course` or `note.lecture`, never both"). Adding a third optional relationship without an explicit exclusivity rule would leave Course-level aggregation and the new global Notes list free to produce notes with more than one owner set, or to double-surface a Reading-owned note under its parent Course.

---

## Options Considered

### Allow a Note to carry Course, Lecture, and Reading simultaneously

Pros:

```
Maximum flexibility — a note could be tagged with every relevant context at once
```

Cons:

```
Reintroduces exactly the ambiguity the existing course/lecture invariant was written to avoid
Course-level aggregation would need new logic to avoid showing the same note twice (once directly, once via its Reading)
No current UI need for a note to belong to more than one place at once
```

---

### Exactly one owner: Course, Lecture, or Reading — never multiple

Pros:

```
Extends the existing, already-proven course/lecture exclusivity invariant to three cases instead of inventing new logic
Course-level aggregation stays correct by construction: a Reading-owned note simply never sets note.course, so it can never be double-counted
Matches how ownership already displays in the UI — one line of "owner context" per note
```

Cons:

```
A note "about a Reading that belongs to Course X" can't also appear in Course X's own Notes list without an explicit future design change
```

---

## Decision Reasoning

Extending the existing two-way exclusivity invariant to three cases is the minimal, consistent choice — it requires no new logic anywhere the invariant is already relied upon (`fetch(forCourseIncludingLectures:)`, note creation, the global Notes list), and avoids inventing double-counting/deduplication logic for a need that hasn't been requested.

---

## Impact

```
Note creation logic (NotesViewModel.createNote and any future Reading-scoped creation path) must set exactly one of course/lecture/reading, never more than one
fetch(forCourseIncludingLectures:) requires no logic change — Reading-owned notes naturally never appear there, since they never set note.course
The global Notes list (Phase 3.1) displays exactly one owner per note: Lecture name, else Reading title, else Course name
This phase does not add a UI path to actually set note.reading (no Reading-scoped Notes screen, no Reading picker in NoteFormView) — the relationship is schema-level foundation only, consistent with "Phase 3.1 Foundation" scope
```

---

# DECISION-032

## Decision

Deleting a Reading must not delete its linked Notes. `Reading.noteEntries` uses `deleteRule: .nullify` — when a Reading is deleted, any Note that referenced it has `note.reading` set to `nil` and is preserved.

---

## Context

Every existing Note ownership relationship (Course, Lecture) uses `deleteRule: .cascade` (`Course.swift:48`, `Lecture.swift:29`) — deleting the parent deletes its Notes. Phase 3.1 adds a third ownership relationship, `Note.reading`, and the same cascade default would silently delete a user's notes whenever they delete a Reading — a meaningfully lighter-weight, more frequent action than deleting a whole Course.

---

## Options Considered

### Cascade, matching Course/Lecture

Pros:

```
Consistent with the existing two precedents (Course.swift:48, Lecture.swift:29)
```

Cons:

```
A Reading is a much lighter-weight, more frequently deleted entity than a Course — losing notes silently on Reading deletion is a real data-loss risk for content the user likely wrote deliberately
```

---

### Nullify — detach, don't delete

Pros:

```
Preserves user-authored content by default; deleting a reading is a routine, low-stakes action that shouldn't be able to destroy unrelated notes
Existing precedent already exists in this codebase for exactly this choice: Lecture.swift:26 uses .nullify for Flashcard.lecture
```

Cons:

```
A "detached" note (reading == nil, course == nil, lecture == nil) has no owner and won't appear in any scoped Notes list — only the global Notes list (Phase 3.1) surfaces it
```

---

## Decision Reasoning

Notes are user-authored content, not disposable metadata — deleting a Reading is routine and shouldn't be able to destroy them as a side effect. `.nullify` already has a direct precedent in this codebase (`Flashcard.lecture`), so this isn't a new pattern, just applying the existing "preserve user content over strict ownership cascade" precedent to a new relationship.

---

## Impact

```
Reading.swift gains: @Relationship(deleteRule: .nullify, inverse: \Note.reading) var noteEntries: [Note] = []
Deleting a Reading no longer deletes its linked Notes — they become ownerless (reading == nil) and surface only in the global Notes list
No change to Course/Lecture cascade behavior — this decision is scoped to the new Reading relationship only
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


DECISION-018

Course Color Hex Storage


DECISION-019

Course Multiple Instructors


DECISION-020

Tutorial/Lab Deferred Pending ClassSession Refactor


DECISION-021

Reading Type Deferred; Resource Navigation and updatedAt Deferred to Phase 3I


DECISION-022

Resource Management Course-Nested Navigation Scope


DECISION-023

Resource.updatedAt Field Added


DECISION-024

Grade Tracker V1 Weighted Grading Methodology


DECISION-025

GradeCategory/Quiz/Exam Timestamps Added


DECISION-026

Flashcard Management V1 Scope


DECISION-027

Active Recall Management Foundation V1


DECISION-028

Notes Management V1 Scope — First-Class Model with Required Attachments


DECISION-029

FileService Deferral — AttachmentFileImporter Utility


DECISION-030

Course Notes Lecture Association


DECISION-031

Note Ownership Exclusivity — Course, Lecture, or Reading


DECISION-032

Reading Deletion Nullifies, Does Not Cascade, Notes
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