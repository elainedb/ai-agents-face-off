# Tasks: YouTube Dashboard ("ytdash")

## Phase 1: Setup & Shared Infrastructure

- [ ] T001 Verify Flutter and Android toolchain dependencies.
- [ ] T002 Add dependencies to `pubspec.yaml` and run `flutter pub get` (done).
- [ ] T003 Configure native Android MainActivity to handle MethodChannel for intent extras.

## Phase 2: Foundational Services & Models

- [ ] T004 Implement `Video` model in `lib/models/video.dart` with parsing and geocoding support.
- [ ] T005 Implement `TestConfig` in `lib/services/test_config.dart` to manage launch arguments.
- [ ] T006 Implement `AuthService` in `lib/services/auth_service.dart` for Google Sign-In and Whitelist filtering.
- [ ] T007 Implement `ApiService` in `lib/services/api_service.dart` supporting pagination across multiple channels.
- [ ] T008 Implement `CacheService` in `lib/services/cache_service.dart` using `shared_preferences` for offline fallback.

## Phase 3: Iteration 1 - Authentication & Access (P1)

- [ ] T009 Implement `LoginScreen` in `lib/screens/login_screen.dart` with `screen_login`, `login_google_button`, and `login_error_message`.
- [ ] T010 Hook up `LoginScreen` in `main.dart` with proper routing.
- [ ] T011 Verify AC-LOGIN-01, AC-LOGIN-02, AC-LOGIN-03.

## Phase 4: Iteration 2 - Video List & Navigation (P1)

- [ ] T012 Implement `HomeScreen` in `lib/screens/home_screen.dart` with `screen_home`, `video_list`, `video_list_item`, and `video_count`.
- [ ] T013 Implement "Pull-to-refresh" functionality using `refresh_control`.
- [ ] T014 Implement external link opening with `captureExternalLinks` routing to `external_open_url` / `external_open_error`.
- [ ] T015 Verify AC-LIST-01, AC-LIST-02, AC-LIST-03, AC-COUNT-01, AC-LINK-01.

## Phase 5: Iteration 3 - Caching, Filtering, Sorting (P2)

- [ ] T016 Integrate `CacheService` into the data loading pipeline to fallback to local stale cache on network failures.
- [ ] T017 Implement category filter UI (`filter_button`, `filter_apply_button`) which replaces/overlays the list while open to avoid text collision.
- [ ] T018 Implement sorting UI (`sort_button`, `sort_apply_button`) allowing Date Descending ("Date - Newest") and Date Ascending ("Date - Oldest").
- [ ] T019 Verify AC-CACHE-01, AC-FILTER-01, AC-SORT-01.

## Phase 6: Iteration 4 - Map Integration (P2)

- [ ] T020 Implement `MapScreen` in `lib/screens/map_screen.dart` using `flutter_map` + `latlong2`.
- [ ] T021 Wrap map markers with `Semantics(identifier: 'map_marker')` and add a horizontal list of accessible interactive text chips for each located video.
- [ ] T022 Implement the bottom sheet detail view (`detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`).
- [ ] T023 Verify AC-MAP-01, AC-MAP-02, AC-MAP-03.

## Phase 7: Polish, Quality Assurance & Complete

- [ ] T024 Write and run unit tests for domain/business logic.
- [ ] T025 Run local static analysis clean-up.
- [ ] T026 Execute and verify all Maestro tests.
- [ ] T027 Generate `BUILD-REPORT.md` and touch `.build-complete`.
