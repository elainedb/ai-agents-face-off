# Tasks: YouTube Dashboard ("ytdash")

## Phase 1: Setup & Infrastructure
- [ ] T001 Run `flutter pub add flutter_bloc equatable get_it injectable dartz shared_preferences flutter_map latlong2 url_launcher google_sign_in firebase_core firebase_auth http`
- [ ] T002 Run `flutter pub add --dev build_runner injectable_generator`
- [ ] T003 Set up config mechanism (TestConfig reader via MethodChannel from `intent.extras` in Android `MainActivity.kt`).
- [ ] T004 Create `lib/core/config/test_config.dart` to read `uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`, `captureExternalLinks`.
- [ ] T005 Set up `get_it` and `injectable` for dependency injection.
- [ ] T006 Set up Semantics bindings `SemanticsBinding.instance.ensureSemantics()` in `main()`.

## Phase 2: Iteration 1 — Authentication (AC-LOGIN-01, 02, 03)
- [ ] T007 Implement Auth repository (Google Sign-In logic + whitelist check).
- [ ] T008 Implement Auth UI screen with `login_google_button` and `login_error_message`.
- [ ] T009 Hook up Auth Bloc to handle `mockAuthEmail` if `uiTestMode` is active.

## Phase 3: Iteration 2 — Video list (AC-LIST-01, 02, 03, AC-COUNT-01, AC-LINK-01)
- [ ] T010 Implement YouTube API client (fetching from `search` or `playlistItems` + `videos` for details/location). Must fetch all pages.
- [ ] T011 Create domain entities (Video, Channel, Location).
- [ ] T012 Implement Video repository.
- [ ] T013 Implement Video list screen (`screen_home`, `video_list`, `video_list_item`, `video_count`, `refresh_control`, `logout_button`).
- [ ] T014 Implement URL launcher wrapper (with `external_open_url` and `external_open_error` banners).

## Phase 4: Iteration 3 — Caching, filtering, sorting (AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
- [ ] T015 Add local data source using `shared_preferences` (cache videos JSON, 24h TTL, stale-fallback).
- [ ] T016 Add UI for filter (`filter_button`, `filter_apply_button`) and sort (`sort_button`, `sort_apply_button`).
- [ ] T017 Implement filtering/sorting logic in Bloc or Domain use cases.

## Phase 5: Iteration 4 — Map (AC-MAP-01, 02, 03)
- [ ] T018 Implement Map screen (`screen_map`) with `flutter_map`.
- [ ] T019 Add markers with `Semantics(identifier: 'map_marker')` and an overlay row of native chips.
- [ ] T020 Implement Bottom Sheet (`detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`).

## Phase 6: Finalizing & Testing
- [ ] T021 Set up Android `google-services.json` from `config/secrets.env` dummy logic.
- [ ] T022 Wire real mode parameters.
- [ ] T023 Run maestro tests to self-validate all 12 ACs.
- [ ] T024 Write `BUILD-REPORT.md`.
- [ ] T025 Touch `.build-complete`.
