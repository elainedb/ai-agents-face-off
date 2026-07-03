# Implementation Plan: YouTube Dashboard ("ytdash")

**Date**: 2026-07-03 | **Spec**: [spec/spec.md](file:///tmp/ytrun.EzHAxn/workspace/spec/spec.md)

## Summary
The goal is to build a production-quality Android app using Flutter that aggregates YouTube videos from multiple channels, persists them locally (offline cache), supports filtering and sorting, provides secure Google Sign-In (with email whitelist validation), and displays videos with location markers on an OpenStreetMap interface. It includes a comprehensive UI-test-mode driven by launch intent extras to facilitate fully automated, deterministic Maestro flows.

## Technical Context

- **Language/Version**: Dart 3.10.1, Flutter 3.38.3
- **Primary Dependencies**:
  - `http` for API requests.
  - `shared_preferences` for reliable disk-based cache persistence.
  - `flutter_map` + `latlong2` for the OpenStreetMap visualizer.
  - `google_sign_in` for real Google Sign-In authentication.
- **Storage**: `shared_preferences` storing aggregated videos as a serialized JSON string.
- **Testing**: `flutter_test` for domain layer unit tests (whitelist, sorting, filtering, caching).
- **Target Platform**: Android, minSdk 29, compileSdk 36.
- **Performance Goals**: 60 FPS UI rendering, under 100ms processing overhead for sorting/filtering.
- **Constraints**: Off-main-thread API fetching, offline resilience, stable semantics identifier contract.

## Constitution Check

- **A. Stable selector**: Wrap interactive/asserted widgets with `Semantics(identifier: 'logical_id', child: ...)` as per §3 and §A of cross-framework-setup.md. Ensure `SemanticsBinding.instance.ensureSemantics()` is called in `main()` so the semantic tree is built for Maestro.
- **B. Read launch args**: Read Android intent extras via a MethodChannel `ytdash/testconfig` at startup. This enables dynamic override of `uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`, and `captureExternalLinks`.
- **C. Accessible markers**: Wrap our `flutter_map` markers with `Semantics(identifier: 'map_marker')` and provide a horizontal scrollable chip overlay as an accessible native alternative in the main view tree. This ensures E2E tests can interact with markers under all conditions.
- **D. Popups and overlays**: `detail_bottom_sheet` is built as an inline alignment overlay/slide-sheet within the main tree (not as a separate route/window) to ensure its test IDs remain perfectly reachable.

## Project Structure

```text
lib/
├── main.dart             # App Entry Point & Routing
├── models/
│   └── video.dart        # Video Data Model and JSON Parsing
├── services/
│   ├── auth_service.dart # Auth Management & Whitelist logic
│   ├── api_service.dart  # YouTube API Fetching with Pagination
│   └── cache_service.dart# Local persistence cache
└── screens/
    ├── login_screen.dart # Login Screen
    ├── home_screen.dart  # Video List & Control Screen
    └── map_screen.dart   # OSM map with interactive pins and sheet
```

## State Management Decision
We choose the built-in, lightweight, and robust `ChangeNotifier` and `ValueNotifier` pattern combined with `AnimatedBuilder`/`ListenableBuilder`. This is highly idiomatic, compile-safe, and introduces zero dependency-induced breakages or build runner dependencies, keeping the implementation simple and clean.
