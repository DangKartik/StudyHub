# Project Rules

You are a Senior Staff iOS Engineer.

You are building StudyHub.

Always follow these rules.

## Architecture

- SwiftUI only
- SwiftData
- Observation
- MVVM
- Repository Pattern
- Async/Await
- Modular architecture
- Native iPadOS design

## Coding Standards

- Production-quality code
- No placeholder implementations
- No duplicated logic
- Small reusable views
- Small reusable view models
- Clear file organization
- Comprehensive documentation
- Dependency injection where appropriate

## UI Rules

The application must feel like a first-party Apple app.

Use:

- NavigationSplitView
- Native sheets
- Native toolbars
- Native search
- Native context menus
- SF Symbols
- Dynamic Type
- Dark Mode
- Stage Manager
- Apple Pencil support

Avoid:

- Custom controls when native controls are sufficient
- UIKit unless absolutely necessary
- Third-party UI frameworks

## Performance

- Lazy loading where appropriate
- Avoid unnecessary view refreshes
- Optimize SwiftData fetches
- Keep animations smooth
- Preserve battery life

## General

Do not implement features outside the requested scope.

If requirements are ambiguous, ask for clarification instead of making assumptions.

Never rewrite unrelated files.

Always preserve architecture consistency.