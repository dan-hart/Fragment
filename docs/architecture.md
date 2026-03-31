# Fragment Architecture

Fragment is a shared SwiftUI codebase for iOS and macOS that manages GitHub Gists.

## High-level structure

- `Shared/FragmentApp.swift`: app entry point, settings scene, macOS command menu
- `Shared/Handler/SessionHandler.swift`: main observable coordinator for auth, gist state, cache state, and alerts
- `Shared/Handler/GistServices.swift`: GitHub auth and gist network helpers
- `Shared/Handler/GistStorage.swift`: cache persistence, search parsing, diff summaries
- `Shared/Models/GistDocument.swift`: app-facing gist model and freshness state
- `Shared/Views/*`: SwiftUI screens and feature views

## Data flow

1. `FragmentApp` creates a single `SessionHandler`.
2. `SessionHandler` validates the token and refreshes gists from GitHub.
3. Fresh gists are converted to `GistDocument` values and cached locally.
4. If GitHub is unavailable, the app can fall back to the cached snapshot.
5. Views bind to `SessionHandler.gists` and render freshness state directly.

## Why `GistDocument` exists

The app used to pass `OctoKit.Gist` directly through the UI. That made offline support, testing, and search behavior hard to control. `GistDocument` is the app-owned representation of a gist, so the UI can reason about:

- cached vs fresh source
- loaded content
- visibility
- local search and diff summaries

## Save protection

Before saving edits, `CodeView` asks `SessionHandler` for a `GistSavePreview`. That preview combines:

- a local diff summary
- a remote conflict check against the last loaded content

This keeps save behavior safer than blindly overwriting the server copy.
