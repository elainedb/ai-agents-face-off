# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter app with Google Sign-In authentication that displays YouTube videos from specified channels. Features include video feed with filtering/sorting, local SQLite caching, and a map view showing video recording locations.

## Build & Run Commands

```bash
flutter pub get                    # Install dependencies
flutter analyze                    # Run static analysis
flutter test                       # Run all tests
flutter test test/path/to/file.dart  # Run single test file
flutter run                        # Run the app (requires Firebase config)
dart run build_runner build        # Regenerate freezed/injectable/json code
dart scripts/ensure_config.dart    # Generate placeholder configs for CI
```

## Configuration

Sensitive config files are gitignored. For local development, copy templates and fill in real values:
```bash
cp lib/config/auth_config.template.dart lib/config/auth_config.dart
cp lib/config/config.template.dart lib/config/config.dart
```
Also requires Firebase config files: `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.

For CI, run `dart scripts/ensure_config.dart` to generate safe placeholders.

## Architecture

Clean Architecture with three layers, organized by feature under `lib/features/`:

- **Domain** (`domain/`): Entities (freezed), repository interfaces, use cases. Use cases follow a common `UseCase<Type, Params>` interface from `lib/core/usecases/usecase.dart`. Return types use `Either<Failure, T>` from dartz.
- **Data** (`data/`): Repository implementations, remote/local data sources, freezed models with `toEntity()` conversion. Local caching uses SQLite (sqflite). Remote data comes from YouTube Data API v3.
- **Presentation** (`presentation/`): BLoC pattern for state management, pages/widgets. Events and states use freezed unions.

**Features:**
- `authentication/` — Firebase Auth + Google Sign-In with authorized email list
- `videos/` — YouTube video feed with channel/country filtering, sort by published/recording date, map view (flutter_map + OpenStreetMap), geocoding for video locations

### Key Patterns

- **Dependency Injection**: get_it + injectable. Registration is in `lib/di.dart` with generated config in `lib/di.config.dart`. Classes use `@injectable`, `@singleton`, or `@LazySingleton` annotations.
- **Code Generation**: freezed for immutable classes/unions, json_serializable for JSON, injectable_generator for DI. Run `dart run build_runner build` after modifying annotated classes.
- **Error Handling**: `Failure` (freezed union in `lib/core/error/failures.dart`) for domain errors, `ServerException`/`CacheException` for data layer. Repositories catch exceptions and return `Left(Failure)`.
- **Caching**: Videos are cached in SQLite with 24-hour TTL. Repository falls back to cache when remote fails.

## Testing

Flutter test framework. Tests live alongside source files or in `test/`. Run `flutter test` for all tests, `flutter test test/path/to/file.dart` for a single file.

## CI/CD

GitHub Actions: checkout → flutter pub get → analyze → test → SonarCloud scan. Runs on pushes to main and PRs.

## Key Dependencies

- flutter_bloc for state management
- freezed + json_serializable for code generation
- get_it + injectable for dependency injection
- sqflite for local database
- dartz for functional error handling
- flutter_map + latlong2 for maps (OpenStreetMap)
- firebase_auth + google_sign_in for authentication
- cached_network_image for image loading
