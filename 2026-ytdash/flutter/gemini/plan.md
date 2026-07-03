# Implementation Plan: ytdash_flutter

**Date**: 2026-07-03 | **Spec**: spec/spec.md, spec/constitution.md, spec/acceptance-criteria.md

## Summary
The goal is to build a production-quality, robust Flutter application for Android that aggregates, caches, filters, sorts, and displays YouTube videos from configured channels, with map visualization of geolocated videos. It adheres strictly to stable selector and UI test mode contracts to allow black-box end-to-end automation via Maestro.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter 3.19+

**Primary Dependencies**:
- `http: ^1.2.0` (standard networking)
- `shared_preferences: ^2.2.0` (simple disk persistence for video list cache)
- `flutter_map: ^6.1.0` (interactive OSM widget)
- `latlong2: ^0.9.0` (coordinate handling for flutter_map)
- `url_launcher: ^6.2.0` (external app and deep-link launching)

**Storage**: `shared_preferences` storing serialized JSON of aggregated videos. This satisfies the process relaunch offline cache requirement (AC-CACHE-01) while being extremely reliable, lightweight, and fast on all Android emulators, avoiding heavy native SQLite compilation overheads or locks.

**Testing**: `flutter_test` for unit testing of auth whitelist logic, sorting, filtering, and cache read/write.

**Target Platform**: Android (applicationId: `com.example.ytdash_flutter`)

**Project Type**: Mobile App

**Performance Goals**: 60 FPS, smooth list scrolling, asynchronous background parsing of network responses, and caching to avoid repeated expensive YouTube API search quota hits.

**Constraints**:
- Offline-capable (must serve stale cached content on network error).
- Exact semantic element matching for Maestro (Semantics identifiers).
- Fully overridable runtime configuration via launch intent extras (API base, whitelist override, capture-links flag).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Selector contract (§3)**: Exposed via Flutter `Semantics(identifier: '...', child: ...)` on all required interactive/asserted widgets, rather than localized labels. SemanticsBinding.instance.ensureSemantics() will be initialized in main().
- [x] **UI Test Mode contract (§4)**: Handled by custom Kotlin MethodChannel in `MainActivity.kt` reading Android launch intent extras, passing them to the Dart app layer at startup.
- [x] **Map markers (§5)**: Since `flutter_map` renders markers as real widgets, we wrap them in `Semantics(identifier: 'map_marker')` to make them reachable by Maestro. To satisfy parity and robustness, we also render an accessible, horizontal overlay list of map chips (labeled with `map_marker`) so pins can be activated even if scrolled out of the map viewport.
- [x] **Overlay / popup reachability (§5a)**: Dialogs, sheets, and menus in Flutter remain in the main semantics tree, but we will explicitly tag elements inside overlays (e.g. logout in menus, bottom sheet elements) with correct stable IDs.
- [x] **Clean architecture (§1)**: Strictly separates Data/Services, Repositories, ViewModels, and Views. No network/disk work on the UI thread, unified error handling with retries, and single-source-of-truth from the local cache.

## Project Structure

### Documentation (this feature)
```text
spec/
├── constitution.md
├── spec.md
├── acceptance-criteria.md
├── cross-framework-setup.md
└── youtube-api.md
```

### Source Code (repository root)
```text
lib/
├── main.dart             # App initialization & MethodChannel setup
├── data/
│   ├── models/           # API and local representation of YouTube data
│   │   ├── video.dart
│   │   ├── channel.dart
│   │   └── test_config.dart
│   ├── services/         # Client services
│   │   ├── youtube_service.dart
│   │   ├── cache_service.dart
│   │   └── geocoding_service.dart
│   └── repositories/     # Domain data access (caching, merging)
│       └── video_repository.dart
├── ui/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── view_models/auth_view_model.dart
│   │   │   └── views/login_screen.dart
│   │   ├── home/
│   │   │   ├── view_models/video_view_model.dart
│   │   │   └── views/home_screen.dart
│   │   └── map/
│   │       └── views/map_screen.dart
│   └── shared/           # Common components, styling, helpers
│       ├── theme.dart
│       └── widgets/
```

**Structure Decision**: A clean hybrid approach is selected. Source files are separated into `data` (models, services, repositories) and `ui` (features divided by user stories/screens and shared elements), as recommended in the architectural best practices skill.
