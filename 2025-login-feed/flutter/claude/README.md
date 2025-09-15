# flutter_claude

A Flutter app with Google Sign-In authentication and authorized user access control.

## Features

- Google Sign-In authentication
- Authorized email list control
- Clean architecture with BLoC state management
- Secure configuration management

## Setup

⚠️ **Important:** This project requires Firebase configuration files that are not included in the repository for security reasons.

Please follow the [Firebase Setup Guide](FIREBASE_SETUP.md) to configure the app before running.

### Quick Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase:** (See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions)
   ```bash
   # Copy configuration templates for local development
   cp lib/config/auth_config.template.dart lib/config/auth_config.dart
   cp android/app/google-services.json.template android/app/google-services.json
   cp ios/Runner/GoogleService-Info.plist.template ios/Runner/GoogleService-Info.plist
   ```

3. **Customize configuration files with your Firebase project settings**

4. **Run the app:**
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
- Authorized email lists are stored in secure config files (not committed)
- CI uses auto-generated safe defaults (empty authorized list)
- Sensitive API keys and data are properly excluded from the repository

## CI/CD Setup

For CI/CD environments, run the setup script before analysis:

```bash
./scripts/setup_ci.sh
flutter analyze
```