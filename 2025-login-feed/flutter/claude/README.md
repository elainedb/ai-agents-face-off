# flutter_claude

A Flutter app with Google Sign-In authentication that displays YouTube videos from specified channels.

## Features

- Google Sign-In authentication with authorized email control
- YouTube video feed from 4 specified channels
- Clean architecture with BLoC state management
- Secure configuration management
- Video thumbnail display with publication dates
- Launch videos in YouTube app or browser

## Setup

⚠️ **Important:** This project requires Firebase and YouTube API configuration files that are not included in the repository for security reasons.

### Prerequisites

- Flutter SDK
- Firebase project with Google Sign-In enabled
- YouTube Data API v3 key from Google Cloud Console

### Quick Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure authentication and API keys:**
   ```bash
   # Copy configuration templates for local development
   cp lib/config/auth_config.template.dart lib/config/auth_config.dart
   cp lib/config/config.template.dart lib/config/config.dart
   ```

3. **Customize configuration files:**

   **lib/config/auth_config.dart:**
   ```dart
   class AuthConfig {
     static const List<String> authorizedEmails = [
       'your-email@example.com',
       'another-email@example.com',
     ];
   }
   ```

   **lib/config/config.dart:**
   ```dart
   class Config {
     static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY_HERE';
   }
   ```

4. **Set up Firebase configuration files:** (See [Firebase Setup Guide](https://firebase.flutter.dev/docs/overview))
   - Add `android/app/google-services.json` for Android
   - Add `ios/Runner/GoogleService-Info.plist` for iOS

5. **Run the app:**
   ```bash
   flutter run
   ```

## Architecture

This project follows Clean Architecture principles:

- **Presentation Layer:** BLoC for state management, UI widgets
- **Domain Layer:** Business logic, entities, use cases
- **Data Layer:** Repository implementations, data sources

## Security

- Firebase configuration files (with API keys) are not committed to version control
- YouTube API keys are stored in secure config files (not committed)
- Authorized email lists are stored in secure config files (not committed)
- CI uses auto-generated safe defaults (empty authorized list, placeholder API key)
- Sensitive API keys and data are properly excluded from the repository

## CI/CD Setup

For CI/CD environments, run the configuration script before analysis:

```bash
dart scripts/ensure_config.dart
flutter analyze
flutter test
```

This script automatically creates safe placeholder configuration files when the actual config files are missing (like in CI environments).

## Getting YouTube API Key

1. Go to the [Google Cloud Console](https://console.developers.google.com/)
2. Create a new project or select an existing one
3. Enable the YouTube Data API v3
4. Go to Credentials and create an API key
5. Restrict the API key to YouTube Data API v3 (recommended)
6. Copy the API key to `lib/config/config.dart`