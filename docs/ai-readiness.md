# AI Readiness

This repo is increasingly optimized for reliable AI-assisted edits.

## Best entry points

- Start with [README](../README.md) for setup and scope.
- Read [architecture](architecture.md) before touching session or gist flow.
- Read [testing](testing.md) before changing behavior.

## Stable concepts

- `SessionHandler` is the observable coordinator, not the low-level network client.
- `GistDocument` is the UI-facing gist model.
- `AuthenticationService` and `GistService` wrap OctoKit interactions.
- `GistCacheStore` owns offline gist persistence.
- `GistQuery` and `GistDiffSummary` contain testable logic that should stay pure.

## Editing guidance

- Prefer adding new behavior in the pure support types before expanding SwiftUI views.
- Treat build scripts as lint checks, not auto-fix steps.
- Verify both iOS and macOS builds after meaningful changes.
- Preserve the shared code model unless a platform-specific divergence is clearly needed.

## Useful commands

```bash
git status --short --branch
xcodebuild -scheme macOS -configuration Debug build
xcodebuild -scheme iOS -configuration Debug build
xcodebuild test -scheme macOS
xcodebuild test -scheme iOS -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```
