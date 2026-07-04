# Implementation Plan: YouTube Dashboard ("ytdash")

**Branch**: `main` | **Date**: 2026-07-04 | **Spec**: `spec/spec.md`

## Summary

A Flutter mobile app that signs a user in, shows a list of YouTube videos fetched from an API, caches them, lets the user filter/sort them, and plots the ones with a location on a map. We will use `flutter_bloc` for state management, `get_it` and `injectable` for dependency injection, `shared_preferences` for caching, and `flutter_map` for maps.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter SDK

**Primary Dependencies**: 
- UI/State: `flutter_bloc`, `equatable`, `url_launcher`
- DI: `get_it`, `injectable`, `injectable_generator`
- Network/Data: `http`, `shared_preferences`
- Functional: `dartz` (for Either/Failure)
- Map: `flutter_map`, `latlong2`
- Auth: `firebase_core`, `firebase_auth`, `google_sign_in`

**Storage**: `shared_preferences` (JSON string storage for 24h TTL cache)

**Testing**: Maestro flows (`flows/`) for UI testing.

**Target Platform**: Android (primary for flows)

**Project Type**: Mobile App

**Performance Goals**: Fast startup, smooth scrolling list, resilient to network failures.

**Constraints**: Must strictly adhere to the Selector contract, UI Test Mode contract, and Map markers contract defined in `spec/constitution.md`.

## Constitution Check

- **Layered separation**: Yes, UI/Presentation (Bloc/Widgets), Domain (Repositories/Entities), Data (API/Cache).
- **Dependency inversion**: Yes, using `get_it` and abstract interfaces.
- **Unidirectional, observable state**: Yes, `flutter_bloc` with explicit View States.
- **Single source of truth**: Local cache will serve UI, network will refresh cache.
- **Explicit error handling**: Sealed states for Error with retry buttons.

## Project Structure

### Documentation

```text
plan.md
tasks.md
```

### Source Code

```text
lib/
├── core/
│   ├── config/       # Constants, test config, channel config
│   ├── error/        # Failures
│   ├── di/           # Dependency injection setup
│   └── network/      # API client wrappers
├── data/
│   ├── models/       # DTOs
│   ├── datasources/  # Remote & Local data sources
│   └── repositories/ # Repository implementations
├── domain/
│   ├── entities/     # Business objects (Video, Channel)
│   ├── repositories/ # Repository interfaces
│   └── usecases/     # Use cases
└── presentation/
    ├── bloc/         # View models (AuthBloc, VideoListBloc)
    └── screens/      # UI, pages, widgets
```

**Structure Decision**: Clean Architecture with feature folders grouped by layer to maintain strict separation of concerns.

## Complexity Tracking

No significant violations of simple rules. Clean architecture adds some boilerplate but ensures testability and separation as required by the constitution.
