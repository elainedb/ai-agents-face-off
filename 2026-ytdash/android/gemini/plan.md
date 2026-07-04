# Implementation Plan

## Technical Context
- **Framework**: Android (native)
- **Language**: Kotlin 2.0+
- **UI**: Jetpack Compose + Material 3
- **Architecture**: MVVM with unidirectional data flow (sealed `UiState` representing Loading, Content, Error, Empty).
- **Dependency Injection**: Hilt
- **Network**: Retrofit + OkHttp + kotlinx.serialization
- **Persistence**: Room Database (for robust offline caching with 24h TTL and stale-fallback on network error)
- **Map**: osmdroid via `AndroidView` (since native OSM markers are canvas-drawn and unreachable, we will expose a native `AssistChip` row as the reachable affordance, per the cross-framework setup guide).
- **Image Loading**: Coil
- **Auth**: Play Services Auth (`com.google.android.gms:play-services-auth`)

## Justification
This stack represents the modern, idiomatic Android development approach. Kotlin + Compose is the standard for building UIs. MVVM with a unidirectional state flow handles the required UI states (loading, error, content) predictably. Hilt simplifies dependency injection, ensuring our presentation layer depends on abstractions rather than concrete data sources. Retrofit is the gold standard for network requests, and Room provides robust offline caching capability. osmdroid is the standard library for OpenStreetMap on Android.

## UI Test Mode & Contracts
- The app will read `intent.extras` in `MainActivity` to populate a `TestConfig` object.
- Stable selectors will be implemented using `Modifier.testTag("x")` with `Modifier.semantics { testTagsAsResourceId = true }` at the root. We will ensure popups (like the bottom sheet) keep their elements in the main composition tree or explicitly re-apply the semantics if necessary.
- We will fetch all pages of all channels using YouTube Data API's pagination.
- For map markers, since osmdroid canvas nodes aren't reachable, we will render a native Compose list of chips below or overlaying the map to satisfy the `map_marker` requirement.

## Workflow Phases
1. **Setup**: Base Android project, Hilt, Navigation, API networking setup.
2. **Iteration 1**: Google Sign-in, Authentication UI, whitelist enforcement.
3. **Iteration 2**: Video List, YouTube API integration (fetching all pages), launching external URL.
4. **Iteration 3**: Room caching, Sorting, Filtering.
5. **Iteration 4**: Map screen, osmdroid integration, native marker list.
