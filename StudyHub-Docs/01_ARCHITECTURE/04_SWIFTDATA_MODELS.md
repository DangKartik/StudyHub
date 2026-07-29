# SWIFTDATA MODELS

**Project:** StudyHub  
**Document:** 04_SWIFTDATA_MODELS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team

---

# 1. Purpose

This document defines the complete SwiftData model architecture for StudyHub.

It specifies:

- Every persistent model
- Model responsibilities
- Model ownership
- Relationships
- Data integrity rules
- Future scalability

This is a design specification only.

Actual Swift model implementations are created during development.

---

# 2. Design Principles

StudyHub's data layer follows these principles.

- Every model represents one real-world concept.
- Models own their child objects.
- Relationships should mirror real academic workflows.
- Avoid duplicate data.
- Prefer references over copying information.
- Keep models focused and cohesive.
- Every model should have a stable unique identifier.

---

# 3. Core Model Hierarchy

The complete hierarchy is shown below.

```text
Semester
│
├── Courses
│   │
│   ├── Lectures
│   │   ├── Active Recall Questions
│   │   ├── Flashcards
│   │   ├── Attachments
│   │   └── Notes
│   │
│   ├── Assignments
│   │
│   ├── Readings
│   │
│   ├── Resources
│   │
│   ├── Grade Categories
│   │
│   ├── Exams
│   │
│   └── Notes
│
├── Statistics
│
├── Quotes
│
└── Study Sessions
```

---

# 4. Primary Models

The application contains the following primary models.

| Model | Purpose |
|--------|----------|
| Semester | Academic container |
| Course | Individual university course |
| Lecture | Single lecture |
| Assignment | Coursework |
| Reading | Reading task |
| Resource | External material |
| Exam | Examination |
| Quiz | Quiz or test |
| GradeCategory | Assessment weights |
| Flashcard | Learning card |
| ActiveRecallQuestion | Recall question |
| Note | Course- or Lecture-scoped note with attachments |
| StudySession | Study history |
| Quote | Daily motivation |
| StatisticsSnapshot | Historical analytics |
| Attachment | PDF, image or file |
| CalendarEventReference | Linked calendar event |

---

# 5. Semester Model

Represents one academic semester.

Examples

- Fall 2026
- Spring 2027
- Summer 2027

Properties

```
id

name

startDate

endDate

color

isArchived

createdAt

updatedAt
```

Relationships

```
Courses

Study Sessions

Statistics

Quotes
```

---

# 6. Course Model

Represents one university course.

Examples

```
SC2002

MH1812

CS101
```

Properties

```
id

name

courseCode

courseColor

instructor

email

secondInstructor

secondInstructorEmail

officeHours

credits

goodNotesNotebookID

notes

isArchived

createdAt

updatedAt
```

`courseColor` stores either a preset color name (e.g. `"blue"`) or a custom hex string (e.g. `"#3A7DFF"`); resolution and fallback are handled by a shared Color utility, not by the model (see DECISION-018).

`secondInstructor` / `secondInstructorEmail` represent an optional co-instructor as plain fields, not a separate relationship (see DECISION-019).

`isArchived` marks a course as archived, mirroring `Semester.isArchived` (see DECISION-016).

Relationships

```
Semester

Lectures

Assignments

Readings

Resources

Flashcards

Grade Categories

Exams

Quizzes

Notes (`noteEntries`)
```

---

# 7. Lecture Model

Represents one teaching session.

Properties

```
id

title

topic

date

startTime

endTime

location

summary

notes

createdAt

updatedAt
```

Relationships

```
Course

Flashcards

Active Recall Questions

Attachments

Notes (`noteEntries`)
```

---

# 8. Assignment Model

Properties

```
id

title

description

priority

status

progress

dueDate

submissionDate

estimatedHours

createdAt

updatedAt
```

Relationships

```
Course

Checklist

Attachments
```

---

# 9. Reading Model

Properties

```
id

title

author

pageCount

currentPage

estimatedMinutes

notes

dueDate

createdAt

updatedAt
```

Relationships

```
Course

Attachments
```

---

# 10. Resource Model

Represents external learning material.

Examples

- Website
- PDF
- Video
- GitHub Repository
- YouTube Playlist

Properties

```
id

title

type

url

notes

createdAt

updatedAt
```

`updatedAt` was added alongside Resource Management (see DECISION-023), bringing Resource in line with every other primary model's `id`/`createdAt`/`updatedAt` convention (§23).

Relationship

```
Course
```

---

# 11. Quiz Model

Properties

```
id

title

date

weight

score

maximumScore

notes

createdAt

updatedAt
```

`createdAt`/`updatedAt` were added per DECISION-025, bringing Quiz in line with the project-wide id/createdAt/updatedAt convention (§23) at the point Quiz became user-editable (Grade Tracker V1, Phase 3J).

Relationship

```
Course
```

---

# 12. Exam Model

Properties

```
id

title

date

location

weight

duration

notes

createdAt

updatedAt
```

`createdAt`/`updatedAt` were added per DECISION-025, bringing Exam in line with the project-wide id/createdAt/updatedAt convention (§23) at the point Exam became user-editable (Grade Tracker V1, Phase 3J).

Relationship

```
Course
```

---

# 13. Grade Category Model

Represents weighted grading.

Examples

```
Assignments

20%

Midterm

30%

Final

50%
```

Properties

```
id

title

weight

earnedScore

maximumScore

createdAt

updatedAt
```

`createdAt`/`updatedAt` were added per DECISION-025, bringing Grade Category in line with the project-wide id/createdAt/updatedAt convention (§23) at the point Grade Category became user-editable (Grade Tracker V1, Phase 3J).

Relationship

```
Course
```

---

# 14. Flashcard Model

Properties

```
id

front

back

image

tags

difficulty

nextReviewDate

lastReviewed

reviewCount

easeFactor

interval

createdAt
```

Relationships

```
Course

Lecture
```

---

# 15. Active Recall Question

Properties

```
id

question

answer

questionType

difficulty

lastReviewed

nextReviewDate
```

Relationship

```
Lecture
```

---

# 16. Note Model

Represents a Course- or Lecture-scoped note (see DECISION-028).

Properties

```
id

title

body

createdAt

updatedAt
```

`body` is plain text only; rich text, Markdown, and AI-generated content are explicitly deferred (see DECISION-028).

Relationships

```
Course (optional)

Lecture (optional)

Attachments
```

A Note may belong to a Course, a Lecture, or neither at creation time, but Version 1 only exposes Course- and Lecture-nested entry points — there is no unlinked "General" note or global library yet. Attachments reuse the existing Attachment Model (§20) rather than a separate file-storage structure.

---

# 17. Study Session

Represents one completed study session.

Properties

```
id

startTime

endTime

duration

completedPomodoros

focusScore

createdAt
```

Relationships

```
Semester

Courses Studied

Flashcards Reviewed
```

---

# 18. Quote Model

Properties

```
id

text

hasBeenShown

lastShown

createdAt
```

Quotes exist independently of semesters.

The rotation engine ensures every quote is shown once before repeating.

---

# 19. Statistics Snapshot

Stores historical statistics.

Examples

```
Daily Study Hours

Weekly Progress

Monthly Progress
```

Properties

```
id

date

studyHours

readingMinutes

assignmentsCompleted

flashcardsReviewed

accuracy
```

Relationship

```
Semester
```

---

# 20. Attachment Model

Represents attached files.

Supported types

- PDF
- Image
- Audio
- ZIP
- Markdown

Properties

```
id

filename

type

url

size

createdAt
```

Relationships

```
Lecture

Assignment

Reading

Resource

Note
```

`note` was added per DECISION-028, so a Note's attachments (lecture slides, PDFs, reference documents, or a GoodNotes deep-link reference stored as `type == "goodnotes"`) reuse this model rather than a separate structure.

---

# 21. Calendar Event Reference

Represents linked calendar events.

Properties

```
id

eventIdentifier

calendarIdentifier

lastSynced

syncStatus
```

Relationships

```
Lecture

Assignment

Exam
```

---

# 22. Enumerations

The following enums should be used instead of strings wherever possible.

Priority

```
Low

Medium

High

Critical
```

---

Assignment Status

```
Not Started

In Progress

Submitted

Completed

Overdue
```

---

Reading Status

```
Not Started

Reading

Completed
```

---

Question Type

```
Question Answer

Fill Blank

Definition

Diagram

Image

Essay
```

---

Resource Type

```
PDF

Website

Book

Video

Repository

Document
```

---

Study Mode

```
Flashcards

Active Recall

Reading

Mixed
```

---

# 23. Common Fields

Every persistent model should include:

```
id

createdAt

updatedAt
```

This simplifies synchronization and auditing.

---

# 24. Model Ownership

Ownership follows this hierarchy.

```
Semester

owns

Courses

↓

Course

owns

Lectures

Assignments

Readings

Resources

Grade Categories

Quizzes

Exams

Notes

↓

Lecture

owns

Flashcards

Recall Questions

Attachments

Notes
```

Deleting a parent removes all owned children.

---

# 25. Data Integrity Rules

- A Course must belong to one Semester.
- A Lecture must belong to one Course.
- A Flashcard may optionally belong to a Lecture.
- Every Assignment belongs to one Course.
- Every Reading belongs to one Course.
- Grade Categories belong to one Course.
- Quotes exist globally.
- Statistics belong to one Semester.
- A Note may optionally belong to a Course or a Lecture (see DECISION-028); it is never required to have either.

Invalid relationships should never be created.

---

# 26. Derived Data

The following values should **not** be stored.

Instead, compute them when needed.

Examples

- Current Grade
- Weighted Grade
- Attendance Percentage
- Remaining Assignments
- Study Streak
- Average Flashcard Accuracy
- Reading Completion Percentage

Derived values reduce duplication and prevent inconsistencies.

---

# 27. Searchable Models

Global search should index:

- Semester
- Course
- Lecture
- Assignment
- Reading
- Resource
- Flashcard
- Quote

Search metadata should be lightweight and updated automatically.

---

# 28. Future Models

Reserved for future versions.

- Email
- Study Group
- Research Paper
- Citation
- AI Conversation
- LMS Course
- Outlook Account
- Apple Mail Account

These are intentionally excluded from Version 1.0.

---

# 29. Migration Strategy

Models should evolve without data loss.

Future changes should use:

- Versioned schemas
- SwiftData migration plans
- Automatic migration where possible

Breaking changes should be avoided.

---

# 30. Performance Guidelines

Models should:

- Avoid deeply nested relationships.
- Store only necessary information.
- Minimize redundant data.
- Use lazy loading where appropriate.
- Support thousands of records efficiently.

---

# 31. SwiftData Model Summary

StudyHub's persistence layer is centered around the **Semester → Course → Academic Content** hierarchy.

This structure reflects how students naturally organize their university life while remaining scalable, efficient, and easy to maintain.

All future models should integrate into this hierarchy rather than introducing parallel or competing structures.