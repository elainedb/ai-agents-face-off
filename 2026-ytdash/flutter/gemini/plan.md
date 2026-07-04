# Implementation Plan

## Architecture
- **Layered separation**:
  - `data`: network (HTTP client), local persistence (SharedPreferences), models, data mapping.
  - `domain`: business logic (sorting, filtering, auth rules).
  - `presentation`: UI components, view states (loading, empty, content, error).
- **Dependency Injection & State Management**: `flutter_riverpod`. It is lightweight, type-safe, and very popular for dependency injection and unidirectional observable state.
- **Single Source of Truth**: The local cache (persisted via `shared_preferences` as JSON) is the source of truth. Network fetch refreshes it.

## Libraries
- `http`: For network requests.
- `shared_preferences`: For local persistence (cache).
- `flutter_riverpod`: State management and dependency injection.
- `google_sign_in`: Real Google Sign-in.
- `flutter_map` & `latlong2`: For the map widget and coordinates.
- `url_launcher`: To open the video external URLs.
- `freezed_annotation` and `json_annotation` for models (if beneficial), but manual JSON is also fine. We'll use manual parsing to keep it simple and avoid build_runner.

## Features & Implementation
1. **Test Config**: A `MethodChannel` at `ytdash/testconfig` to read launch intent extras for `uiTestMode`, `mockAuthEmail`, etc.
2. **Auth**: `AuthService` will handle mock auth when `mockAuthEmail` is present, or call `google_sign_in` in real mode.
3. **Network**: `YouTubeApi` client. It fetches all pages of each channel using `nextPageToken`.
4. **Offline Cache**: Videos saved to `shared_preferences`. Fallback on network error.
5. **Map**: `flutter_map`. `Semantics(identifier: 'map_marker')` on each marker widget, plus an overlay list row fallback to ensure tests can reach it if needed (per constitution §5).
6. **Testing Identifiers**: Wrap widgets with `Semantics(identifier: 'X')`. Use `SemanticsBinding.instance.ensureSemantics()` in `main()`.

## Anti-Overfit
- We will dynamically fetch `channels.json` or hardcode its labels but fetch everything from the API based on the list. Actually, `channels.json` is in `config/channels.json`, we will load it as an asset.
- We will parse pages recursively until `nextPageToken` is null.
