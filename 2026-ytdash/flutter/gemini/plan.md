# Implementation Plan: YouTube Dashboard

**Date**: 2026-07-04 | **Spec**: spec/spec.md

## Summary

Build a production-quality Android app in Flutter that signs users in with Google, fetches and displays a list of YouTube videos from a mocked/real API, allows filtering and sorting, and shows videos on a map.

## Technical Context

**Language/Version**: Dart 3 (Flutter)
**Primary Dependencies**:
- State: `flutter_bloc`
- Network/JSON: `http`, `json_annotation`
- DI: `get_it`
- Local Cache: `shared_preferences`
- Map: `flutter_map`, `latlong2`
- Auth: `google_sign_in`
- Utils: `url_launcher`, `cached_network_image`, `equatable`

**Testing**: E2E via Maestro
**Target Platform**: Android

## Constitution Check

- Stable selectors: Will use `Semantics(identifier: '...', child: ...)` for all asserted elements.
- UI Test Mode: Will implement MethodChannel to read launch intent extras.
- Map markers: Will use `Semantics(identifier: 'map_marker')` on flutter_map markers, and a fallback chip list.
- Cache: Will implement stale-fallback with shared_preferences.
- Filtering/Sorting: Will replace list with options panel.

## Project Structure

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/       # Test config and channels parsing
│   ├── di/           # Dependency injection
│   ├── error/        # Failure types
│   └── usecases/
├── features/
│   ├── auth/         # Login screen, Google Sign-in
│   ├── videos/       # List, Map, Filtering, Sorting
│   └── shared/       # Shared UI components
└── test_config.dart  # MethodChannel for UI Test Mode
```
