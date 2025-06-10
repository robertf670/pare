# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive Product Requirements Document (PRD.md)
- Dark theme color scheme implementation based on PRD specifications
- In-app version control system planning and architecture
- User personas and functional requirements documentation

### Changed
- Updated app theme to use dark color palette as primary theme
- Forced dark theme mode for consistent user experience
- Preparing for GitHub CI/CD integration

## [1.0.0+1] - 2025-10-06

### Added
- Initial release of Pare Flutter application
- Modern Material 3 UI design system
- Home screen with welcome message and counter functionality
- Profile screen with user information display
- State management using Provider package
- Navigation system using go_router
- Responsive design with SingleChildScrollView layout
- Support for both light and dark themes
- Comprehensive test suite with widget tests
- HTTP client support with both http and dio packages
- Local storage capabilities with shared_preferences
- Internationalization support with intl package
- Android platform support with proper namespace configuration
- Package namespace: `ie.qqrxi.pare`
- Clean architecture following Flutter best practices
- Comprehensive documentation in README.md
- Proper linting and code analysis configuration

### Technical Details
- Flutter SDK: 3.29.3
- Dart SDK: 3.7.2
- Material Design: Version 3
- Target Platform: Android
- Minimum SDK: As per Flutter defaults
- Target SDK: As per Flutter defaults

### Dependencies
- provider: ^6.1.2 (State management)
- go_router: ^14.1.4 (Navigation)
- http: ^1.2.1 (HTTP client)
- dio: ^5.4.3+1 (Advanced HTTP client)
- shared_preferences: ^2.2.2 (Local storage)
- intl: ^0.19.0 (Internationalization)
- cupertino_icons: ^1.0.8 (iOS-style icons)

### Development Dependencies
- flutter_test: SDK (Testing framework)
- flutter_lints: ^5.0.0 (Code analysis)

### Quality Assurance
- All tests passing
- Zero linting issues
- Successful APK build verification
- Cross-platform responsive design tested

---

## Versioning Strategy

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backwards compatible manner
- **PATCH** version when you make backwards compatible bug fixes

For Flutter apps, we also include a build number using the format: `MAJOR.MINOR.PATCH+BUILD`

## Release Process

1. Update version in `pubspec.yaml`
2. Update this CHANGELOG.md with new changes
3. Create a new git tag with the version number
4. Push changes and tags to GitHub
5. GitHub Actions will handle the CI/CD process (when implemented)

## Contributing

When contributing to this project:

1. Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
2. Update the CHANGELOG.md under the `[Unreleased]` section
3. Ensure all tests pass and linting is clean
4. Update version numbers appropriately

### Commit Message Convention

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for formatting changes
- `refactor:` for code refactoring
- `test:` for adding or updating tests
- `chore:` for maintenance tasks 