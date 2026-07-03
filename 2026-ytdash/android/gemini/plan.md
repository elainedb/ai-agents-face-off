# Implementation Plan: YouTube Dashboard ("ytdash")

**Branch**: `main` | **Date**: 2026-07-02 | **Spec**: [spec/spec.md](file:///tmp/ytrun.FHGjuq/workspace/spec/spec.md)

## Summary
The ytdash app is a high-quality native Android app built using Kotlin, Jetpack Compose, and Material3. It will:
1. Authenticate users via Google Sign-In with an authorized email whitelist, including a fully customizable mock-auth bypass for UI testing.
2. Fetch and aggregate YouTube videos from configured channels, following pagination to retrieve all pages, and deduplicating by videoId.
3. Cache the loaded videos locally in SharedPreferences using JSON serialization, supporting robust offline viewing on network failures.
4. Offer intuitive sorting (by date and title) and filtering (by channel category).
5. Plot geolocated videos on an OpenStreetMap using `osmdroid` and expose reachable native AssistChips as map markers to satisfy the black-box E2E test suite seamlessly.

## Technical Context

**Language/Version**: Kotlin 2.2+, JDK 17, Android compileSdk 36

**Primary Dependencies**:
- UI: Jetpack Compose (BOM 2026.03.01) & Material3
- Navigation: Jetpack Navigation 3 (runtime + UI)
- Network: OkHttp 4.12.0 for HTTP networking, lightweight & robust
- JSON Serialization: Kotlinx Serialization (JSON)
- Map Widget: `org.osmdroid:osmdroid-android:6.1.20` embedded via `AndroidView`
- Credentials: `androidx.credentials` + `androidx.credentials:credentials-play-services-auth`

**Storage**:
- `SharedPreferences` storing serialized Kotlinx JSON array of videos (for offline cache & stale-fallback). High reliability, zero migration overhead.

**Testing**:
- Local JUnit4 unit tests for Sorting, Filtering, and Whitelist validation.
- E2E: Maestro flows running on the target device.

**Target Platform**: Android API 24+ (minSdk 24, compileSdk 36)

**Performance Goals**: Butter-smooth list scrolling (60fps+) with AsyncImage thumbnail loading (using Coil).

**Constraints**: Offline-capable, no blocking work on the main UI thread.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Selector contract (MANDATORY)**: We will set `testTagsAsResourceId = true` on the root composition. Popups/dialogs (such as sorting/filtering overlays) will be inline surfaces/Views so they stay within the main semantics tree, or will have the flag re-applied. We will put the list-item ID (`video_list_item`) directly on the title `Text` component per Compose-specific guidelines to ensure the text matches the ID on the same node.
- **UI Test Mode contract (MANDATORY)**: Reads launch intent extras (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`, `captureExternalLinks`) at startup and stores them in a global `TestConfig` singleton.
- **Accessible Markers contract (MANDATORY)**: Since `osmdroid` draws markers on a Canvas, they are not reachable by black-box tools. We will expose an horizontal/scrollable row of Compose `AssistChip`s (using `testTag("map_marker")`), one per geolocated video, in the main layout. Human taps on the canvas markers and E2E taps on the Compose chips will both show the native details bottom sheet.
- **Single Source of Truth**: The local SharedPreferences cache is the main data source that the UI reads from; network fetch refreshes the cache.

## Project Structure

```text
app/
├── src/
│   ├── main/
│   │   ├── AndroidManifest.xml
│   │   ├── java/com/example/ytdash/
│   │   │   ├── MainActivity.kt          # Host Activity, parses Intent extras
│   │   │   ├── Navigation.kt            # Compose screens navigation
│   │   │   ├── NavigationKeys.kt
│   │   │   ├── TestConfig.kt            # Holds launch-intent test config
│   │   │   ├── theme/                   # Theme tokens (Color, Type, Theme)
│   │   │   ├── data/
│   │   │   │   ├── DataRepository.kt    # Network & cache operations
│   │   │   │   ├── Models.kt            # Kotlinx-serializable models
│   │   │   ├── ui/
│   │   │   │   ├── login/               # Login screen UI & Viewmodel
│   │   │   │   ├── main/                # Main video list & map UI & ViewModel
```

**Structure Decision**: Standard single-module Android application project with clean packaged architecture (data layer, ui layer, domain logic layer).
