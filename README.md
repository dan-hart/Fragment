# Fragment

A native iOS and macOS app for managing GitHub Gists with a code-focused editor, offline-friendly cache, and shared SwiftUI codebase.

## Highlights

- Native SwiftUI app for iOS and macOS
- GitHub gist authentication via personal access token stored in Keychain
- Local cached gist browsing when GitHub is unavailable
- Search with power-user filters like `ext:swift`, `visibility:public`, and `state:cached`
- Save review flow with diff summaries and remote conflict checks
- Shared logic tests for caching, search, and diff behavior

## Requirements

- iOS 26.0+ or macOS 26.0+
- Xcode 26.0+
- A GitHub personal access token with the `gist` scope

## Build

```bash
xcodebuild -scheme macOS -configuration Debug build
xcodebuild -scheme iOS -configuration Debug build
```

## Test

```bash
xcodebuild test -scheme macOS
xcodebuild test -scheme iOS -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```

## Architecture

The app uses a shared SwiftUI codebase with a small coordinator/service split:

- `SessionHandler` coordinates app state
- `GistDocument` is the app-owned gist model
- `AuthenticationService` and `GistService` wrap GitHub API work
- `GistCacheStore` handles the offline snapshot

Start with [docs/architecture.md](docs/architecture.md) for more detail.

## Repo guide

- [Contributing](CONTRIBUTING.md)
- [Architecture](docs/architecture.md)
- [Testing](docs/testing.md)
- [AI readiness](docs/ai-readiness.md)
- [Roadmap](docs/roadmap.md)

## Dependencies

- [OctoKit](https://github.com/nerdishbynature/octokit.swift)
- [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)
- [CodeEditor](https://github.com/ZeeZide/CodeEditor)
- [Highlightr](https://github.com/raspu/Highlightr)
- [SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols)
- [DHCacheKit](https://github.com/dan-hart/DHCacheKit)

`SwifterSwift` is no longer used in this repo.

## Support

- [Report bugs](https://github.com/dan-hart/Fragment/issues)
- [Request features](https://github.com/dan-hart/Fragment/issues)
- [Project roadmap](docs/roadmap.md)
- [Buy me a coffee](https://www.buymeacoffee.com/codedbydan)
