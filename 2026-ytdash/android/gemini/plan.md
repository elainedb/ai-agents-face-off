# Implementation Plan — YouTube Dashboard ("ytdash")

**Date**: 2026-07-02 | **Framework**: Android (Jetpack Compose)

## Summary
Building a production-quality YouTube aggregation, caching, and mapping application. The app aggregates videos from multiple configured YouTube channels, caches them locally for offline access, allows sorting and filtering, and displays located videos on an OpenStreetMap (osmdroid) map.

## Technical Context
- **Language/Version**: Kotlin 2.x, JDK 17
- **Target Platform**: Android (minSdk 24, targetSdk 36, compileSdk 36)
- **UI Framework**: Jetpack Compose with Material 3 (declarative, reactive UI)
- **Navigation**: Simple state/backstack management
- **State Management**: MVVM with `ViewModel` and Kotlin `StateFlow` / unidirectional data flow
- **Networking**: OkHttp & `kotlinx.serialization` (for clean, lightweight HTTP requests and JSON parsing)
- **Local Cache**: Android `SharedPreferences` + `kotlinx.serialization` JSON storage (extremely robust, avoids DB lock/migration issues)
- **Map Library**: `osmdroid` (OpenStreetMap) integrated via Compose `AndroidView`
- **Testing**: Unit tests for sorting, filtering, and auth whitelist checks, and cache persistence tests

## Constitution Check
1. **Selector Contract (MANDATORY)**: Set `Modifier.semantics { testTagsAsResourceId = true }` on a high-level layout. All stable IDs (`screen_login`, `login_google_button`, `video_list`, `video_list_item`, etc.) will be applied exactly. To accommodate Compose's unmerged semantics tree, `video_list_item` will be attached directly to the video's title `Text` so Maestro can check text value on index-based items correctly, while still ensuring the parent remains clickable.
2. **UI Test Mode Contract**: The app reads launch intent extras (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`, `captureExternalLinks`) at startup via a `TestConfig` class. This overrides default API and auth flows cleanly.
3. **Map Marker Contract**: Since osmdroid draws pins on a Canvas that are unreachable by Maestro, we will provide a row of Compose `AssistChip`s overlaying the map (labeled with the video titles, tagged as `map_marker`) as native, accessible marker affordances. Tapping a marker (or chip) shows an inline Compose `Surface` bottom sheet (`detail_bottom_sheet`) overlaying the map with `detail_video_url` and `detail_open_youtube_button`.
4. **Offline Relaunch**: Data will be persisted to disk (via `SharedPreferences` using JSON) to survive relaunch. On network failure, we fall back to this cached data without showing a blocking error view.
5. **No Collisions in Dialogs/Panels**: Sorting and filtering panels will overlay and replace the video list while open, preventing text-matching collisions in Maestro.

## Project Structure
```text
app/src/main/java/com/example/ytdash/
├── MainActivity.kt         # Entry point, reads intent extras & sets up TestConfig
├── Navigation.kt           # Navigates between Login, Home (List), and Map screens
├── NavigationKeys.kt       # Navigation destination definitions
├── data/
│   ├── DataRepository.kt   # Video fetching (OkHttp), pagination, caching (SharedPreferences)
│   └── Model.kt            # Video data models (kotlinx.serialization)
├── ui/
│   ├── auth/               # Login screen & whitelist auth logic
│   ├── list/               # Video list screen, sort & filter controls
│   ├── map/                # osmdroid MapView and native accessible chip overlay
│   └── main/               # Shared VM or view states
└── theme/                  # Theme, Color, Type
```

## Compliance & Security
- **No hardcoded secrets**: API base URL and keys are configurable and retrieved from launch extras or secrets file at runtime.
- **Whitelist**: Local or remote list check, secure and strictly enforced.
