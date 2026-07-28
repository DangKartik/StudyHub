# ICLOUD SYNC

**Project:** StudyHub  
**Document:** 10_ICLOUD_SYNC.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team  

---

# 1. Purpose

This document defines the iCloud synchronization architecture for StudyHub.

The purpose of iCloud Sync is to provide:

- Seamless multi-device synchronization
- Secure user-owned data storage
- Offline-first functionality
- Conflict resolution
- Reliable academic data continuity

StudyHub should feel like a first-party Apple application where users can move between:

- iPad
- iPhone
- Mac

without losing academic data.

---

# 2. Sync Philosophy

StudyHub follows the principle:

> User data belongs to the user and should remain available across all Apple devices.

The application should work:

- Offline
- Online
- During synchronization
- During network failures

The user should never manually manage backups.

---

# 3. Technology Stack

StudyHub uses:

```
SwiftData

+

CloudKit

+

iCloud Container
```

Primary frameworks:

- SwiftData
- CloudKit
- CloudKit Dashboard
- BackgroundTasks
- Network Framework

---

# 4. Sync Architecture

High-level architecture:

```
SwiftUI Views

↓

ViewModels

↓

Repositories

↓

SwiftData Local Database

↓

CloudKit Synchronization

↓

iCloud Private Database
```

---

# 5. Sync Model

StudyHub uses an offline-first architecture.

The local database is the primary working database.

Flow:

```
User Action

↓

SwiftData Local Save

↓

Background Sync

↓

CloudKit Upload

↓

Other Devices Receive Changes
```

---

# 6. Offline First Design

StudyHub must remain fully functional without internet access.

Users can:

- Create courses
- Add assignments
- Write notes
- Review flashcards
- Track study sessions
- Update grades

All changes are stored locally first.

---

# 7. Local Data Ownership

SwiftData owns the local application database.

Examples:

Stored locally:

- Courses
- Lectures
- Assignments
- Flashcards
- Notes
- Statistics
- Study sessions

CloudKit stores synchronized copies.

---

# 8. iCloud Container

StudyHub requires a dedicated iCloud container.

Example:

```
iCloud.com.studyhub.app
```

The container stores:

- User academic data
- Preferences
- Sync metadata

---

# 9. CloudKit Database Design

StudyHub uses the private CloudKit database.

Database:

```
Private Database
```

Reason:

Academic data is personal.

Each user owns their own data.

---

# 10. Cloud Records

CloudKit records represent SwiftData models.

Examples:

```
SemesterRecord

CourseRecord

LectureRecord

AssignmentRecord

FlashcardRecord

StudySessionRecord
```

---

# 11. Syncable Models

The following models support iCloud Sync.

## Academic Data

- Semester
- Course
- Lecture
- Assignment
- Reading
- Quiz
- Exam
- Resource

---

## Learning Data

- Flashcard
- Active Recall Question
- Review History
- Study Session

---

## Analytics Data

- Study Statistics
- Progress Records
- Streak Data

---

## User Data

- Quotes
- Preferences
- Settings

---

# 12. Non-Syncable Data

Some data remains device-specific.

Examples:

- Temporary UI state
- Navigation position
- Loading states
- Cache files
- Search history
- Temporary AI responses

---

# 13. Sync Service

The CloudSyncService manages synchronization.

Responsibilities:

- Monitor sync status
- Trigger synchronization
- Handle failures
- Report progress
- Resolve conflicts

---

# 14. CloudSyncService Interface

Example:

```swift
protocol CloudSyncServiceProtocol {

    func sync() async throws

    func uploadChanges() async throws

    func downloadChanges() async throws

    func getSyncStatus() async -> SyncStatus

}
```

---

# 15. Sync States

StudyHub exposes synchronization status.

States:

```swift
enum SyncStatus {

    case idle

    case syncing

    case completed

    case failed(Error)

    case offline

}
```

---

# 16. Background Synchronization

Synchronization should happen automatically.

Triggers:

- Application launch
- Application enters background
- Network availability restored
- User manually refreshes
- Periodic background tasks

---

# 17. Background Task Integration

StudyHub uses:

```
BackgroundTasks Framework
```

For:

- Syncing changes
- Updating statistics
- Refreshing notifications

---

# 18. Conflict Resolution

Conflicts occur when:

- Multiple devices edit the same object.
- Offline changes happen simultaneously.

Example:

```
iPad

↓

Changes Course Name


Mac

↓

Changes Course Instructor
```

---

# 19. Conflict Strategy

StudyHub uses:

## Last Write Wins

Default behavior:

The newest valid change replaces the older value.

---

## Field-Level Merging

For certain objects:

Example:

Course:

```
Name

+

Instructor

+

Notes
```

Different fields may merge independently.

---

# 20. Conflict Priority

Priority order:

```
User Manual Changes

↓

Generated AI Content

↓

Automatic Updates

↓

Cached Data
```

Manual user edits always have priority.

---

# 21. Sync Error Handling

Possible errors:

```
No Internet Connection

Authentication Failed

CloudKit Unavailable

Storage Limit Reached

Conflict Detected
```

---

# 22. User Feedback

Users should see sync status.

Examples:

```
✓ Synced

↻ Syncing

⚠ Sync Issue

Offline
```

The app should avoid technical error messages.

---

# 23. Data Migration

When database models change:

Process:

```
Old SwiftData Model

↓

Migration Layer

↓

New SwiftData Model

↓

Cloud Sync Update
```

---

# 24. Migration Rules

Before releasing model changes:

- Test local migration.
- Test CloudKit compatibility.
- Test multiple devices.
- Test existing user data.

---

# 25. Delete Synchronization

Deleting data should synchronize.

Example:

User deletes:

```
Course A
```

Flow:

```
Local Delete

↓

SwiftData Update

↓

CloudKit Delete

↓

Other Devices Remove Course
```

---

# 26. Soft Delete Strategy

For important academic data, StudyHub may support soft deletion.

Example:

Instead of immediately deleting:

```
isDeleted = true
```

Benefits:

- Recovery
- Conflict handling
- Safer synchronization

---

# 27. Large Files and Attachments

Large files should not be stored directly in CloudKit records.

Examples:

- PDFs
- Images
- Lecture recordings

Use:

```
CKAsset
```

---

# 28. GoodNotes Sync

StudyHub does not sync GoodNotes content.

Only stores:

- Notebook links
- Page references

GoodNotes manages its own iCloud synchronization.

---

# 29. AI Data Sync

AI-generated content follows special rules.

Synced:

- Saved summaries
- Approved flashcards
- Generated questions

Not synced:

- Temporary conversations
- Processing states
- API responses before approval

---

# 30. Privacy Requirements

StudyHub must:

- Request iCloud permission properly.
- Explain data usage.
- Never upload data without consent.
- Respect Apple's privacy guidelines.

---

# 31. Security

Cloud data protection includes:

- iCloud account authentication
- CloudKit security model
- Local device encryption
- Secure storage of credentials

---

# 32. Testing Strategy

iCloud Sync testing includes:

## Single Device

Test:

- Local save
- Sync upload
- Sync recovery

---

## Multiple Devices

Test:

- iPad to Mac
- iPad to iPhone
- Conflict resolution

---

## Offline Testing

Test:

- Create data offline
- Reconnect network
- Sync completion

---

# 33. Performance Guidelines

Synchronization should:

- Run in the background.
- Avoid blocking the UI.
- Batch changes when possible.
- Minimize network usage.
- Prioritize important changes.

---

# 34. Future Sync Features

Possible future additions:

- Shared study groups
- Collaborative notes
- Shared courses
- Family sharing
- University accounts
- LMS synchronization

---

# 35. iCloud Sync Rules Summary

Mandatory rules:

- SwiftData is the local source of truth.
- CloudKit provides synchronization.
- The app must work offline.
- Sync runs automatically.
- User changes have priority.
- Conflicts must resolve safely.
- Large files use CKAsset.
- Temporary UI state is never synced.
- Sensitive data remains private.

---

# 36. iCloud Sync Architecture Summary

StudyHub uses an offline-first SwiftData + CloudKit architecture.

This provides:

- Reliable synchronization
- Native Apple ecosystem support
- Secure academic data storage
- Seamless device switching
- Professional first-party app behavior

The goal is for StudyHub to feel like an Apple-designed academic operating system rather than a simple planner.