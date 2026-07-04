# Tasks: YouTube Dashboard (ytdash)

## Phase 1: Setup
- [ ] T001 Initialize Retrofit, Kotlinx Serialization dependencies in `app/build.gradle.kts`.
- [ ] T002 Setup `TestConfig` to parse `intent.extras` in `MainActivity.kt`.
- [ ] T003 Create UI themes and basic common components (Loading, ErrorView with Retry).

## Phase 2: Foundational (Auth & Domain)
- [ ] T004 Implement `AuthRepository` supporting Google Sign-In and `mockAuthEmail`.
- [ ] T005 Implement `ConfigRepository` to read `config/channels.json` and `config/secrets.env` (or mock values).
- [ ] T006 Implement Email Whitelist Domain Logic (`isAuthorized(email)`).

## Phase 3: Iteration 1 - Authentication (AC-LOGIN-01, 02, 03)
- [ ] T007 Build `LoginScreen` UI (`screen_login`, `login_google_button`, `login_error_message`).
- [ ] T008 Implement `LoginViewModel` to handle auth flow and whitelist check.
- [ ] T009 Add Logout functionality (`logout_button`) in `MainActivity` or shared top bar.

## Phase 4: Iteration 2 - Video List (AC-LIST-01, 02, 03, AC-COUNT-01, AC-LINK-01)
- [ ] T010 Implement `YouTubeApi` via Retrofit (handle `search.list` and `videos.list` or `playlistItems`).
- [ ] T011 Implement paginated fetching to gather ALL videos from ALL channels.
- [ ] T012 Parse YouTube API JSON to `domain/models/Video`.
- [ ] T013 Build `HomeScreen` UI (`screen_home`, `video_list`, `video_list_item`, `video_count`, `refresh_control`).
- [ ] T014 Implement external link opening (real vs captured `captureExternalLinks` -> `external_open_url` / `external_open_error`).

## Phase 5: Iteration 3 - Caching, Filtering, Sorting (AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
- [ ] T015 Implement `VideoCache` using `SharedPreferences` (save/load JSON list).
- [ ] T016 Modify `VideoRepository` to implement stale-cache fallback on network error.
- [ ] T017 Implement Sort/Filter UI replacing list when open (`filter_button`, `sort_button`, etc.).
- [ ] T018 Implement Sort/Filter logic in `HomeViewModel`.

## Phase 6: Iteration 4 - Map (AC-MAP-01, 02, 03)
- [ ] T019 Implement `MapScreen` using `osmdroid` (`screen_map`).
- [ ] T020 Add accessible `AssistChip` fallback for markers (`map_marker`).
- [ ] T021 Implement marker selection and `detail_bottom_sheet` (with `detail_video_url`, `detail_open_youtube_button`).
- [ ] T022 Wire bottom sheet YouTube button to open external link logic.

## Phase 7: Polish & Self-Validation
- [ ] T023 Run `maestro test flows/` locally to verify 12/12 ACs.
- [ ] T024 Write `BUILD-REPORT.md`.
- [ ] T025 Create `.build-complete`.
