# RESOURCES

**Project:** StudyHub  
**Document:** 19_RESOURCES.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Product + UX Team  

---

# 1. Purpose

The Resources section provides a centralized location for students to store, organize, access, and manage all academic materials.

It acts as the student's academic knowledge library.

Resources include:

- Lecture slides.
- PDFs.
- Notes.
- Links.
- Videos.
- Code files.
- Reference materials.

---

# 2. Resource Philosophy

Students should not search for information repeatedly.

StudyHub organizes resources around learning context.

Traditional workflow:

```
Download File

↓

Save Somewhere

↓

Forget Location

↓

Search Again
```

StudyHub workflow:

```
Add Resource

↓

Connect To Course

↓

Organize Automatically

↓

Use While Learning
```

---

# 3. User Goals

Users should be able to:

- Store academic files.
- Organize resources by course.
- Link resources to lectures and readings.
- Search quickly.
- Preview materials.
- Annotate resources.
- Access resources anywhere.

---

# 4. Navigation Flow

Primary:

```
Sidebar

↓

Resources
```

---

Course-based:

```
Course Detail

↓

Resources

↓

Resource Detail
```

---

Content-based:

```
Lecture

↓

Related Resources

↓

Resource Detail
```

---

# 5. Resources Dashboard

The dashboard provides:

```
Recent Resources

Categories

Storage Usage

Favorites
```

---

Layout:

```
┌────────────────────────────┐
│ Resources             +    │
├────────────────────────────┤
│ Recent                     │
│ Lecture 5 Slides            │
│                            │
├────────────────────────────┤
│ Categories                 │
│ PDFs  Notes  Links         │
│                            │
├────────────────────────────┤
│ Favorites                  │
│ Important Materials        │
└────────────────────────────┘
```

---

# 6. Resource Types

Supported:

```
PDF

Document

Presentation

Spreadsheet

Image

Video

Audio

Link

Code File

Markdown
```

---

# 7. Resource Organization

Resources can be organized by:

```
Course

Semester

Lecture

Topic

Tag

Folder
```

---

Example:

```
SC302

↓

Lecture 06

↓

Graph Algorithms.pdf
```

---

# 8. Resource Categories

Default categories:

```
Lecture Materials

Textbooks

Research Papers

Notes

Assignments

Projects

References
```

---

# 9. Add Resource

Primary action:

```
+
```

---

Options:

```
Upload File

Add Link

Scan Document

Create Note

Import From Cloud
```

---

# 10. Resource Metadata

Every resource contains:

```
Title

Type

Course

Created Date

Modified Date

Tags

Source
```

---

Example:

```
Title:

Graph Algorithms Notes


Course:

SC302


Type:

PDF
```

---

# 11. Resource Card

Displays:

```
Icon

Title

Course

Last Opened

Favorite Status
```

---

Example:

```
📄

Binary Trees.pdf

SC302

Opened Yesterday
```

---

# 12. Resource Detail Page

Selecting a resource opens a dedicated page.

Contains:

```
Preview

Information

Related Content

Actions
```

---

Layout:

```
┌──────────────────────────┐
│ Resource Title            │
├──────────────────────────┤
│                          │
│ Preview                  │
│                          │
├──────────────────────────┤
│ Related                  │
│ Notes                    │
│ Flashcards               │
└──────────────────────────┘
```

---

# 13. Preview System

Supports previews for:

```
PDF

Images

Documents

Slides

Text Files
```

---

Actions:

```
Open

Download

Share

Annotate
```

---

# 14. PDF Viewer

Features:

```
Page Navigation

Search

Zoom

Bookmarks

Highlights

Annotations
```

---

# 15. Annotation System

Users can:

```
Highlight

Draw

Add Notes

Underline

Bookmark Pages
```

---

Supports:

```
Apple Pencil

Touch

Keyboard
```

---

# 16. Resource Linking

Resources connect with:

```
Courses

Lectures

Assignments

Readings

Notes

Flashcards

Active Recall
```

---

Example:

```
PDF

↓

Lecture 05

↓

Create Flashcards
```

---

# 17. Cloud Storage Integration

Future support:

```
iCloud Drive

Google Drive

OneDrive
```

---

Capabilities:

```
Import

Export

Sync
```

---

# 18. iCloud Integration

Native storage:

```
CloudKit

iCloud Drive
```

---

Syncs:

```
Resources

Metadata

Annotations

Relationships
```

---

# 19. Search

Global resource search:

Search by:

```
Title

Content

Course

Tags

File Type
```

---

Example:

Search:

```
Sorting Algorithms
```

Results:

```
Lecture Slides

Research Paper

Notes
```

---

# 20. Filtering

Filters:

```
Course

File Type

Semester

Date Added

Favorites
```

---

# 21. Favorites

Users can mark resources as important.

Example:

```
⭐ Exam Revision Notes
```

---

Favorites appear in:

```
Resources Dashboard

Home Dashboard
```

---

# 22. Recently Opened

Tracks:

```
Last Opened Time

Opening Frequency

Recent Activity
```

---

Example:

```
Recently Opened:

Machine Learning Notes

2 hours ago
```

---

# 23. AI Resource Assistance

Future AI features:

```
Summarize Document

Generate Notes

Create Flashcards

Extract Concepts

Generate Questions
```

---

Example:

Input:

```
Research Paper
```

Output:

```
Summary

Key Ideas

Recall Questions
```

---

# 24. Sharing

Users can:

```
Share Resource

Export

Copy Link
```

---

Sharing options:

```
AirDrop

Messages

Email

Files
```

---

# 25. Storage Management

Displays:

```
Storage Used

File Count

Largest Files
```

---

Example:

```
Storage:

2.4 GB / 5 GB
```

---

# 26. Offline Access

Users can mark resources:

```
Available Offline
```

---

Offline resources:

```
Downloaded

Cached

Accessible Without Internet
```

---

# 27. Empty State

No resources:

```
No Resources Yet

Upload your lecture notes,
slides, and study materials.

[Add Resource]
```

---

# 28. Loading State

Display:

- Resource skeleton cards.
- Preview loading.
- File processing indicator.

---

# 29. Error State

Example:

```
Unable to open resource.

Retry
```

---

# 30. Toolbar

Toolbar:

```
Leading:

Sidebar


Center:

Resources


Trailing:

+

Search

Filter
```

---

# 31. Context Menu

Long press:

```
Open

Rename

Move

Favorite

Share

Delete
```

---

# 32. ViewModel Responsibilities

ResourcesViewModel manages:

```
Load resources

Upload files

Organize resources

Search resources

Sync storage

Manage metadata

Handle previews
```

---

# 33. SwiftUI Structure

Recommended:

```
Features/

└── Resources/

    ├── ResourcesView.swift

    ├── ResourceCard.swift

    ├── ResourceDetailView.swift

    ├── ResourcePreviewView.swift

    ├── UploadResourceView.swift

    └── ResourcesViewModel.swift
```

---

# 34. Navigation Architecture

```
Sidebar

↓

Resources

↓

Resource Detail

↓

Related Learning Feature
```

---

# 35. Data Requirements

Models:

```
Resource

Course

Lecture

Reading

Assignment

Note

FileMetadata

Tag
```

---

# 36. Accessibility Requirements

Support:

- VoiceOver.
- Dynamic Type.
- Keyboard navigation.
- Reduced Motion.

---

VoiceOver example:

```
PDF Resource.

Graph Algorithms Notes.

SC302.

Last opened yesterday.
```

---

# 37. iPad Requirements

Optimized for:

## Landscape

Supports:

- File browser.
- Preview panel.
- Drag and drop.

---

## Portrait

Supports:

- Resource browsing.
- Focused preview.

---

## Apple Pencil

Supports:

- PDF annotation.
- Handwritten notes.

---

# 38. Performance Requirements

Resources must:

- Handle large files.
- Load previews efficiently.
- Cache frequently used files.
- Sync reliably.
- Manage storage efficiently.

---

# 39. Testing Checklist

```
□ Upload resource

□ Open resource

□ Preview files

□ Search

□ Filter

□ Favorite resource

□ Add annotation

□ Cloud sync

□ Offline access

□ Share resource

□ Storage management

□ Dark Mode

□ Dynamic Type

□ VoiceOver
```

---

# 40. Final Resource Architecture

```
Resources

        |

        ├── Files

        ├── Notes

        ├── Links

        ├── Annotations

        ├── Organization

        ├── Search

        └── Learning Integration
```

Resources transform StudyHub into a complete academic knowledge repository where every learning material is connected to the student's courses, notes, and learning workflow.