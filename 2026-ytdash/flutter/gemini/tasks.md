# Tasks: ytdash_flutter Implementation

## Phase 1: Setup & Native Bridge (Launch Config)
- [ ] T001 Add primary dependencies (`http`, `shared_preferences`, `flutter_map`, `latlong2`, `url_launcher`) to `pubspec.yaml`
- [ ] T002 Implement MethodChannel in `android/app/src/main/kotlin/.../MainActivity.kt` to read launch intent extras
- [ ] T003 Create `TestConfig` data class in Dart to load and expose launch extras
- [ ] T004 Add internet permission to `AndroidManifest.xml` and ensure cleartext traffic is enabled for mock server communication
- [ ] T005 Wire up `SemanticsBinding.instance.ensureSemantics()` in `main.dart` for Maestro automation

## Phase 2: Domain, Models & Data Access
- [ ] T006 Define `Video` domain model with nested `Location` class, JSON parsing (`fromJson`/`toJson`)
- [ ] T007 Implement `CacheService` to serialize and deserialize the list of videos to/from disk using `shared_preferences`
- [ ] T008 Implement `YoutubeService` with standard HTTP requests, pagination, and multi-channel aggregation
- [ ] T009 Implement `GeocodingService` with 3-decimal caching and Nominatim integration
- [ ] T010 Implement `VideoRepository` merging network results, caching updates, and handling offline/network failures

## Phase 3: Authentication & Whitelist (Iteration 1)
- [ ] T011 Create `AuthViewModel` with google sign-in simulation (for uiTestMode) / real logic, whitelist checks, and session tracking
- [ ] T012 Implement `LoginScreen` UI with stable IDs (`screen_login`, `login_google_button`, `login_error_message`)
- [ ] T013 Implement secure routing/navigation between Login and Home screens

## Phase 4: Video List & Counting (Iteration 2)
- [ ] T014 Create `VideoViewModel` managing state: Loading, Content, Empty, and Error with Retry
- [ ] T015 Implement `HomeScreen` with `video_list` container and `video_list_item` rows
- [ ] T016 Display total video count in the title using `video_count` selector
- [ ] T017 Implement pull-to-refresh / button using `refresh_control`
- [ ] T018 Implement video tap deep-linking using `url_launcher`, supporting `captureExternalLinks` mode and `external_open_url`/`external_open_error` selectors at root

## Phase 5: Persistence, Filter & Sort (Iteration 3)
- [ ] T019 Implement automatic disk cache saving and silent stale-fallback on network error (AC-CACHE-01)
- [ ] T020 Implement sorting interface and logic (`sort_button`, `sort_apply_button`), supporting newest and oldest ordering
- [ ] T021 Implement filtering interface and logic (`filter_button`, `filter_apply_button`), supporting channel label categorization
- [ ] T022 Ensure filter/sort panel completely replaces the video list while open to avoid text collisions in Maestro

## Phase 6: Interactive Map & Details (Iteration 4)
- [ ] T023 Implement `MapScreen` using `flutter_map` and openstreetmap tiles
- [ ] T024 Place markers on coordinates for videos with locations, tagged with `map_marker` semantics identifier
- [ ] T025 Add reachable horizontal chips or list next to the map tagged as `map_marker` for reliable test execution
- [ ] T026 Implement native details sheet (`detail_bottom_sheet`) with `detail_video_url` and `detail_open_youtube_button`
- [ ] T027 Wire map bottom sheet open-action to deep-linking logic, ensuring proper external URL capture

## Phase 7: Polish, Verification & Completion
- [ ] T028 Write unit tests for whitelist check, sort/filter domain logic, and local cache read/write
- [ ] T029 Run static analysis using `flutter analyze` and ensure zero errors
- [ ] T030 Run Maestro tests (`flows/AC-*.yaml`) on device `25251FDF60029V` and resolve any issues
- [ ] T031 Complete and verify real-mode Google Sign-In and API parameters
- [ ] T032 Write `BUILD-REPORT.md` and touch `.build-complete`
