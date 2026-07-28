# DATA RELATIONSHIPS

**Project:** StudyHub  
**Document:** 05_DATA_RELATIONSHIPS.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team

---

# 1. Purpose

This document defines how every SwiftData model relates to every other model within StudyHub.

It specifies:

- Ownership
- Cardinality
- Cascade delete behavior
- Optional vs required relationships
- Data integrity rules
- Relationship lifecycle

This document is the single source of truth for all SwiftData relationships.

---

# 2. Design Principles

Every relationship in StudyHub follows these principles.

## Ownership

Every child object has exactly one owner.

No object should have multiple parents.

---

## Single Source of Truth

Information should exist in only one place.

Avoid duplicate relationships.

---

## Strong Parent Hierarchy

Deleting a parent should cleanly remove its owned children unless explicitly stated otherwise.

---

## Predictability

Every model should have a clear place within the academic hierarchy.

---

# 3. Overall Relationship Hierarchy

```
Semester
│
├── Courses
│   │
│   ├── Lectures
│   │   ├── Attachments
│   │   └── Active Recall Questions
│   │
│   ├── Assignments
│   │   ├── Checklist Items
│   │   └── Attachments
│   │
│   ├── Readings
│   │   └── Attachments
│   │
│   ├── Resources
│   │
│   ├── Grade Categories
│   │
│   ├── Quizzes
│   │
│   ├── Exams
│   │
│   └── Study Materials
│       ├── Flashcards
│       ├── AI Summaries
│       ├── Weak Topics
│       └── Review Sessions
│
├── Study Sessions
│
└── Statistics
```

---

# 4. Semester Relationships

## Owns

- Courses
- Study Sessions
- Statistics Snapshots

Relationship Type

```
Semester

1

↓

Many

Courses
```

Delete Rule

Cascade

Deleting a semester removes all associated academic data.

---

# 5. Course Relationships

A Course belongs to exactly one Semester.

A Course owns:

- Lectures
- Assignments
- Readings
- Resources
- Exams
- Quizzes
- Grade Categories
- Study Materials

Relationship

```
Semester

1

↓

Many

Courses
```

---

# 6. Lecture Relationships

Each Lecture belongs to one Course.

Each Lecture owns:

- Attachments
- Active Recall Questions

A Lecture may reference Flashcards but does not own them.

```
Course

1

↓

Many

Lectures
```

---

# 7. Assignment Relationships

Each Assignment belongs to one Course.

Each Assignment owns:

- Checklist Items
- Attachments

Relationship

```
Course

1

↓

Many

Assignments
```

---

# 8. Reading Relationships

Each Reading belongs to one Course.

Each Reading owns:

- Attachments

Relationship

```
Course

1

↓

Many

Readings
```

---

# 9. Resource Relationships

Each Resource belongs to one Course.

Resources do not own children.

Relationship

```
Course

1

↓

Many

Resources
```

---

# 10. Exam Relationships

Each Exam belongs to one Course.

Relationship

```
Course

1

↓

Many

Exams
```

---

# 11. Quiz Relationships

Each Quiz belongs to one Course.

Relationship

```
Course

1

↓

Many

Quizzes
```

---

# 12. Grade Category Relationships

Each Grade Category belongs to one Course.

Relationship

```
Course

1

↓

Many

Grade Categories
```

---

# 13. Study Material Relationships

Study Materials belong to one Course.

Study Materials include:

- Flashcards
- AI Summaries
- Weak Topics
- Review Sessions

Relationship

```
Course

1

↓

Many

Study Materials
```

---

# 14. Flashcard Relationships

Each Flashcard belongs to one Course.

Optional references

- Lecture
- Reading
- Assignment

These references indicate where the flashcard originated.

They are not ownership relationships.

Relationship

```
Course

1

↓

Many

Flashcards
```

Optional

```
Flashcard

↓

Lecture

(Optional)
```

---

# 15. Active Recall Relationships

Each Active Recall Question belongs to one Lecture.

Relationship

```
Lecture

1

↓

Many

Active Recall Questions
```

---

# 16. Attachment Relationships

Attachments always belong to one parent.

Possible parents

- Lecture
- Assignment
- Reading

An attachment cannot belong to multiple parents.

---

# 17. Study Session Relationships

Each Study Session belongs to one Semester.

It may reference multiple Courses.

Relationship

```
Semester

1

↓

Many

Study Sessions
```

Course relationship

```
Study Session

Many

↔

Many

Courses
```

---

# 18. Statistics Relationships

Statistics belong to one Semester.

Relationship

```
Semester

1

↓

Many

Statistics Snapshots
```

---

# 19. Quote Relationships

Quotes are global.

They do not belong to any Semester.

Reason

Motivational quotes should persist across all academic years.

---

# 20. Calendar Relationships

Calendar Event References may belong to:

- Lecture
- Assignment
- Exam

Each academic object may have zero or one linked calendar event.

---

# 21. GoodNotes Relationships

Each Course may reference one GoodNotes notebook.

Each Lecture may optionally reference one GoodNotes page.

StudyHub never owns GoodNotes content.

Only identifiers are stored.

---

# 22. AI Relationships

AI-generated content belongs to the object that requested it.

Examples

Lecture Summary

```
Lecture

↓

AISummary
```

Generated Flashcards

```
Course

↓

Flashcards
```

Generated Quiz

```
Lecture

↓

Quiz
```

Deleting the parent deletes generated AI content.

---

# 23. Notification Relationships

Notifications are generated from existing models.

Notifications never own data.

Examples

```
Assignment

↓

Notification
```

```
Exam

↓

Notification
```

Notifications are recreated when necessary.

---

# 24. Search Relationships

The Search Index references models.

It never owns them.

Deleting an object automatically removes its search index entry.

---

# 25. Many-to-Many Relationships

Only a small number of many-to-many relationships are allowed.

Examples

Study Session ↔ Courses

Tags ↔ Flashcards (future)

All other relationships should remain one-to-many.

---

# 26. Delete Rules

## Cascade Delete

Deleting a Semester removes:

- Courses
- Lectures
- Assignments
- Readings
- Resources
- Exams
- Quizzes
- Grade Categories
- Flashcards
- Active Recall Questions
- Study Sessions
- Statistics

---

Deleting a Course removes:

- Lectures
- Assignments
- Readings
- Resources
- Exams
- Quizzes
- Grade Categories
- Study Materials

---

Deleting a Lecture removes:

- Attachments
- Active Recall Questions

Flashcards remain but lose their Lecture reference.

---

Deleting an Assignment removes:

- Checklist Items
- Attachments

---

Deleting a Reading removes:

- Attachments

---

# 27. Nullify Rules

The following references are optional.

Flashcard

↓

Lecture

Flashcard

↓

Reading

Flashcard

↓

Assignment

If the source object is deleted, the reference becomes nil.

The Flashcard itself remains.

---

# 28. Relationship Constraints

Every Course must belong to exactly one Semester.

Every Lecture must belong to exactly one Course.

Every Assignment must belong to exactly one Course.

Every Reading must belong to exactly one Course.

Every Exam must belong to exactly one Course.

Every Quiz must belong to exactly one Course.

Every Grade Category must belong to exactly one Course.

Every Active Recall Question must belong to exactly one Lecture.

Quotes have no parent.

---

# 29. Relationship Validation

Before saving data, validate that:

- Required parents exist.
- Circular references do not exist.
- Duplicate ownership is impossible.
- Required foreign keys are present.
- Delete rules remain valid.

Invalid relationships should never be persisted.

---

# 30. Relationship Performance

Relationships should support:

- Lazy loading
- Efficient SwiftData fetches
- Minimal memory usage
- Fast dashboard queries
- Fast search indexing

Avoid deeply nested fetch chains.

---

# 31. Future Relationships

Reserved for future versions.

Potential additions

- Study Groups
- Research Papers
- Citations
- AI Conversations
- Email Threads
- LMS Assignments
- Shared Notes

These should integrate into the existing hierarchy without breaking current relationships.

---

# 32. Relationship Summary

StudyHub uses a clear hierarchical ownership model.

Core ownership chain

```
Semester
    ↓
Course
    ↓
Academic Content
    ↓
Child Objects
```

This architecture ensures:

- Clear ownership
- Predictable deletion
- Strong data integrity
- Minimal duplication
- Efficient queries
- Excellent scalability

Every relationship in StudyHub should conform to this hierarchy unless explicitly documented otherwise.