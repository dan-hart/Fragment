# Fragment Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernize Fragment's UX, architecture, tests, CI, and contributor documentation while keeping the app buildable on iOS and macOS.

**Architecture:** Keep `SessionHandler` as the observable coordinator, introduce focused helper units for auth, gist networking, caching, and search, and move UI behavior toward app-owned gist documents that can represent cached and fresh content. Update the app shell and docs around that model rather than rewriting the whole product.

**Tech Stack:** SwiftUI, Swift Concurrency, OctoKit, KeychainAccess, XCTest, GitHub Actions

---

### Task 1: Add tests for new pure app logic

**Files:**
- Create: `FragmentSharedTests/GistQueryTests.swift`
- Create: `FragmentSharedTests/GistCacheStoreTests.swift`
- Create: `FragmentSharedTests/GistDiffSummaryTests.swift`
- Modify: `Fragment.xcodeproj/project.pbxproj`

- [ ] Write failing tests for query parsing and filtering
- [ ] Run the shared test targets and confirm failure
- [ ] Write failing tests for cache round-trip persistence
- [ ] Run the tests and confirm failure
- [ ] Write failing tests for diff/conflict summary helpers
- [ ] Run the tests and confirm failure

### Task 2: Introduce focused gist and auth support types

**Files:**
- Create: `Shared/Models/GistDocument.swift`
- Create: `Shared/Services/AuthenticationService.swift`
- Create: `Shared/Services/GistService.swift`
- Create: `Shared/Services/GistCacheStore.swift`
- Create: `Shared/Services/GistQuery.swift`
- Create: `Shared/Services/GistDiffSummary.swift`
- Modify: `Fragment.xcodeproj/project.pbxproj`

- [ ] Implement the minimal types needed to satisfy the new tests
- [ ] Keep the public surface area small and app-specific
- [ ] Re-run focused tests after each type lands

### Task 3: Refactor session coordination and offline support

**Files:**
- Modify: `Shared/Handler/SessionHandler.swift`
- Modify: `Shared/Extensions/OctoKitExtensions/GistExtensions/Gist+Custom.swift`
- Modify: `Shared/Models/Errors/FragmentError.swift`

- [ ] Delegate auth/network/cache work out of `SessionHandler`
- [ ] Load cached gists on launch or refresh failure
- [ ] Expose freshness state and conflict-check support
- [ ] Re-run tests after refactor

### Task 4: Improve authentication, search, and editor UX

**Files:**
- Modify: `Shared/Views/MainView.swift`
- Modify: `Shared/Views/AuthenticationView.swift`
- Modify: `Shared/Views/Container/ContainerView.swift`
- Modify: `Shared/Views/Container/ListView.swift`
- Modify: `Shared/Views/CodeViews/CodeView.swift`
- Modify: `Shared/Views/Add/AddGistView.swift`
- Modify: `Shared/Views/GistViews/GistRow.swift`
- Modify: `Shared/Views/SettingsView.swift`
- Modify: `Shared/FragmentApp.swift`
- Modify: `Shared/Constants.swift`

- [ ] Add onboarding content around token setup
- [ ] Add cache/freshness messaging in list UI
- [ ] Add power search filters and macOS quick actions
- [ ] Add diff/conflict protection in the editor
- [ ] Improve add-gist filename/language ergonomics

### Task 5: Modernize repo workflows and docs

**Files:**
- Modify: `.github/workflows/iOS-test.yml`
- Modify: `.github/workflows/macOS-test.yml`
- Add: `.github/workflows/ci.yml`
- Add: `.github/ISSUE_TEMPLATE/bug_report.md`
- Add: `.github/ISSUE_TEMPLATE/config.yml`
- Add: `CONTRIBUTING.md`
- Modify: `README.md`
- Add: `docs/architecture.md`
- Add: `docs/testing.md`
- Add: `docs/ai-readiness.md`
- Add: `docs/roadmap.md`
- Add: `docs/decisions/2026-03-30-modernization.md`

- [ ] Replace outdated CI patterns with maintained Actions
- [ ] Document labels, issue categories, and contributor expectations
- [ ] Bring README in sync with actual dependencies and workflows
- [ ] Add explicit architecture and AI-context documents

### Task 6: Full verification

**Files:**
- Modify as needed based on verification results

- [ ] Run shared and platform test suites
- [ ] Run `xcodebuild -scheme macOS -configuration Debug build`
- [ ] Run `xcodebuild -scheme iOS -configuration Debug build`
- [ ] Review diffs for accidental formatter mutations or unrelated churn
