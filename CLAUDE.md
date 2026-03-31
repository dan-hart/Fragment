# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fragment is a native iOS/macOS application for managing GitHub Gists, built with SwiftUI and modern Swift concurrency. It targets iOS 26.0+ and macOS 26.0+ with Swift 6.2.

## Build Commands

```bash
# Build for macOS
xcodebuild -scheme macOS -configuration Debug build

# Build for iOS
xcodebuild -scheme iOS -configuration Debug build

# Run tests for macOS
xcodebuild test -scheme macOS

# Run tests for iOS
xcodebuild test -scheme iOS -destination "platform=iOS Simulator,name=iPhone 16 Pro"

# Clean build
xcodebuild clean -scheme macOS
```

**Important**: When verifying build success, always test both iOS and macOS schemes as this is a universal app. Both targets must build successfully.

## Architecture

### Core Components

- **SessionHandler** (`Shared/Handler/SessionHandler.swift`): Main business logic class marked with `@MainActor`. Handles GitHub authentication via OctoKit, token storage in Keychain, and gist management. Uses `@Published` properties for SwiftUI binding.

- **FragmentApp** (`Shared/FragmentApp.swift`): App entry point using `@main` and SwiftUI App lifecycle. Creates SessionHandler as `@StateObject` and passes to views via `@EnvironmentObject`.

- **Navigation Flow**: MainView → ContainerView (authenticated) or AuthenticationView (unauthenticated). Uses NavigationStack for iOS/macOS navigation.

### Key Patterns

- **Shared Codebase**: Single codebase in `Shared/` directory with platform-specific conditionals using `#if os(macOS)` and `#if os(iOS)`.

- **Swift Concurrency**: Uses modern async/await patterns. SessionHandler has a `callTask` helper for SwiftUI integration with async operations.

- **MVVM with SwiftUI**: Views are lightweight, SessionHandler acts as ViewModel/Model layer with `@Published` properties.

### Project Structure

```
Shared/
├── FragmentApp.swift          # App entry point
├── Handler/SessionHandler.swift # Main business logic
├── Views/
│   ├── MainView.swift         # Root navigation
│   ├── AuthenticationView.swift
│   ├── Container/ContainerView.swift # Main authenticated view
│   ├── CodeViews/CodeView.swift      # Code editor
│   └── Add/AddGistView.swift         # Gist creation
├── Models/                    # Data models (Language, Visibility, etc.)
└── Extensions/OctoKitExtensions/ # GitHub API extensions
```

## Dependencies

The project uses Swift Package Manager with these key dependencies:
- **OctoKit**: GitHub API integration (marked with `@preconcurrency`)
- **KeychainAccess**: Secure token storage
- **CodeEditor**: Syntax highlighting code editor
- **Highlightr**: Syntax highlighting engine

**Note**: SwifterSwift was recently removed due to build issues. Use standard Swift/Foundation methods instead (e.g., `(string as NSString).pathExtension` instead of `string.pathExtension`).

## Code Quality Tools

### SwiftFormat
Configuration in `.swiftformat.yml`:
- Uses 4-space indentation
- Swift 5.9 target
- Custom rules enabled for organization and consistency

### SwiftLint
Configuration in `.swiftlint.yml`:
- Extensive opt-in rules for code quality
- Missing docs enforcement
- Disabled rules for style flexibility

Both tools run automatically via Xcode build phases.

## Platform-Specific Notes

- **Deployment Targets**: Keep at iOS 26.0+ and macOS 26.0+ as configured
- **Universal App**: Single target builds for both iOS and macOS
- **Settings**: macOS has a dedicated Settings scene, iOS uses in-app settings
- **Authentication**: Uses GitHub Personal Access Tokens stored in Keychain

## Testing

- **iOS Tests**: `Fragment-iOS-Tests/`
- **macOS Tests**: `Fragment-macOS-Tests/`
- **Shared Tests**: `FragmentSharedTests/`

Test targets mirror the main app structure and test core functionality.