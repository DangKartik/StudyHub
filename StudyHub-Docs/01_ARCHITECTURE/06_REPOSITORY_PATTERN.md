# REPOSITORY PATTERN

**Project:** StudyHub  
**Document:** 06_REPOSITORY_PATTERN.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team

---

# 1. Purpose

This document defines the Repository Pattern used throughout StudyHub.

Repositories act as the single source of truth for all application data.

Their responsibilities include:

- Reading data
- Writing data
- Updating data
- Deleting data
- Searching data
- Synchronizing data
- Managing persistence

Repositories isolate the rest of the application from SwiftData.

If the persistence layer changes in the future, Views and ViewModels should require little or no modification.

---

# 2. Repository Philosophy

StudyHub follows one fundamental rule:

> **Every interaction with persistent data must go through a Repository.**

Views never communicate directly with SwiftData.

ViewModels never create SwiftData queries.

Business logic never depends on ModelContext.

Instead:

```
View

↓

ViewModel

↓

Repository

↓

SwiftData
```

---

# 3. Why Use Repositories?

Without repositories:

- Business logic becomes duplicated.
- Views become tightly coupled to SwiftData.
- Testing becomes difficult.
- Future migrations become expensive.

Repositories provide:

- Encapsulation
- Reusability
- Testability
- Maintainability
- Scalability

---

# 4. Architecture

```
SwiftUI View

↓

ViewModel

↓

Repository

↓

SwiftData

↓

CloudKit
```

Only the Repository communicates with SwiftData.

---

# 5. Repository Responsibilities

Every Repository is responsible for:

- Creating objects
- Reading objects
- Updating objects
- Deleting objects
- Fetching lists
- Searching
- Filtering
- Sorting
- Validation
- Saving changes
- Handling persistence errors

Repositories should **not** contain presentation logic.

---

# 6. Repository Rules

Repositories must:

- Be small and focused.
- Own one primary model.
- Expose simple APIs.
- Hide persistence details.
- Never know about SwiftUI.
- Never update UI state.

---

# 7. Generic Repository Pattern

Every Repository should provide a consistent set of operations.

Standard operations include:

- Create
- Fetch
- Fetch by ID
- Update
- Delete
- Exists
- Count
- Search
- Save

Additional feature-specific methods may be added when appropriate.

---

# 8. Repository Ownership

Each major model has one Repository.

| Model | Repository |
|--------|------------|
| Semester | SemesterRepository |
| Course | CourseRepository |
| Lecture | LectureRepository |
| Assignment | AssignmentRepository |
| Reading | ReadingRepository |
| Resource | ResourceRepository |
| Flashcard | FlashcardRepository |
| Active Recall | ActiveRecallRepository |
| Study Session | StudySessionRepository |
| Statistics | StatisticsRepository |
| Quote | QuoteRepository |
| Calendar | CalendarRepository |

Each Repository is responsible only for its associated model.

---

# 9. Semester Repository

Responsibilities

- Create semesters
- Archive semesters
- Switch active semester
- Delete semesters
- Load semester statistics
- Fetch active semester

Example responsibilities

```
Create Semester

Archive Semester

Load Active Semester

Delete Semester
```

---

# 10. Course Repository

Responsibilities

- Create course
- Update course
- Delete course
- Load lectures
- Load assignments
- Load readings
- Calculate grade progress

The Course Repository owns all course-related persistence.

---

# 11. Lecture Repository

Responsibilities

- Create lectures
- Update lecture notes
- Manage lecture attachments
- Load lecture summaries
- Fetch lecture schedule

---

# 12. Assignment Repository

Responsibilities

- CRUD operations
- Due date queries
- Priority filtering
- Completion status
- Upcoming deadlines

Example queries

- Due Today
- Due This Week
- Overdue
- Completed

---

# 13. Reading Repository

Responsibilities

- Reading progress
- Estimated time
- Notes
- Due dates
- Completion percentage

---

# 14. Flashcard Repository

Responsibilities

- Create cards
- Delete cards
- Review scheduling
- Shuffle
- Filtering
- Statistics

Specialized operations

- Due Today
- Again
- Hard
- Good
- Easy

---

# 15. Statistics Repository

Responsibilities

- Study hours
- Reading progress
- Grade analytics
- Weekly summaries
- Monthly summaries

Statistics should be computed here whenever persistence is required.

---

# 16. Quote Repository

Responsibilities

- Add quotes
- Edit quotes
- Delete quotes
- Daily quote rotation
- Reset rotation after all quotes have been shown

The quote rotation algorithm belongs here.

---

# 17. Calendar Repository

Responsibilities

- Store linked calendar events
- Fetch synchronized events
- Update sync state

Actual EventKit communication belongs to CalendarService.

---

# 18. Repository vs Service

Repositories and Services have different responsibilities.

Repository

Responsible for application data.

Examples

- Courses
- Lectures
- Assignments
- Flashcards

Service

Responsible for external systems.

Examples

- EventKit
- CloudKit
- Notifications
- GoodNotes
- AI

Rule

Repositories never communicate directly with external APIs unless coordinated through the appropriate Service.

---

# 19. Repository Communication

Repositories should not directly depend on one another.

Poor

```
Course Repository

↓

Lecture Repository

↓

Assignment Repository
```

Preferred

```
ViewModel

↓

Course Repository

Assignment Repository
```

The ViewModel coordinates multiple repositories.

---

# 20. Search

Each Repository is responsible for searching its own model.

Examples

Course Repository

- Search by name
- Search by code

Assignment Repository

- Search title
- Search description

Flashcard Repository

- Search tags
- Search front
- Search back

Global search combines results from multiple repositories.

---

# 21. Sorting

Sorting belongs in Repositories.

Examples

Assignments

- Due Date
- Priority
- Alphabetical
- Recently Updated

Courses

- Name
- Code
- Color

Views should request sorted data instead of sorting themselves.

---

# 22. Filtering

Filtering also belongs in Repositories.

Examples

Assignments

- Completed
- Pending
- Overdue

Readings

- Completed
- In Progress

Flashcards

- Due Today
- Difficult
- Tag

---

# 23. Transactions

When multiple objects must be modified together, the Repository should perform the operation atomically whenever possible.

Example

Deleting a Course

- Remove Lectures
- Remove Assignments
- Remove Readings
- Remove Resources
- Remove Grade Categories
- Save changes

The operation should either complete entirely or fail gracefully.

---

# 24. Error Handling

Repositories never crash the application.

Errors should be propagated upward.

Examples

- Save failed
- Duplicate object
- Invalid relationship
- Missing parent
- Migration failure

The ViewModel decides how errors are presented.

---

# 25. Concurrency

Repositories should support Swift Concurrency.

Examples

- Background fetches
- Cloud synchronization
- Batch updates
- AI-generated imports

All public asynchronous operations should use async/await.

---

# 26. Dependency Injection

Repositories should never be created directly inside Views.

Preferred

```
App

↓

Dependency Container

↓

ViewModel

↓

Repository
```

This enables testing and flexibility.

---

# 27. Testing

Repositories should be independently testable.

Tests should verify:

- Create
- Read
- Update
- Delete
- Search
- Sort
- Filter
- Error handling
- Data validation

Repositories should be testable without SwiftUI.

---

# 28. Mock Repositories

Every Repository should have a mock implementation.

Examples

```
MockCourseRepository

MockAssignmentRepository

MockFlashcardRepository
```

Mock repositories simplify:

- SwiftUI previews
- Unit tests
- UI tests

---

# 29. Performance Guidelines

Repositories should:

- Fetch only required data.
- Avoid unnecessary queries.
- Batch updates where appropriate.
- Minimize memory usage.
- Cache frequently accessed results when beneficial.
- Keep query complexity low.

---

# 30. Repository Rules

The following rules are mandatory.

- Views never access SwiftData directly.
- ViewModels never perform persistence operations directly.
- Every persistent model has one primary Repository.
- Repositories own CRUD operations.
- Search, sorting, and filtering belong in Repositories.
- Business logic remains outside Views.
- External APIs are handled by Services, not Repositories.
- Repositories must be testable.
- Repositories should expose clean, simple interfaces.
- Persistence details must remain hidden from higher layers.

---

# 31. Repository Summary

StudyHub uses the Repository Pattern to create a clean separation between the user interface and the persistence layer.

This approach provides:

- A single source of truth
- Better maintainability
- Easier testing
- Reduced coupling
- Improved scalability
- Flexibility for future persistence changes

Every feature that reads or writes persistent data must do so exclusively through its corresponding Repository.