# Pare

A modern Flutter Android application built with the latest specifications.

## Features

- **Modern UI**: Built with Material 3 design system
- **State Management**: Uses Provider for efficient state management
- **Navigation**: Implements go_router for type-safe navigation
- **Responsive Design**: Optimized for different screen sizes
- **Clean Architecture**: Well-structured codebase following Flutter best practices

## Package Details

- **Package Name**: `ie.qqrxi.pare`
- **App Name**: Pare
- **Flutter Version**: 3.29.3+
- **Dart Version**: 3.7.2+

## Dependencies

### Core Packages
- `provider` - State management
- `go_router` - Navigation
- `http` & `dio` - HTTP client for API calls
- `shared_preferences` - Local storage
- `intl` - Internationalization

### Development
- `flutter_lints` - Code analysis and linting
- `flutter_test` - Testing framework

## Getting Started

### Prerequisites
- Flutter SDK 3.29.3 or higher
- Android Studio or VS Code with Flutter extension
- Android SDK for Android development

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building

To build a debug APK:
```bash
flutter build apk --debug
```

To build a release APK:
```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart           # Main app entry point and routing
├── screens/            # App screens (if expanded)
├── widgets/            # Reusable widgets (if expanded)
├── models/             # Data models (if expanded)
└── services/           # API and business logic (if expanded)
```

## Testing

Run tests with:
```bash
flutter test
```

Run code analysis:
```bash
flutter analyze
```

## Features Showcase

The app currently includes:

1. **Home Screen**: Welcome message with counter functionality
2. **Profile Screen**: User profile with contact information
3. **Navigation**: Seamless navigation between screens
4. **Material 3 Theming**: Modern design with proper color schemes
5. **Responsive Layout**: Adapts to different screen sizes

## Development

This project follows Flutter best practices:

- Material 3 design guidelines
- Provider for state management
- go_router for navigation
- Proper project structure
- Comprehensive testing
- Clean code principles

## License

This project is private and not intended for public distribution.
