# Implementation Plan: YouTube Dashboard ("ytdash")

**Branch**: `main` | **Date**: 2026-06-30 | **Spec**: `spec/spec.md`

## Summary
The goal is to build a production-quality Flutter Android application that aggregates, caches, filters, and sorts YouTube videos from configured channels, and plots geolocated videos on an OpenStreetMap. The app will feature robust Google Sign-In with an email whitelist, handle network failures gracefully using persistent caching, and support an automated UI test mode with precise semantic identifiers for Maestro flow validation.

## Technical Context

**Language/Version**: Dart ^3.10.1 / Flutter 3.38.3

**Primary Dependencies**:
- `http: ^1.2.0` (REST requests to YouTube API and Nominatim geocoding)
- `shared_preferences: ^2.2.3` (Local persistent JSON cache of video list & authentication session)
- `flutter_map: ^6.1.0` (OpenStreetMap integration)
- `latlong2: ^0.9.0` (Coordinate types for flutter_map)
- `provider: ^6.1.1` (State management and Dependency Injection)
- `google_sign_in: ^6.2.1` (OAuth2 Google identity provider)
- `url_launcher: ^6.2.5` (Deep-linking to open YouTube externally)

**Storage**: Persistent JSON caching inside `shared_preferences`.

**Testing**: Dart unit tests for domain logic (sorting, filtering, whitelisting) and local storage integration.

**Target Platform**: Android (specifically tested on device `25251FDF60029V`).

**Project Type**: Mobile Application (Flutter/Android).

**Performance Goals**: Sub-100ms UI responsiveness, smooth rendering of OpenStreetMap with markers, and efficient API data aggregation.

**Constraints**:
- Must follow the exact **selector contract** and **UI test mode contract** in `spec/constitution.md`.
- No hardcoded API keys or base URLs.
- Robust error handling with retry triggers for all HTTP/network failures.
- Non-blocking stale-cache fallback on relaunch when offline.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Layered Separation**: Separated into Data Layer (API Client, Repository, Preferences), Domain Layer (Models, Logic), and Presentation Layer (MVVM: ViewModels and Views).
- **Dependency Inversion**: Models and ViewModels depend on repository and client abstractions. ViewModels are injected with repositories via constructors using `provider`.
- **Unidirectional, Observable State**: State in ViewModels is modeled as clear status sealed-like states (`Loading`, `Content`, `Empty`, `Error`). Views listen to state changes and rebuild dynamically.
- **No Blocking Work on UI Thread**: Asynchronous operations are executed using Dart's async/await, moving JSON and HTTP processing off the main event loop if large (or simple asynchronous non-blocking futures).
- **Single Source of Truth**: The Local Cache repository acts as the single source of truth; when the network succeeds, it writes to cache; on offline relaunch, the UI reads directly from the cache.
- **Explicit Error Handling**: Checked. Network, geocoding, and authentication failures result in clean user-facing error overlays with retry actions.
- **Selector & UI Test Mode Contract**: Fully mapped out. We read launch intent extras via a platform `MethodChannel` from `MainActivity.kt` and propagate them at startup.

## Project Structure

### Source Code

```text
lib/
├── data/
│   ├── models/                # JSON serializers and raw API models
│   ├── repositories/          # YoutubeRepository, PreferenceRepository
│   └── services/              # YoutubeApiClient, GeocodingService
├── domain/
│   └── models/                # Immutable domain model (Video)
├── ui/
│   ├── core/                  # Design system tokens, styles, theme, and common components
│   └── features/
│       ├── auth/              # Login screen, AuthViewModel
│       ├── dashboard/         # Video list, Filter/Sort panels, DashboardViewModel
│       └── map/               # OpenStreetMap, Marker overlay, MapViewModel
└── main.dart                  # Application bootstrap & dependency injection
```

**Structure Decision**:
Following the `flutter-apply-architecture-best-practices` skill, we use the MVVM pattern with a feature-focused UI folder structure, and a global Data layer.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Platform `MethodChannel` | To read Android intent extras at runtime for Maestro launch parameters. | `--dart-define` is compile-time only and cannot support dynamic per-run overrides. |
| Dual-Marker Layer (OSM + Native chips) | To allow Maestro to easily tap markers and prevent view-port scrolling issues. | Canvas/WebView pins are invisible to black-box accessibility scanners. |
| In-Panel filter/sort view | Replacing list view with filter/sort selectors prevents item title text collisions. | Overlay modals can cause Maestro regex text matches to hit background list rows. |
