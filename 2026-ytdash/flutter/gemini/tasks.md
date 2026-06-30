# Tasks: YouTube Dashboard ("ytdash")

**Input**: Design documents from `plan.md` and requirements from `spec/spec.md`.

## Phase 1: Setup & Shared Infrastructure
- [ ] T001 Add all required packages (`http`, `shared_preferences`, `provider`, `flutter_map`, `latlong2`, `url_launcher`, `google_sign_in`) to `pubspec.yaml`
- [ ] T002 Implement the MethodChannel in `android/app/src/main/kotlin/com/example/ytdash_flutter/MainActivity.kt` to read Android launch intent extras
- [ ] T003 Set up Dart/Flutter linting rules and verify clean baseline analysis

## Phase 2: Foundational Layers (Data & Domain)
- [ ] T004 Create immutable domain model `Video` and write JSON serializers/deserializers
- [ ] T005 Implement `PreferenceRepository` to manage persistent state (logged-in email, cached video list JSON, offline detection)
- [ ] T006 Implement `YoutubeApiClient` with full pagination following, channel aggregation, and dynamic `apiBaseUrl` / `apiKey` support
- [ ] T007 Implement `NominatimGeocodingService` with rate limiting, User-Agent, and local geocode-cache support

## Phase 3: User Story 1 - Authentication & Whitelist (Iteration 1)
- [ ] T008 Implement `AuthViewModel` managing login status, whitelisting emails, and session persistence
- [ ] T009 Implement `screen_login` UI with `login_google_button` and `login_error_message` elements
- [ ] T010 Integrate UI test mode auth bypass (`mockAuthEmail`) in `AuthViewModel`

## Phase 4: User Story 2 - Video List & Caching (Iteration 2 & 3)
- [ ] T011 Create `DashboardViewModel` with video listing, page aggregation, offline fallback, sorting, and filtering logic
- [ ] T012 Implement `screen_home` UI with `video_list` container, `video_list_item` rows, and `video_count` in the appBar title
- [ ] T013 Implement pull-to-refresh (`refresh_control` using `RefreshIndicator`) in `screen_home`
- [ ] T014 Add external deep-link launching for tapping rows, with test mode `captureExternalLinks` routing to an overlay banner `external_open_url`
- [ ] T015 Verify offline relaunch with stale cache fallback (AC-CACHE-01) works perfectly without blocking `error_view`

## Phase 5: User Story 3 - Filtering & Sorting (Iteration 3)
- [ ] T016 Implement category filter panel in `screen_home` that replaces the video list while open, with `filter_button` and `filter_apply_button`
- [ ] T017 Implement date/title sort panel in `screen_home` that replaces the video list while open, with `sort_button` and `sort_apply_button`

## Phase 6: User Story 4 - Map & Bottom Sheet (Iteration 4)
- [ ] T018 Implement `MapViewModel` to filter located videos and manage selected video details
- [ ] T019 Implement `screen_map` using `flutter_map` showing actual geolocated video pins
- [ ] T020 Implement the native marker chip overlay (`map_marker` list/chips row) for reliable Maestro access
- [ ] T021 Implement `detail_bottom_sheet` with `detail_video_url` and `detail_open_youtube_button` that handles both real URL launching and test-mode capture

## Phase 7: Verification & Polish
- [ ] T022 Write unit tests for whitelist authentication, sorting, filtering, and local caching
- [ ] T023 Run static analysis and fix any Dart lint errors
- [ ] T024 Perform E2E Maestro tests against the mock server to pass all 12 ACs
- [ ] T025 Wire real mode configuration, build release APK, and perform smoke tests
- [ ] T026 Create `.build-complete` file and compile final `BUILD-REPORT.md`
