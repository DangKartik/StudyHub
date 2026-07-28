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