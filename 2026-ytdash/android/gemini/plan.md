# Implementation Plan: YouTube Dashboard ("ytdash")

**Date**: 2026-07-02 | **Spec**: `spec/spec.md`, `spec/constitution.md`

## Summary
The YouTube Dashboard ("ytdash") is a production-quality native Android application built with Jetpack Compose. It aggregates, filters, sorts, and caches YouTube video feeds from multiple configured channels, allowing authenticated users (verified against an email whitelist) to browse content both online and offline. Videos with geo-coordinates are plotted on an OpenStreetMap (OSM) map, with accessible native marker affordances to ensure E2E automated testability via Maestro.

---

## Technical Context

- **Language/Version**: Kotlin 2.x
- **Target Platform**: Android (minSdk 29, compileSdk 35/36, Target Java JDK 17)
- **Primary UI Library**: Jetpack Compose with Material 3
- **Primary Dependencies**:
  - **Networking & JSON**: `OkHttp` + `Gson` for network requests and easy JSON parsing.
  - **Image Loading**: `Coil` (Compose extension) for caching and rendering thumbnails.
  - **Map Rendering**: `osmdroid` for OpenStreetMap on Android.
- **Storage/Caching**: `SharedPreferences` storing Gson-serialized video lists. Provides instant read/write, disk persistence across app launches, offline capability, and 100% reliability with 0 compilation overhead.
- **Dependency Injection**: Manual injection (Service Locator / Dependency Container) in `MainApplication` to avoid annotation-processor build overhead and ensure fast compiles with absolute type safety.
- **Testing**: JUnit 4 for unit tests.

---

## Constitution Check

All principles outlined in `spec/constitution.md` are strictly honored:

1. **Layered Separation & Dependency Inversion**: Presentation (Compose views) communicates via state to ViewModel, which calls repository/services. Network and local persistence live behind abstractions.
2. **Unidirectional State Flow**: Screens render from a sealed `UiState` representing `Loading`, `Content`, `Empty`, or `Error`.
3. **No Blocking UI Work**: Network and disk requests are performed via Kotlin coroutines on `Dispatchers.IO`.
4. **Stable Selectors (Mandatory §3)**: `Modifier.testTag(tag)` combined with `Modifier.semantics { testTagsAsResourceId = true }` is used to expose E2E selectors as resource IDs to Maestro.
5. **UI Test Mode (§4)**: Handled by parsing the launch `Intent` extras in `MainActivity` at startup and populating a `TestConfig` object. This dynamically overrides the auth picker, API key, base URL, whitelists, and external links behavior.
6. **Accessible Map Markers (§5)**: Since `osmdroid` renders on a custom `Canvas` without accessibility nodes, we render an overlay of `Compose` `AssistChip`s carrying the `map_marker` test tag. Each chip corresponds to a located video, allowing Maestro to reliably tap markers, satisfying the accessibility contract without coordination hacks.
7. **Overlay Reachability (§5a)**: Dialogs/popups or detail views are rendered inline (using Compose `Box` positioning) to guarantee test identifiers remain reachable.

---

## Project Structure

```text
app/src/main/
├── AndroidManifest.xml
├── java/com/example/ytdash/
│   ├── MainApplication.kt                # Application entry point & manual DI container
│   ├── MainActivity.kt                   # Single Activity, reads intent extras and hosts UI
│   ├── data/
│   │   ├── model/
│   │   │   ├── Video.kt                  # Domain data model
│   │   │   ├── ChannelConfig.kt          # Channel definition from config
│   │   │   └── TestConfig.kt             # Launch/UI-test configuration
│   │   ├── repository/
│   │   │   ├── VideoRepository.kt        # Combines remote API and local SharedPreferences cache
│   │   │   └── AuthRepository.kt         # Holds whitelist verification and Google identity logic
│   │   └── network/
│   │       └── YouTubeApiService.kt      # Performs API requests to Youtube or the mock server
│   ├── ui/
│   │   ├── theme/                        # Sleek dark-mode & Outfit-based Material3 theme
│   │   ├── viewmodel/
│   │   │   └── MainViewModel.kt          # Manages screen, auth, videos, filters, and sort states
│   │   └── view/
│   │       ├── LoginScreen.kt            # screen_login + Google Sign-In button
│   │       ├── HomeScreen.kt             # screen_home with video_list or screen_map
│   │       ├── VideoListTab.kt           # video_list, video_list_item, pull-to-refresh
│   │       └── MapTab.kt                 # screen_map with osmdroid and native AssistChip overlay
│   └── util/
│       └── TestUtils.kt                  # Helpers for intent reading and external links capture
└── res/
    └── values/
        └── strings.xml
```

---

## Technical Decisions & Justifications

### 1. Simple State-Driven Navigation
Rather than bringing in complex Navigation-Compose libraries which suffer from version mismatches and deep state-restoration bugs under automated harnesses, we use an enum-based navigation structure modeled within `MainViewModel` and handled via standard declarative Compose branch rendering. This is 100% robust, compile-time checked, and completely transparent.

### 2. SharedPreferences JSON Persistence
Using SQLite or Room adds significant compilation complexity, ksp versioning overhead, and potential DB migration crashes. Since our database is a flat list of aggregated videos, serializing/deserializing the cached video array using Gson and writing it to `SharedPreferences` is incredibly lightweight, safe, instant, and completely meets `AC-CACHE-01` (surviving cold relaunches).

### 3. Native AssistChip Overlay for OSM Markers
As mandated in §5, osmdroid's map pins are drawn directly onto an Android Canvas and do not expose accessibility nodes to Maestro. To keep the app 100% testable, we display a horizontal scrollable row of Compose `AssistChip` components carrying the tag `map_marker` directly below or above the map. Selecting a chip highlights the pin on the map and opens the `detail_bottom_sheet` in the same way tapping a map marker would. We also support human taps on the real osmdroid Map Overlay Pins.

### 4. Inline Bottom Sheet Overlay
To avoid the Compose `ModalBottomSheet` separate-window trap (§5a) where accessibility tags are lost, our video detail bottom sheet is rendered as an absolutely positioned `Surface` at the bottom of the map screen container. This ensures all IDs (`detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`) are fully discoverable by Maestro.
