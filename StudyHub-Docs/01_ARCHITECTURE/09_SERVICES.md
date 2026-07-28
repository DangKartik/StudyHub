# SERVICES

**Project:** StudyHub  
**Document:** 09_SERVICES.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team  

---

# 1. Purpose

This document defines the Service Layer architecture used throughout StudyHub.

Services are responsible for communicating with:

- Apple frameworks
- External applications
- Third-party APIs
- Background system capabilities
- Complex application operations

The Service Layer separates external dependencies from the core application architecture.

---

# 2. Service Layer Philosophy

StudyHub follows the principle:

> Repositories manage application data. Services manage external systems and specialized operations.

The architecture follows:

```
SwiftUI View

↓

ViewModel

↓

Repository / Service

↓

SwiftData / External Framework / API
```

---

# 3. Why Services Exist

Without a Service Layer:

- ViewModels become too large.
- External APIs spread throughout the application.
- Testing becomes difficult.
- Framework dependencies become tightly coupled.
- Future integrations become expensive.

Services provide:

- Separation of concerns
- Cleaner ViewModels
- Better testing
- Easier maintenance
- Scalable architecture

---

# 4. Service Architecture

```
AppContainer

↓

Services

├── CalendarService
├── GoogleCalendarService
├── GoodNotesService
├── NotificationService
├── AIService
├── CloudSyncService
├── SearchService
├── FileService
├── PermissionService
├── ReviewSchedulerService
├── GradeCalculatorService
└── AnalyticsService

↓

ViewModels

↓

Views
```

---

# 5. Service Rules

All services must follow these rules.

## Services Must

- Have a single responsibility.
- Hide external implementation details.
- Be injected through Dependency Injection.
- Support async operations where required.
- Be testable.
- Expose clear interfaces.

---

## Services Must Not

- Contain SwiftUI Views.
- Directly modify UI state.
- Handle navigation.
- Replace repositories.
- Store unnecessary application data.

---

# 6. Service Categories

StudyHub services are divided into four categories.

---

# 6.1 System Services

Services interacting with Apple frameworks.

Examples:

- EventKit
- UserNotifications
- CloudKit
- PencilKit
- WidgetKit

---

# 6.2 Integration Services

Services connecting StudyHub with external applications.

Examples:

- GoodNotes
- Google Calendar
- AI providers

---

# 6.3 Application Services

Services implementing complex internal logic.

Examples:

- Spaced repetition
- Grade calculation
- Search indexing

---

# 6.4 Utility Services

Small reusable services.

Examples:

- File management
- Date formatting
- Export handling

---

# 7. Calendar Service

## Responsibility

Handles Apple Calendar integration.

Framework:

```
EventKit
```

---

## Features

Supports:

- Calendar permission requests
- Reading calendars
- Importing events
- Creating StudyHub events
- Updating events
- Deleting events
- Calendar selection

---

## Operations

```
requestPermission()

fetchCalendars()

fetchEvents()

createEvent()

updateEvent()

deleteEvent()
```

---

## Rules

Calendar data remains owned by Apple Calendar.

StudyHub stores references and synchronization metadata, not duplicate calendar ownership.

---

# 8. Google Calendar Service

## Responsibility

Handles Google Calendar synchronization.

---

## Features

Supports:

- Google authentication
- Calendar selection
- Event importing
- Event exporting
- Synchronization
- Conflict handling

---

## Future Support

Potential additions:

- Multiple Google accounts
- Shared calendars
- Google Workspace accounts

---

# 9. GoodNotes Service

## Responsibility

Provides GoodNotes integration.

StudyHub is not a handwriting replacement.

StudyHub acts as:

```
Academic Dashboard

+

Learning Organizer
```

GoodNotes remains responsible for:

- Handwriting
- Apple Pencil notes
- Drawing
- Annotation

---

## Features

Course level:

```
Open Course Notebook
```

Lecture level:

```
Open Lecture Notes
```

---

## Stored Data

StudyHub stores:

- Notebook identifier
- Page identifier
- Linking metadata

StudyHub does not store:

- Pencil strokes
- Handwritten files
- GoodNotes internal data

---

# 10. Notification Service

## Responsibility

Manages all reminders and notifications.

Framework:

```
UserNotifications
```

---

## Notifications

Supports:

- Lecture reminders
- Assignment deadlines
- Reading reminders
- Flashcard reviews
- Quiz reminders
- Exam countdowns
- Study goals

---

## Operations

```
requestPermission()

scheduleNotification()

cancelNotification()

updateNotification()
```

---

# 11. AI Service

## Responsibility

Provides optional AI-powered learning features.

---

## Features

AI can:

- Summarize notes
- Generate flashcards
- Generate quizzes
- Create active recall questions
- Explain concepts
- Identify weak topics
- Recommend study plans

---

## Architecture

```
AIService

↓

AI Provider

↓

Generated Content

↓

User Confirmation

↓

Repository

↓

SwiftData
```

---

## Rules

AI-generated content must:

- Require user approval before saving.
- Never overwrite user notes automatically.
- Preserve user ownership of data.

---

# 12. Cloud Sync Service

## Responsibility

Handles cross-device synchronization.

Technology:

```
SwiftData + CloudKit
```

---

## Features

Supports:

- Uploading changes
- Downloading changes
- Conflict resolution
- Sync status tracking
- Offline support

---

## Sync States

```
Synced

Syncing

Failed

Offline
```

---

# 13. Search Service

## Responsibility

Provides global StudyHub search.

---

## Searchable Content

Search includes:

- Courses
- Lectures
- Assignments
- Readings
- Flashcards
- Resources
- Quotes

---

## Features

Supports:

- Full-text search
- Filtering
- Ranking
- Suggestions
- Recent searches

---

# 14. File Service

## Responsibility

Manages user files and attachments.

---

## Supported Files

- PDF
- Images
- Documents
- Lecture slides
- Resources

---

## Operations

```
importFile()

saveFile()

deleteFile()

moveFile()

exportFile()
```

---

# 15. Permission Service

## Responsibility

Centralizes permission handling.

---

## Permissions

Handles:

- Calendar access
- Notifications
- Files
- Photos
- AI services

---

## Benefits

Instead of:

```
CalendarViewModel

↓

EventKit Permission
```

Use:

```
CalendarViewModel

↓

PermissionService

↓

EventKit
```

---

# 16. Review Scheduler Service

## Responsibility

Implements spaced repetition algorithms.

Used by:

- Flashcards
- Active Recall

---

## Responsibilities

Calculates:

- Next review date
- Difficulty adjustment
- Interval changes
- Retention score

---

## Example

User selects:

```
Easy
```

Service calculates:

```
Review again after 14 days
```

---

# 17. Grade Calculator Service

## Responsibility

Handles academic grade calculations.

---

## Calculates

- Current grade
- Weighted grade
- Required future score
- Remaining assessment impact

---

## Example

Input:

```
Assignments = 20%

Midterm = 30%

Final = 50%
```

Output:

```
Current Grade

Required Final Score
```

---

# 18. Analytics Service

## Responsibility

Collects academic statistics.

---

## Tracks

- Study hours
- Flashcards reviewed
- Reading progress
- Assignment completion
- Review accuracy
- Study streak

---

## Privacy

Academic data remains local by default.

No information is transmitted without explicit user permission.

---

# 19. Background Task Service

## Responsibility

Handles background operations.

---

## Uses

```
BackgroundTasks Framework
```

---

## Tasks

- Cloud synchronization
- Notification scheduling
- Statistics updates
- Data maintenance

---

# 20. Service Protocol Design

Every major service should expose a protocol.

Example:

```swift
protocol CalendarServiceProtocol {

    func requestPermission() async throws

    func fetchEvents() async throws -> [CalendarEvent]

}
```

Implementation:

```
CalendarService

implements

CalendarServiceProtocol
```

---

# 21. Mock Services

Every service requires a mock implementation.

Examples:

```
MockCalendarService

MockAIService

MockNotificationService

MockCloudSyncService
```

Used for:

- Unit testing
- SwiftUI previews
- Development environments

---

# 22. Service Error Handling

Services should return meaningful errors.

Examples:

```
permissionDenied

networkUnavailable

authenticationFailed

syncConflict

invalidResponse

unsupportedFeature
```

ViewModels decide how errors are presented.

---

# 23. Async/Await Support

All long-running services should use Swift Concurrency.

Examples:

- AI generation
- Calendar sync
- Cloud sync
- File processing

Use:

```
async

await

Task
```

---

# 24. Service Dependencies

Services may depend on:

- Other services
- Repositories
- Apple frameworks

Example:

```
CloudSyncService

↓

SwiftData Repository

↓

CloudKit
```

Dependencies must always be injected.

---

# 25. Service Testing

Every service requires tests.

Examples:

## CalendarService

Test:

- Permission handling
- Event creation
- Event updates

---

## AIService

Test:

- Successful generation
- API failure
- Invalid response

---

## ReviewSchedulerService

Test:

- Interval calculation
- Difficulty adjustment

---

# 26. Service Security

Services must:

- Protect user data.
- Request minimum permissions.
- Secure authentication tokens.
- Avoid unnecessary network requests.
- Follow Apple's privacy requirements.

---

# 27. Future Services

Potential future services:

```
AppleMailService

OutlookService

CanvasService

MoodleService

ResearchPaperService

AppleIntelligenceService

SiriShortcutService
```

---

# 28. Service Rules Summary

Mandatory rules:

- Services handle external systems.
- Repositories handle stored data.
- ViewModels coordinate workflows.
- Views never directly call services.
- Services use Dependency Injection.
- Services expose protocols.
- Services support async/await.
- Services have mock implementations.
- Services avoid UI logic.

---

# 29. Service Architecture Summary

The StudyHub Service Layer provides a clean boundary between the application and external systems.

This architecture enables:

- Native Apple integrations
- AI capabilities
- Calendar synchronization
- Cloud support
- Future expansion

The Service Layer allows StudyHub to evolve from a planner into a complete academic operating system while maintaining a clean and scalable architecture.