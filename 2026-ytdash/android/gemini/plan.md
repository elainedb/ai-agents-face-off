# Implementation Plan: YouTube Dashboard ("ytdash")

## Summary
Build a production-quality Android app that signs users in (whitelist only), fetches YouTube videos from a mock/real API across specified channels, caches them locally, allows sorting and filtering, and shows geolocated videos on a map.

## Technical Context

**Language/Version**: Kotlin, minSdk 29, targetSdk 35

**Primary Dependencies**: 
- Jetpack Compose (UI)
- Hilt (Dependency Injection)
- Retrofit + OkHttp (Network)
- kotlinx.serialization (JSON parsing)
- Room (Local Cache/Database)
- osmdroid (Map Widget)
- Coil (Image Loading)
- Play Services Auth (Google Sign-In)

**Storage**: Room Database (SQLite) for caching video data offline with 24h TTL logic.

**Testing**: E2E Maestro flows handle validation.

**Target Platform**: Android E2E on Emulator 25251FDF60029V

**Project Type**: Mobile App

**Performance Goals**: Fast UI, smooth scrolling with Coil, responsive maps.

**Constraints**: Adhere strictly to the selector contract, UI-test-mode contract, and map marker contract defined in `spec/constitution.md`. No secrets in source control.

**Scale/Scope**: 4 Iterations. E2E validated via Maestro.

## Project Structure

```text
src/main/
├── AndroidManifest.xml
└── java/com/example/ytdash/
    ├── MainActivity.kt (Entry point + test config reading)
    ├── App.kt (Hilt Application class)
    ├── di/ (Hilt Modules)
    ├── data/
    │   ├── model/ (VideoEntity, ChannelConfig, etc.)
    │   ├── network/ (Retrofit interface, Interceptors)
    │   ├── local/ (Room DAOs and Database)
    │   └── repository/ (VideoRepository)
    ├── domain/ (Auth logic, Filtering, Sorting)
    └── ui/
        ├── theme/ (Color, Theme, Typography)
        ├── login/ (LoginScreen, LoginViewModel)
        ├── home/ (HomeScreen, HomeViewModel, FilterSortPanel)
        └── map/ (MapScreen, MapViewModel)
```

## Architecture and Approach
- **UI Test Mode**: `intent.extras` parsed on launch into a singleton or injected config class to supply `uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`, `captureExternalLinks`.
- **Authentication**: `Play Services Auth` is used, intercepted via UI-test-mode config if `mockAuthEmail` is present. Check email against whitelist.
- **Networking**: `Retrofit` is used with a dynamic base URL. Interceptor reads `apiKey` from config.
- **Data Persistence**: `Room` is the single source of truth. On launch, attempt fetch; on fail, return cached data if offline, else fail.
- **State Management**: `ViewModel` + `StateFlow` exposing a sealed `UiState` (Loading/Content/Error/Empty).
- **Map Accessibility**: `osmdroid` draws on a Canvas, so its markers are unreachable to Maestro. We will render a native Compose `AssistChip` row overlaid on the map to provide accessible "map_marker" elements that open the `detail_bottom_sheet`.

## Justification
This stack is idiomatic for modern Android development. Compose offers fast UI building. Hilt standardizes DI. Room is the official persistence layer. Retrofit + OkHttp handle robust networking. osmdroid is a lightweight mapping library suitable since we don't depend on Google Maps SDK.
