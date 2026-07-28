# GLOSSARY

**Project:** StudyHub  
**Document:** GLOSSARY.md  
**Version:** 1.0  
**Status:** Reference  
**Owner:** Product + Engineering Team  

---

# 1. Purpose

This glossary defines important concepts, technical terms, product terms, and architectural vocabulary used throughout StudyHub documentation.

The purpose is to ensure:

```
Shared Understanding

Consistent Communication

Clear Development

Better Collaboration
```

---

# 2. Product Glossary

---

# StudyHub

A personal academic operating system designed to help students organize, learn, and improve their study habits.

Core areas:

```
Academic Management

Learning Tools

Productivity

AI Assistance

Analytics
```

---

# Academic Operating System

A unified platform that manages all aspects of a student's academic workflow.

Includes:

```
Courses

Tasks

Notes

Learning

Progress Tracking
```

---

# Academic Workspace

The complete environment where a student's academic information is organized.

Contains:

```
Semesters

Courses

Lectures

Assignments

Resources
```

---

# Knowledge System

A structured method for storing, connecting, and retrieving information.

In StudyHub:

```
Notes

Flashcards

Resources

Concepts
```

---

# Second Brain

A digital system that stores and organizes external knowledge to reduce mental load.

---

# 3. User Interface Glossary

---

# App Shell

The permanent structure surrounding application content.

Includes:

```
Navigation

Sidebar

Tab Bar

Global Actions
```

---

# View

A user interface screen or reusable visual element.

Examples:

```
HomeView

CourseView

SettingsView
```

---

# Screen

A complete user-facing page.

Example:

```
Course Details Screen
```

---

# Component

A reusable UI building block.

Examples:

```
Button

Card

Search Bar

Progress Ring
```

---

# Design System

A collection of rules and reusable components that define the visual identity of an application.

Includes:

```
Colors

Typography

Spacing

Components

Animations
```

---

# Component Library

A collection of reusable UI components used throughout StudyHub.

---

# Empty State

A screen displayed when no information exists.

Example:

```
No Flashcards Yet

Create Your First Deck
```

---

# Loading State

A temporary UI shown while information is being retrieved or processed.

Examples:

```
Progress Indicator

Skeleton View
```

---

# Error State

A UI state shown when something fails.

Purpose:

```
Explain Problem

Guide Recovery
```

---

# 4. Academic Glossary

---

# Semester

A defined academic period containing courses and learning activities.

---

# Course

A subject or academic module taken by a student.

Example:

```
Computer Science

Mathematics
```

---

# Course Dashboard

A central overview page for a course.

Contains:

```
Progress

Lectures

Assignments

Resources

Statistics
```

---

# Lecture

A learning unit within a course.

Can contain:

```
Notes

Files

Readings

Concepts
```

---

# Reading

Additional educational material.

Examples:

```
Book Chapter

Research Paper

Article
```

---

# Resource

Any supporting learning material.

Examples:

```
PDF

Website

Video

File
```

---

# Assignment

An academic task with a completion requirement.

Contains:

```
Title

Deadline

Priority

Status
```

---

# Deadline

The expected completion date or time for an academic task.

---

# 5. Learning Science Glossary

---

# Active Recall

A learning technique where a learner actively retrieves information from memory.

Example:

```
Question

↓

Recall Answer

↓

Check Understanding
```

---

# Spaced Repetition

A memory technique that schedules reviews at increasing intervals.

Goal:

```
Long-Term Retention
```

---

# Flashcard

A learning object containing:

```
Question

Answer
```

used for active recall.

---

# Flashcard Deck

A group of related flashcards.

Example:

```
Machine Learning Basics Deck
```

---

# Review Session

A session where flashcards or learning material are practiced.

---

# Study Session

A focused period of academic activity.

Tracked data:

```
Duration

Activity

Progress
```

---

# Study Mode

A focused environment designed to improve concentration.

Features:

```
Timer

Focus Tools

Distraction Reduction
```

---

# Pomodoro Technique

A time management method using focused work intervals followed by breaks.

---

# 6. AI Glossary

---

# AI Assistant

An intelligent system that helps students learn and organize information.

Capabilities:

```
Explanation

Summarization

Question Generation

Planning
```

---

# AI Tutor

A personalized AI system that teaches concepts based on student needs.

---

# AI Context

Information provided to an AI system to improve relevance.

Examples:

```
Course Notes

Lecture Material

Learning History
```

---

# AI Generation

The process of creating new content using artificial intelligence.

Examples:

```
Study Questions

Summaries

Explanations
```

---

# AI Hallucination

When an AI system produces incorrect or unsupported information.

StudyHub should reduce this through:

```
Context

Verification

Clear Sources
```

---

# 7. Architecture Glossary

---

# MVVM

Model-View-ViewModel architecture pattern.

Structure:

```
Model

↓

ViewModel

↓

View
```

---

# Model

Represents application data.

Examples:

```
Course

Assignment

Flashcard
```

---

# View

Displays information to the user.

Responsible for:

```
Layout

Interaction

Presentation
```

---

# ViewModel

Manages:

```
UI State

Business Logic

Data Preparation
```

---

# Service

A component responsible for specific operations.

Examples:

```
CalendarService

AIService

SyncService
```

---

# Repository

A layer responsible for accessing and managing data.

Example:

```
CourseRepository
```

---

# Dependency Injection

A technique where dependencies are provided instead of created internally.

Benefits:

```
Testing

Flexibility

Maintainability
```

---

# 8. Data Glossary

---

# SwiftData

Apple framework used for local data persistence.

Stores:

```
Courses

Notes

Tasks

Flashcards
```

---

# CloudKit

Apple cloud service used for synchronization and storage.

---

# Local Storage

Data stored directly on the device.

---

# Cloud Sync

Process of keeping data consistent across devices.

Example:

```
iPhone

↓

iPad

↓

Mac
```

---

# Backup

A saved copy of data used for recovery.

---

# Migration

The process of updating existing data after application changes.

---

# 9. Engineering Glossary

---

# API

Application Programming Interface.

A method for software systems to communicate.

---

# SDK

Software Development Kit.

A collection of tools used for building applications.

---

# Framework

A reusable software foundation providing functionality.

---

# Dependency

External code required by an application.

---

# Build

A compiled version of an application.

---

# Release

A publicly available version of the application.

---

# Version

A numbered identifier representing application changes.

Example:

```
1.2.0
```

---

# Semantic Versioning

A versioning system:

```
MAJOR.MINOR.PATCH
```

Example:

```
2.4.1
```

---

# Regression

A previously working feature becoming broken after changes.

---

# Technical Debt

Future work created by choosing faster solutions instead of ideal solutions.

---

# 10. Performance Glossary

---

# Latency

The delay between an action and response.

Example:

```
Search Request

↓

Results Display
```

---

# Memory Leak

When unused memory is not released.

---

# Cache

Temporary stored data used to improve speed.

---

# Lazy Loading

Loading data only when required.

---

# Background Task

A process running without blocking the user interface.

---

# 11. Security Glossary

---

# Encryption

Converting data into a protected format to prevent unauthorized access.

---

# Authentication

Verifying user identity.

Examples:

```
Apple ID

Face ID
```

---

# Authorization

Determining what an authenticated user can access.

---

# Keychain

Apple's secure storage system for sensitive information.

---

# Privacy

Protecting user information and controlling data usage.

---

# 12. Apple Ecosystem Glossary

---

# Human Interface Guidelines (HIG)

Apple's design guidelines for creating native applications.

---

# SF Symbols

Apple's icon library designed for use in applications.

---

# SwiftUI

Apple framework for building user interfaces.

---

# UIKit

Apple framework for traditional interface development.

---

# Xcode

Apple's official development environment.

---

# TestFlight

Apple platform for beta testing applications.

---

# App Store Connect

Apple platform for managing app distribution.

---

# 13. Final Glossary Map

```
StudyHub

|

├── Academic System

|      ├── Courses

|      ├── Lectures

|      ├── Assignments

|      └── Resources

|

├── Learning System

|      ├── Flashcards

|      ├── Active Recall

|      ├── Spaced Repetition

|      └── Study Mode

|

├── Intelligence

|      ├── AI Assistant

|      ├── AI Tutor

|      └── Analytics

|

└── Engineering

       ├── Architecture

       ├── Storage

       ├── Security

       └── Performance
```

---

# 14. Final Principle

A shared vocabulary creates a shared vision.

Every person working on StudyHub should understand the same terms, use the same language, and build toward the same product experience.

```
One Product

One Language

One Vision
```