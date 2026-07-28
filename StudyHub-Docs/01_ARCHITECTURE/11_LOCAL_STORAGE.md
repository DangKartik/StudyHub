# LOCAL STORAGE

**Project:** StudyHub  
**Document:** 11_LOCAL_STORAGE.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team  

---

# 1. Purpose

This document defines the local storage architecture used throughout StudyHub.

Local storage is responsible for:

- Persisting user academic data
- Enabling offline functionality
- Providing fast application performance
- Managing cached information
- Supporting iCloud synchronization

StudyHub follows an offline-first architecture where local storage is the primary working environment.

---

# 2. Storage Philosophy

StudyHub follows the principle:

> The application should always work locally first and synchronize when possible.

The user should never depend on network availability to access academic information.

---

# 3. Storage Architecture

The storage architecture consists of multiple layers.

```
Application Layer

↓

Repository Layer

↓

SwiftData Layer

↓

Local Persistent Store

↓

CloudKit Synchronization
```

---

# 4. Technology Stack

StudyHub uses:

```
SwiftData

+

SQLite Persistent Store

+

CloudKit Sync
```

Supporting technologies:

- FileManager
- UserDefaults
- Keychain
- AppStorage
- File Protection APIs

---

# 5. Storage Categories

StudyHub separates data into five storage categories.

```
Core Data

User Preferences

Files

Cache

Secure Data
```

---

# 6. Core Academic Data Storage

Core academic data is stored using SwiftData.

Examples:

- Semesters
- Courses
- Lectures
- Assignments
- Readings
- Quizzes
- Exams
- Flashcards
- Study Sessions
- Statistics

---

# 7. SwiftData Persistent Store

SwiftData manages the primary database.

Responsibilities:

- Object persistence
- Relationships
- Fetching
- Updates
- Deletion
- Migration

---

# 8. Persistent Model Rules

All persistent models must:

- Have stable identifiers.
- Support migration.
- Define clear relationships.
- Avoid storing unnecessary computed data.
- Support CloudKit synchronization where required.

---

# 9. Model Identification

Every persistent object requires a unique identifier.

Example:

```swift
@Model
class Course {

    var id: UUID

    var name: String

}
```

---

# 10. Data Storage Hierarchy

StudyHub storage follows:

```
Semester

↓

Course

↓

Academic Content

↓

Learning Data

↓

Statistics
```

---

# 11. User Preferences Storage

Small user settings are stored separately.

Technology:

```
UserDefaults

+

AppStorage
```

---

# 12. User Preference Examples

Stored preferences:

- Theme preference
- Appearance mode
- Default calendar view
- Notification settings
- Study timer settings
- Dashboard customization
- User interface preferences

---

# 13. Preferences Rules

User preferences should:

- Be lightweight.
- Load quickly.
- Not contain academic records.
- Sync only when required.

---

# 14. Keychain Storage

Sensitive information must use Keychain.

Examples:

- Authentication tokens
- API credentials
- Secure identifiers

---

# 15. Keychain Rules

Never store:

- Passwords
- Tokens
- Private keys

inside:

- UserDefaults
- SwiftData
- Plain files

---

# 16. File Storage Architecture

Large files are stored separately from SwiftData.

Examples:

- PDFs
- Images
- Documents
- Lecture slides
- Attachments

Storage:

```
FileManager

↓

Application Container
```

---

# 17. File Organization

Recommended structure:

```
StudyHub Storage

├── Documents

│   ├── Courses

│   ├── Lectures

│   ├── Assignments

│   └── Resources


├── Attachments

├── Exports

└── Temporary
```

---

# 18. File References

SwiftData should store references, not file contents.

Example:

Stored:

```
attachmentURL
```

Not:

```
PDF Binary Data
```

---

# 19. Attachment Management

The File Service manages:

- Importing files
- Moving files
- Deleting files
- Exporting files
- File validation

Views should never directly manipulate files.

---

# 20. Cache Storage

Cache stores temporary information.

Examples:

- Search indexes
- Thumbnail images
- Generated previews
- Temporary AI results

---

# 21. Cache Rules

Cache data:

- Can be deleted safely.
- Should not contain user-critical information.
- Should improve performance only.

---

# 22. Search Index Storage

Search indexes may be stored locally.

Contains:

- Object identifiers
- Search terms
- Metadata

Does not contain:

- Duplicate academic data

---

# 23. AI Cache Storage

Temporary AI processing results may be cached.

Examples:

- Generated suggestions
- Temporary summaries
- Processing states

Rules:

- User approval required before saving permanently.
- Cache can be removed anytime.

---

# 24. Temporary Storage

Temporary files are stored separately.

Examples:

- Export files
- Preview images
- Imported documents before processing

Location:

```
Temporary Directory
```

---

# 25. Storage Cleanup

StudyHub should automatically clean:

- Temporary files
- Expired cache
- Unused previews

Cleanup triggers:

- Application launch
- Background maintenance
- Storage pressure

---

# 26. Data Deletion

When users delete data:

Example:

```
Delete Course
```

Process:

```
Remove SwiftData Object

↓

Delete Related Files

↓

Update Search Index

↓

Sync Cloud Changes
```

---

# 27. Backup Strategy

User data is protected through:

- iCloud Sync
- Device backups
- CloudKit private database

---

# 28. Export Support

Future versions may support:

- PDF export
- Markdown export
- JSON backup
- Complete academic archive

---

# 29. Database Migration

Storage changes require migration.

Process:

```
Old Schema

↓

Migration Plan

↓

New Schema

↓

Validation
```

---

# 30. Migration Rules

Before changing models:

- Test existing data.
- Test relationships.
- Test CloudKit compatibility.
- Test rollback scenarios.

---

# 31. Performance Guidelines

Storage operations should:

- Avoid blocking the main thread.
- Use asynchronous fetching where appropriate.
- Fetch only required data.
- Avoid unnecessary file duplication.
- Use pagination for large datasets.

---

# 32. Large Dataset Handling

Potential large collections:

- Flashcards
- Notes
- Attachments
- Study history

Strategies:

- Lazy loading
- Pagination
- Efficient predicates
- Background processing

---

# 33. Security and Privacy

Local storage must respect:

- Apple Data Protection
- User privacy
- Secure file handling

Sensitive information must never be stored insecurely.

---

# 34. Offline Behavior

When offline:

Users can:

- View courses
- Create assignments
- Review flashcards
- Write notes
- Track study sessions

Changes remain local until synchronization occurs.

---

# 35. Storage Testing

Testing includes:

## Database Testing

Verify:

- Save operations
- Fetch operations
- Updates
- Deletion

---

## Migration Testing

Verify:

- Existing user data
- Schema changes
- Relationship preservation

---

## File Testing

Verify:

- Import
- Export
- Delete
- Recovery

---

# 36. Storage Rules Summary

Mandatory rules:

- SwiftData stores academic objects.
- UserDefaults stores lightweight preferences.
- Keychain stores sensitive information.
- FileManager stores large files.
- Cache data must be disposable.
- Local storage is the primary source of truth.
- The app must work offline.
- Storage operations must be testable.
- Migration must be planned.
- User data must remain protected.

---

# 37. Local Storage Architecture Summary

StudyHub uses a layered local storage architecture:

```
SwiftData

↓

File Storage

↓

Preferences

↓

Cache

↓

Secure Storage
```

This provides:

- Fast performance
- Offline capability
- Reliable persistence
- Secure user data handling
- Seamless iCloud synchronization

The goal is to provide the reliability expected from a first-party Apple application while supporting the complexity of a complete academic operating system.