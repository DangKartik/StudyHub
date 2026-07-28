# DEPENDENCY INJECTION

**Project:** StudyHub  
**Document:** 07_DEPENDENCY_INJECTION.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team

---

# 1. Purpose

This document defines the Dependency Injection (DI) architecture used throughout StudyHub.

Dependency Injection allows the application to provide objects to other objects instead of allowing them to create dependencies themselves.

The goals are:

- Loose coupling
- Testability
- Modularity
- Scalability
- Maintainability

Every service, repository, and manager in StudyHub should follow this document.

---

# 2. Dependency Injection Philosophy

StudyHub follows one fundamental rule.

> Objects should receive their dependencies rather than creating them.

Bad

```
CourseViewModel

↓

creates

CourseRepository

↓

creates

SwiftData
```

Good

```
App

↓

Dependency Container

↓

CourseRepository

↓

CourseViewModel
```

Objects never decide how dependencies are constructed.

---

# 3. Why Dependency Injection?

Dependency Injection solves several problems.

Without DI

- Tight coupling
- Difficult testing
- Duplicate objects
- Hidden dependencies
- Poor scalability

With DI

- Mock implementations
- Easier testing
- Shared services
- Cleaner architecture
- Better code reuse

---

# 4. Dependency Graph

```
StudyHubApp

↓

AppContainer

↓

Repositories

Services

Managers

↓

ViewModels

↓

Views
```

Views should never resolve dependencies themselves.

---

# 5. Dependency Injection Principles

StudyHub follows these principles.

## Explicit Dependencies

Dependencies should be visible through initializers.

Avoid hidden dependencies.

---

## Constructor Injection First

Constructor injection is the preferred approach.

Objects should receive everything they need during initialization.

---

## Single Source of Truth

Shared dependencies should be created once.

Examples

- NotificationService
- CalendarService
- AIService

---

## Protocol-Oriented Design

Depend on protocols rather than concrete implementations whenever practical.

Example

```
CourseRepositoryProtocol

↓

CourseRepository
```

---

# 6. App Container

StudyHub uses a centralized App Container.

Responsibilities

- Create dependencies
- Configure dependencies
- Share dependencies
- Manage application-wide services

The App Container is initialized once during application launch.

---

# 7. App Startup

Initialization order

```
StudyHubApp

↓

AppContainer

↓

Services

↓

Repositories

↓

Environment

↓

RootView
```

All dependencies should be ready before the user reaches the Home Dashboard.

---

# 8. Dependency Categories

StudyHub contains four major dependency categories.

## Services

Examples

- CalendarService
- NotificationService
- AIService
- GoodNotesService
- SearchService
- BackupService

---

## Repositories

Examples

- SemesterRepository
- CourseRepository
- AssignmentRepository
- ReadingRepository
- FlashcardRepository

---

## Managers

Examples

- ThemeManager
- NavigationManager
- SessionManager
- PermissionManager
- SyncManager

Managers coordinate application state.

---

## Utilities

Examples

- GradeCalculator
- ReviewScheduler
- DateFormatter
- TimeFormatter

Utilities are lightweight and usually stateless.

---

# 9. Service Lifetime

Application Services should be long-lived.

One shared instance per application.

Examples

```
NotificationService

CalendarService

AIService

SearchService
```

These services persist for the application's lifetime.

---

# 10. Repository Lifetime

Repositories are shared objects.

Repositories manage data access and should not be recreated unnecessarily.

Example

```
CourseRepository

↓

Shared

↓

Entire Application
```

---

# 11. ViewModel Lifetime

ViewModels are screen-specific.

They are created when the screen appears and released when the screen is destroyed.

Example

```
CourseDetailView

↓

CourseDetailViewModel
```

ViewModels should not be shared globally unless explicitly required.

---

# 12. Manager Lifetime

Managers generally exist for the application's lifetime.

Examples

- ThemeManager
- SessionManager
- NavigationManager

These coordinate application-wide behavior.

---

# 13. Constructor Injection

Preferred dependency injection style.

Example concept

```
CourseViewModel

requires

CourseRepository

NotificationService
```

Dependencies are supplied during initialization.

The ViewModel never creates them itself.

---

# 14. Environment Injection

Some application-wide dependencies may be exposed through the SwiftUI Environment.

Examples

- Theme
- Active Semester
- Navigation State
- App Settings

Environment values should remain lightweight.

Repositories should not be placed directly in the environment.

---

# 15. Repository Injection

Each ViewModel receives only the repositories it requires.

Example

Assignment Detail

Needs

- AssignmentRepository

Not

- FlashcardRepository
- StatisticsRepository

Avoid unnecessary dependencies.

---

# 16. Service Injection

Services should be injected only when required.

Examples

Lecture ViewModel

Needs

- GoodNotesService
- CalendarService

Does not need

- AIService

Keep dependency lists minimal.

---

# 17. Protocol-Based Injection

Every major dependency should expose a protocol.

Examples

```
CourseRepositoryProtocol

AssignmentRepositoryProtocol

NotificationServiceProtocol

CalendarServiceProtocol

AIServiceProtocol
```

ViewModels depend on protocols rather than concrete implementations.

---

# 18. Mock Implementations

Each protocol should have a mock implementation.

Examples

```
MockCourseRepository

MockNotificationService

MockCalendarService

MockAIService
```

These are used for:

- Unit tests
- UI previews
- SwiftUI previews
- Automated testing

---

# 19. Dependency Resolution

Dependencies should be resolved once.

Bad

```
View

↓

creates Repository

↓

creates Service
```

Good

```
AppContainer

↓

creates Repository

↓

passes Repository

↓

ViewModel
```

Creation should occur in one place.

---

# 20. Circular Dependencies

Circular dependencies are prohibited.

Bad

```
CourseRepository

↓

AssignmentRepository

↓

CourseRepository
```

Instead

```
ViewModel

↓

CourseRepository

AssignmentRepository
```

The ViewModel coordinates multiple repositories.

---

# 21. Lazy Dependencies

Expensive dependencies may be created lazily.

Examples

- AI Engine
- Backup Engine
- PDF Processing
- Search Index

Create them only when first needed.

---

# 22. Testing

Dependency Injection makes testing straightforward.

Example

Production

```
CourseRepository
```

Testing

```
MockCourseRepository
```

No application code should require modification for testing.

---

# 23. SwiftUI Previews

SwiftUI previews should use mock dependencies.

Benefits

- Fast previews
- Predictable data
- Offline previews
- Stable UI development

Preview data should never connect to production storage.

---

# 24. Future Scalability

Dependency Injection allows future replacements.

Examples

Current

```
CloudKitService
```

Future

```
CloudKitService

↓

EnterpriseSyncService
```

No ViewModel changes should be required.

---

# 25. Dependency Ownership

Ownership hierarchy

```
StudyHubApp

↓

AppContainer

↓

Services

↓

Repositories

↓

ViewModels

↓

Views
```

Ownership always flows downward.

---

# 26. Dependency Rules

The following rules are mandatory.

- Objects never create their own repositories.
- Objects never create their own services.
- Constructor injection is preferred.
- Depend on protocols whenever practical.
- Avoid singletons unless truly global.
- Avoid hidden dependencies.
- Keep dependencies explicit.
- Prevent circular dependencies.
- Use mock implementations for testing.
- Share long-lived services through the App Container.

---

# 27. Future Dependencies

Future services may include

- Apple Mail Service
- Outlook Service
- Canvas Service
- Moodle Service
- Apple Intelligence Service
- Siri Service
- SharePlay Service

These should integrate through the existing Dependency Injection system.

---

# 28. Dependency Injection Summary

StudyHub adopts a centralized Dependency Injection architecture built around an App Container, protocol-oriented design, and constructor injection.

This approach provides:

- Loose coupling
- Better testing
- Cleaner architecture
- Easier maintenance
- Improved scalability
- Flexible implementations

Every component in StudyHub should receive its dependencies explicitly, ensuring the application remains modular and maintainable as it grows.