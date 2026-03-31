# Fragment Modernization Design

**Date:** 2026-03-30

**Goal:** Improve Fragment's product quality, repo quality, and AI readiness in one cohesive pass without changing its core identity as a native gist manager.

## Scope

This design covers ten aligned improvements:

1. Add a friendlier authentication onboarding experience.
2. Introduce offline-friendly gist caching with visible freshness state.
3. Improve desktop search and quick actions.
4. Add safer editing ergonomics for gist changes.
5. Split `SessionHandler` responsibilities into smaller units.
6. Expand automated tests around app logic.
7. Tighten CI and stop formatter/linter build phases from mutating source.
8. Repair documentation drift.
9. Add AI-oriented architecture and workflow docs.
10. Add contributor-facing roadmap and issue taxonomy guidance.

## Product Design

The authentication experience will shift from a bare token prompt to a small onboarding flow that explains what Fragment is, why it needs a GitHub token, which scope is required, and how the app handles storage. The token field remains, but supporting guidance becomes part of the primary experience instead of an escape hatch.

Fragment will show cached gists when available, mark whether the list is fresh or offline, and preserve cached content so the user can still inspect recent work without a network round trip. The UI will prefer truthfulness over pretending content is current.

Search will support both plain text and lightweight power-user filters like `ext:swift`, `visibility:public`, and `state:cached`. On macOS, primary actions like refresh, create gist, and focusing search will be available through commands and shortcuts.

The editor will warn before overwriting remote changes by comparing the loaded text against the latest fetched server version. Users will also get a simple diff summary before saving so edits feel intentional instead of blind.

## Architecture

`SessionHandler` remains the SwiftUI-facing observable object, but the implementation will delegate specific work to focused units:

- `AuthenticationService` for token validation and profile lookups
- `GistService` for network CRUD operations
- `GistCacheStore` for persisted gist snapshots
- `GistQuery` for search parsing and filtering
- `GistDocument` as the app-facing gist model that can represent both fresh and cached data

This keeps app state orchestration in one place while moving pure logic and storage concerns into smaller, testable files.

## Error Handling

Network failures should no longer collapse the whole experience into an empty screen. The app will:

- show cached results when refresh fails
- expose freshness state in the UI
- surface remote edit conflicts before overwrite
- keep alert messages readable and specific

## Testing Strategy

The new logic will be covered with unit tests around:

- query parsing and search filtering
- gist cache persistence
- conflict detection and diff summary helpers
- authentication/session state transitions where feasible

Build verification remains both iOS and macOS, with test workflows updated to modern GitHub Actions.

## Repo and AI Readiness

The repo will gain durable docs for architecture, testing, contributor workflow, roadmap, and issue taxonomy. README content will be updated to match reality so both humans and AI tools can trust the repo's entry points.
