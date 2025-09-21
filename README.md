# Fragment

[![GitHub issues](https://img.shields.io/github/issues/dan-hart/Fragment)](https://github.com/dan-hart/Fragment/issues)
[![GitHub forks](https://img.shields.io/github/forks/dan-hart/Fragment)](https://github.com/dan-hart/Fragment/network)
[![GitHub stars](https://img.shields.io/github/stars/dan-hart/Fragment)](https://github.com/dan-hart/Fragment/stargazers)
[![GitHub license](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://github.com/dan-hart/Fragment/blob/main/LICENSE.md)
[![Maintainability](https://api.codeclimate.com/v1/badges/abb6d83c6dafb22f3bef/maintainability)](https://codeclimate.com/github/dan-hart/Fragment/maintainability)
[![ios tests](https://github.com/dan-hart/Fragment/actions/workflows/iOS-test.yml/badge.svg)](https://github.com/dan-hart/Fragment/actions/workflows/iOS-test.yml)
[![macOS tests](https://github.com/dan-hart/Fragment/actions/workflows/macOS-test.yml/badge.svg)](https://github.com/dan-hart/Fragment/actions/workflows/macOS-test.yml)
[![CodeFactor](https://www.codefactor.io/repository/github/dan-hart/fragment/badge)](https://www.codefactor.io/repository/github/dan-hart/fragment)
[![Swift 6.2](https://img.shields.io/badge/swift-6.2-orange.svg)](https://swift.org/)
[![iOS 26.0+](https://img.shields.io/badge/iOS-26.0+-blue.svg)](https://developer.apple.com/ios/)
[![macOS 26.0+](https://img.shields.io/badge/macOS-26.0+-blue.svg)](https://developer.apple.com/macos/)

A modern, native iOS and macOS application for managing GitHub Gists with advanced code editing capabilities.

![Fragment App Screenshot](https://user-images.githubusercontent.com/13913605/161664604-ead728bc-cac4-4a39-914c-147e1af2399f.png)

## Features

- 🔐 **Secure GitHub Authentication** - Uses GitHub Personal Access Tokens stored securely in Keychain
- 📝 **Advanced Code Editing** - Syntax highlighting for 100+ programming languages
- 🎨 **Theme Support** - Dark and light mode support with beautiful code themes
- 🔍 **Search & Filter** - Quickly find gists by name, description, or file extension
- ✏️ **Gist Management** - Create, edit, and update gists directly from the app
- 🔄 **Real-time Sync** - Automatic synchronization with your GitHub account
- 📱 **Universal App** - Native support for iPhone, iPad, and Mac
- 🌐 **Web Integration** - Open gists in browser with one click

## Requirements

- **iOS 26.0+** or **macOS 26.0+**
- **Xcode 16.0+** with Swift 6.2
- GitHub Personal Access Token with gist permissions

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/dan-hart/Fragment.git
   cd Fragment
   ```

2. Open `Fragment.xcodeproj` in Xcode

3. Select your target device/simulator

4. Build and run (⌘R)

### GitHub Personal Access Token Setup

1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Give it a name like "Fragment App"
4. Select the `gist` scope
5. Copy the generated token
6. Launch Fragment and paste the token when prompted

## Architecture

Fragment is built using modern iOS/macOS development practices:

- **SwiftUI** - Declarative UI framework
- **Swift Concurrency** - Modern async/await patterns with proper actor isolation
- **MVVM Architecture** - Clean separation of concerns
- **Swift Package Manager** - Dependency management

### Key Components

- `SessionHandler` - Manages GitHub authentication and API calls
- `FragmentApp` - Main app entry point with proper SwiftUI lifecycle
- `MainView` - Primary navigation using NavigationStack
- `CodeView` - Advanced code editor with syntax highlighting
- `GistRow` - Reusable gist list item component

## Dependencies

Fragment uses the following Swift packages:

- [**OctoKit**](https://github.com/nerdishbynature/octokit.swift) - GitHub API integration
- [**KeychainAccess**](https://github.com/kishikawakatsumi/KeychainAccess) - Secure token storage
- [**CodeEditor**](https://github.com/ZeeZide/CodeEditor) - Code editing with syntax highlighting
- [**Highlightr**](https://github.com/raspu/Highlightr) - Syntax highlighting engine
- [**SFSafeSymbols**](https://github.com/SFSafeSymbols/SFSafeSymbols) - Type-safe SF Symbols
- [**SwifterSwift**](https://github.com/SwifterSwift/SwifterSwift) - Swift extensions
- [**DHCacheKit**](https://github.com/dan-hart/DHCacheKit) - Local caching utilities

## Development

### Project Structure

```
Fragment/
├── Shared/                    # Shared code for iOS/macOS
│   ├── FragmentApp.swift     # App entry point
│   ├── Models/               # Data models
│   ├── Views/                # SwiftUI views
│   ├── Handler/              # Business logic
│   └── Extensions/           # Swift extensions
├── Fragment-iOS-Tests/        # iOS unit tests
├── Fragment-macOS-Tests/      # macOS unit tests
└── FragmentSharedTests/       # Shared test code
```

### Code Quality

Fragment maintains high code quality standards:

- **SwiftLint** - Automatic linting with custom rules
- **SwiftFormat** - Consistent code formatting
- **Unit Tests** - Comprehensive test coverage
- **Swift 6 Compliance** - Modern concurrency and sendable conformance

### Building

```bash
# Build for iOS
xcodebuild -project Fragment.xcodeproj -scheme iOS -destination "platform=iOS Simulator,name=iPhone 16 Pro" build

# Build for macOS
xcodebuild -project Fragment.xcodeproj -scheme macOS build

# Run tests
xcodebuild test -project Fragment.xcodeproj -scheme iOS -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```

## Contributing

We welcome contributions! Please see our [Code of Conduct](CODE_OF_CONDUCT.md) and follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes following our coding standards
4. Run tests: `xcodebuild test`
5. Run linting: `swiftlint`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to the branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Development Guidelines

- Follow Swift naming conventions
- Write unit tests for new features
- Ensure SwiftLint passes
- Update documentation as needed
- Maintain Swift 6 compatibility

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE.md](LICENSE.md) file for details.

### GPLv3 License Summary

Fragment is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This ensures that the software remains free and open source for everyone.

## Support

- 🐛 [Report bugs](https://github.com/dan-hart/Fragment/issues)
- 💡 [Request features](https://github.com/dan-hart/Fragment/issues)
- 📖 [Documentation](https://github.com/dan-hart/Fragment/wiki)
- ☕ [Buy me a coffee](https://www.buymeacoffee.com/codedbydan)

## Acknowledgments

- GitHub for their excellent Gist API
- The Swift community for amazing open source packages
- Apple for SwiftUI and modern development tools

---

Made with ❤️ by [Dan Hart](https://github.com/dan-hart)
