# Decision: March 30, 2026 modernization pass

## Context

Fragment built successfully, but the repo had several trust and maintenance issues:

- build phases rewrote tracked files
- tests barely covered app behavior
- the UI relied on raw `OctoKit.Gist` values
- onboarding and offline behavior were thin
- docs had drifted from the actual codebase

## Decision

Introduce a lightweight app-owned gist model (`GistDocument`), split session support into focused files, switch build phases to lint-only checks, and add repo documentation for contributors and AI tools.

## Consequences

- The UI can now represent cached and fresh gist state explicitly.
- Shared logic is easier to test.
- Local verification is less surprising because builds stop mutating source.
- The repo has clearer contributor and architecture docs.
