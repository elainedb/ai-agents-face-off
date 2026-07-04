# Implementation Plan: YouTube Dashboard (ytdash)

**Branch**: `main` | **Date**: 2026-07-03 | **Spec**: `spec/spec.md`

## Summary

Build a production-quality Android app that signs a user in via Google, fetches YouTube videos from a mock/real API across configured channels, caches them locally, allows filtering/sorting, and displays located videos on a map.

## Technical Context

**Language/Version**: Kotlin 2.x, JDK 17, Android compileSdk 36

**Primary Dependencies**:
- UI: Jetpack Compose (Material3)
- Navigation: Jetpack Navigation Compose
- State/Architecture: MVVM + ViewModel + StateFlow
- DI: Manual Dependency Injection (AppContainer)
- Networking: Retrofit + OkHttp + kotlinx.serialization
- Persistence (Cache): SharedPreferences with JSON serialization (simplest robust offline store)
- Maps: osmdroid via `AndroidView`
- Auth: Google Sign-In (`play-services-auth`)

**Testing**: JUnit + Coroutines Test (Domain logic), Maestro (UI E2E, already provided in `flows/`)

**Target Platform**: Android MinSDK 24, TargetSDK 36

**Project Type**: Mobile Application

## Constitution Check

- **Layered Separation**: Data (Network + Cache), Domain (Auth whitelist, Sort, Filter), Presentation (Compose MVVM).
- **Dependency Inversion**: Repositories defined as interfaces (e.g. `VideoRepository`), injected via manual DI (AppContainer).
- **Unidirectional State**: `UiState` sealed classes for screens (Loading/Content/Empty/Error).
- **No blocking UI**: Network/Disk on Dispatchers.IO.
- **Single Source of Truth**: Cache is the single source of truth; Network updates cache.
- **Explicit Errors**: All errors surfaced to UI with Retry.
- **Test IDs Contract**: `testTagsAsResourceId = true` on root. All interactive elements use `Modifier.testTag`. `DropdownMenu`/`ModalBottomSheet` roots will have `testTagsAsResourceId = true` reapplied.
- **UI Test Mode Contract**: Read `intent.extras` in `MainActivity` at launch for `uiTestMode`, `apiBaseUrl`, `mockAuthEmail`, etc.
- **Map Markers Fallback**: osmdroid pins are unreachable by Maestro. A row of `AssistChip` natively accessible markers will overlay the map.

## Project Structure

```text
src/main/
├── AndroidManifest.xml
└── java/com/example/ytdash/
    ├── MainActivity.kt           # Intent extra parsing, Test config, Root Nav
    ├── AppContainer.kt           # Manual DI Container
    ├── data/
    │   ├── api/                  # Retrofit API interface + models
    │   ├── cache/                # SharedPreferences cache
    │   └── repository/           # Repository implementations
    ├── domain/
    │   ├── models/               # Domain models (Video, Channel, etc)
    │   ├── auth/                 # Whitelist logic
    │   └── usecase/              # Sort/Filter logic
    └── ui/
        ├── theme/                # Compose theme
        ├── common/               # Reusable components (ErrorView, Loading)
        ├── login/                # Login screen
        ├── home/                 # List, Sort, Filter
        └── map/                  # osmdroid map + detail bottom sheet
```
