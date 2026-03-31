# Testing Fragment

Fragment uses a mix of platform smoke tests and shared logic tests.

## What is covered today

- App boot smoke tests on iOS and macOS
- Shared logic tests for:
  - query parsing and filtering
  - cache persistence round-trips
  - diff/conflict summary behavior

## Commands

```bash
xcodebuild test -scheme macOS
xcodebuild test -scheme iOS -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```

## Verification expectations

When behavior changes:

- add or update a test first when the logic is testable without UI automation
- run at least the most relevant scheme while iterating
- run both platform builds before considering the work complete

## Current gaps

- No UI automation around onboarding or editing flows yet
- No dedicated tests for `SessionHandler` state transitions yet
- GitHub API behavior is still mostly verified through integration builds rather than mocked tests
