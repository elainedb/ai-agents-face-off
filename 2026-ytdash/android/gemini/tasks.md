# Tasks Checklist — YouTube Dashboard ("ytdash")

## Phase 1: Setup & Foundational (Shared Infrastructure)
- [ ] T001 Add required dependencies (OkHttp, Kotlinx Serialization, and Osmdroid) to `gradle/libs.versions.toml` and `app/build.gradle.kts`
- [ ] T002 Create data models in `app/src/main/java/com/example/ytdash/data/Model.kt` (Video, Location, Channel, YouTube response types)
- [ ] T003 Implement `TestConfig` class to parse Android launch intent extras (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`, `captureExternalLinks`)
- [ ] T004 Setup basic Navigation structure in `app/src/main/java/com/example/ytdash/Navigation.kt` (Login, Home, Map screens) with `testTagsAsResourceId = true` on root

## Phase 2: Iteration 1 — Authentication & Access Control
- [ ] T005 Create Login screen UI in `app/src/main/java/com/example/ytdash/ui/auth/LoginScreen.kt` with `screen_login`, `login_google_button`, and `login_error_message`
- [ ] T006 Implement whitelist verification logic using emails from `authorizedEmails` (from launch extras or default production whitelist: `user1@example.com,user2@example.com`)
- [ ] T007 Implement Mock Google Sign-In in test mode (bypass Google picker, sign in directly as `mockAuthEmail` if present)
- [ ] T008 Implement Sign-Out button `logout_button` and logic to return to Login screen

## Phase 3: Iteration 2 — Video List & Pagination
- [ ] T009 Implement API fetcher in `DataRepository` to load and aggregate configured channels from `config/channels.json`
- [ ] T010 Implement pagination in `DataRepository` (recursively follow `nextPageToken` until all pages of all channels are loaded and merged)
- [ ] T011 Create Video List UI in `app/src/main/java/com/example/ytdash/ui/list/ListScreen.kt` with `video_list`, `video_list_item` (on title Text), and `video_count` in the screen title
- [ ] T012 Implement Pull-To-Refresh on the video list (`refresh_control`) and loading/error/empty states
- [ ] T013 Implement "Open in external YouTube" logic for list item click (with support for `captureExternalLinks` and `external_open_url` / `external_open_error`)

## Phase 4: Iteration 3 — Caching, Filtering, & Sorting
- [ ] T014 Implement persistent caching using SharedPreferences + `kotlinx.serialization` (saves latest aggregated videos; falls back to cache on offline relaunch)
- [ ] T015 Create Filter and Sort panels that replace the video list while open (to avoid text collisions)
- [ ] T016 Implement category filtering (`filter_button`, `filter_apply_button`) based on categories/labels present in data
- [ ] T017 Implement sorting by title (alphabetical ascending/descending) and date (publishedAt descending/ascending) (`sort_button`, `sort_apply_button`)

## Phase 5: Iteration 4 — Map Screen with Accessible Markers
- [ ] T018 Integrate osmdroid in `app/src/main/java/com/example/ytdash/ui/map/MapScreen.kt` (`screen_map`, `map_nav_button`)
- [ ] T019 Implement accessible native marker chips / overlay (`map_marker` tagged `AssistChip`s) representing located videos
- [ ] T020 Implement details bottom sheet (`detail_bottom_sheet`) overlaying the map with `detail_video_url` and `detail_open_youtube_button`
- [ ] T021 Connect bottom sheet "Open in YouTube" button to external launcher with `captureExternalLinks` and `external_open_error` support

## Phase 6: Polish & Verification
- [ ] T022 Write unit tests for sorting, filtering, and auth whitelist checks
- [ ] T023 Write persistence tests for caching (SharedPreferences)
- [ ] T024 Run Maestro flows locally and verify that all 12 criteria pass against the mock server
- [ ] T025 Confirm real-mode compatibility with the real Google Sign-In and real YouTube API
- [ ] T026 Generate `BUILD-REPORT.md` and signal completion via `.build-complete`
