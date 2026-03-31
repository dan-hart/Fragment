# Contributing to Fragment

Thanks for helping improve Fragment.

## Local workflow

1. Create a branch from `develop`.
2. Make focused changes with tests where behavior changes.
3. Verify both platforms before opening a PR:

```bash
xcodebuild -scheme macOS -configuration Debug build
xcodebuild test -scheme macOS
xcodebuild -scheme iOS -configuration Debug build
xcodebuild test -scheme iOS -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```

4. Keep SwiftLint and SwiftFormat clean. The Xcode build phases now run in lint-only mode; they should not rewrite tracked files.

## Issue taxonomy

Use these labels as the default taxonomy for issues and planning:

- `bug`: Something that is broken or regressed
- `enhancement`: A user-visible improvement
- `tech-debt`: Internal cleanup or architecture work
- `testing`: Missing or improved verification
- `docs`: Documentation drift or missing docs
- `ai-ready`: Improvements that make the repo easier for AI-assisted work
- `good first issue`: Small, well-scoped contributor work
- `help wanted`: Valuable work that is open for contribution

## Pull request expectations

- Keep PRs scoped to one theme when possible.
- Explain the user-facing impact, not just the file list.
- Call out verification results explicitly.
- Mention any follow-up work or known gaps.

## Repo docs

- [README](README.md): project overview and quick start
- [Architecture](docs/architecture.md): app structure and data flow
- [Testing](docs/testing.md): verification strategy
- [AI readiness](docs/ai-readiness.md): context for AI-assisted changes
- [Roadmap](docs/roadmap.md): near-term priorities
