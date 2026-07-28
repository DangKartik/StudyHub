# SEARCH ARCHITECTURE

**Project:** StudyHub  
**Document:** 14_SEARCH_ARCHITECTURE.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering Team  

---

# 1. Purpose

This document defines the global search architecture for StudyHub.

The search system allows users to quickly find any academic information across the entire application.

StudyHub search should feel similar to:

- Apple Notes Search
- Spotlight Search
- Mail Search
- Files Search

The goal is to make every piece of academic information instantly accessible.

---

# 2. Search Philosophy

StudyHub follows the principle:

> Everything inside the academic ecosystem should be searchable.

Users should not need to remember:

- Which semester contains information.
- Which course contains notes.
- Which lecture contains a concept.
- Which assignment contains a requirement.

Search should become the universal entry point.

---

# 3. Search Architecture Overview

Architecture:

```
User Input

↓

Search Interface

↓

Search ViewModel

↓

Search Service

↓

Search Index

↓

Repositories

↓

SwiftData
```

---

# 4. Search Components

The search system consists of:

```
SearchView

SearchViewModel

SearchService

SearchIndexer

SearchRepository

SearchIndex
```

---

# 5. Search Service Responsibility

The SearchService manages:

- Query processing
- Index searching
- Result ranking
- Filtering
- Suggestions
- Recent searches

---

# 6. Search Service Interface

Example:

```swift
protocol SearchServiceProtocol {

    func search(
        query: String
    ) async throws -> [SearchResult]

    func index(
        item: SearchableItem
    ) async throws

    func remove(
        itemID: UUID
    ) async throws

}
```

---

# 7. Searchable Content

The following entities are searchable.

---

# Academic Content

## Semesters

Search:

- Semester name
- Academic year

Example:

```
Fall 2026
```

---

## Courses

Search:

- Course name
- Course code
- Instructor

Example:

```
SC2002 Object Oriented Design
```

---

## Lectures

Search:

- Lecture topic
- Keywords
- Concepts
- Objectives

Example:

```
Inheritance
```

---

## Assignments

Search:

- Title
- Description
- Requirements
- Rubric

Example:

```
Machine Learning Project
```

---

## Readings

Search:

- Book/article title
- Author
- Notes
- Highlights

---

## Resources

Search:

- File name
- Type
- Description

Examples:

- PDF
- Slides
- Links

---

# Learning Content

## Flashcards

Search:

- Question
- Answer
- Tags
- Concepts

Example:

```
Polymorphism
```

---

## Active Recall Questions

Search:

- Question text
- Topic
- Related lecture

---

## Notes

Search:

- Titles
- Text content
- Keywords

---

# Personal Content

## Quotes

Search:

- Quote text
- Author

---

## Study Sessions

Search:

- Subject
- Session notes
- Date

---

# 8. Search Index

StudyHub uses a dedicated search index.

Purpose:

- Improve performance.
- Avoid scanning the entire database.
- Provide instant results.

---

# 9. Search Index Structure

Example:

```
SearchIndexItem

{

id

entityType

title

subtitle

keywords

createdDate

updatedDate

}

```

---

# 10. Search Index Rules

The search index stores:

- Identifiers
- Metadata
- Searchable text

The search index does not store:

- Complete notes
- Files
- Large attachments
- Duplicate database objects

---

# 11. Indexing Process

When content is created:

```
User Creates Item

↓

SwiftData Save

↓

Repository Update

↓

SearchIndexer

↓

Search Index Updated
```

---

# 12. Updating Index

When content changes:

Example:

User edits lecture title.

Flow:

```
Update Lecture

↓

Update SwiftData

↓

Refresh Search Index
```

---

# 13. Removing From Index

When content is deleted:

```
Delete Object

↓

Remove Search Index Entry

↓

Update Search Results
```

---

# 14. Search Query Processing

User enters:

```
machine learning
```

Processing:

```
Normalize Query

↓

Tokenize Words

↓

Search Index

↓

Rank Results

↓

Display Results
```

---

# 15. Search Ranking

Results should be ranked by:

Priority:

```
Exact Match

↓

Title Match

↓

Keyword Match

↓

Content Match

↓

Recent Activity
```

---

# 16. Search Result Model

Example:

```swift
struct SearchResult {

    let id: UUID

    let type: SearchItemType

    let title: String

    let subtitle: String

    let relevanceScore: Double

}
```

---

# 17. Search Categories

Users can filter results.

Categories:

```
All

Courses

Lectures

Assignments

Readings

Notes

Flashcards

Resources

Quotes
```

---

# 18. Search Suggestions

Before typing:

Show:

- Recent searches
- Frequently accessed items
- Upcoming deadlines
- Recommended content

---

# 19. Recent Searches

Store:

- Search query
- Date
- Result opened

Storage:

```
UserDefaults
```

or

```
SwiftData
```

depending on complexity.

---

# 20. Global Search Interface

Search should be accessible from:

- Sidebar
- Keyboard shortcut
- Command menu
- Dashboard

---

# 21. iPad Search Design

StudyHub follows iPadOS patterns.

Supports:

- Large search field
- Keyboard input
- Pointer interaction
- Split view usage

---

# 22. Keyboard Shortcuts

Future support:

```
Command + F

↓

Open Search
```

---

# 23. Natural Language Search

Future AI-powered search:

Examples:

User:

```
Show my weak topics before my AI exam
```

System:

```
Finds:

AI course

Weak flashcards

Upcoming exam

Study recommendation
```

---

# 24. Semantic Search

Future versions may support:

- Concept matching
- Meaning-based search
- Related topic discovery

Example:

Search:

```
inheritance
```

Finds:

```
Object-oriented programming

Classes

Polymorphism

Parent-child relationships
```

---

# 25. File Search

File search supports:

- PDFs
- Slides
- Images
- Documents

Search metadata:

- Filename
- Course
- Lecture
- Date

---

# 26. OCR Support

Future feature:

Extract text from:

- Handwritten notes
- Images
- Scanned PDFs

Technologies:

- Vision Framework
- Apple Intelligence

---

# 27. Search Performance

Search must:

- Return results quickly.
- Avoid blocking the UI.
- Run heavy indexing in background.
- Cache frequently accessed results.

---

# 28. Background Indexing

Index updates may run during:

- App launch
- Background tasks
- Data changes

---

# 29. Search Error Handling

Possible errors:

```
Index unavailable

Database unavailable

Invalid query

Search timeout
```

---

# 30. Search Privacy

Search data remains private.

StudyHub must not:

- Upload search history.
- Share academic content.
- Send notes externally without permission.

---

# 31. Search Testing

Testing includes:

## Unit Tests

Verify:

- Query processing
- Ranking
- Filtering
- Index updates

---

## Integration Tests

Verify:

- SwiftData integration
- Repository communication

---

## UI Tests

Verify:

- Search interface
- Result navigation
- Empty states

---

# 32. Empty Search States

Examples:

No query:

```
Search your academic workspace
```

No results:

```
No results found

Try another keyword
```

---

# 33. Accessibility

Search supports:

- VoiceOver
- Dynamic Type
- Keyboard navigation
- Focus management

---

# 34. Future Search Features

Potential additions:

```
AI Semantic Search

Voice Search

Spotlight Integration

Siri Search

Handwriting Recognition

Cross-App Search
```

---

# 35. Search Architecture Rules Summary

Mandatory rules:

- Search must cover the entire application.
- Search uses an optimized index.
- SwiftData remains the source of truth.
- Search indexes store metadata only.
- Search runs asynchronously.
- Search must respect privacy.
- Results must be ranked intelligently.
- Search must support iPad workflows.

---

# 36. Search Architecture Summary

StudyHub search provides a unified academic search engine.

Architecture:

```
SwiftData

↓

Repositories

↓

Search Index

↓

Search Service

↓

Search UI
```

This allows StudyHub to provide a fast, intelligent, and privacy-focused search experience similar to Apple's own applications.