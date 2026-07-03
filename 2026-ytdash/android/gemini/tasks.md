# Tasks: ytdash Implementation

## Phase 1: Setup (Shared Infrastructure)
- [ ] T001 Define serializable Data Models for YouTube API response matching `spec/youtube-api.md`.
- [ ] T002 Implement `TestConfig` parsing to read intent extras at launch and support UI-test-mode.
- [ ] T003 Configure `libs.versions.toml` and `app/build.gradle.kts` to add OkHttp, Coil, Kotlinx Serialization, and Osmdroid dependencies.

## Phase 2: Foundational (Blocking Prerequisites)
- [ ] T004 Implement `DataRepository` handling local JSON caching via SharedPreferences and fetching from YouTube endpoints.
- [ ] T005 Implement pagination-following network aggregation across all configured channels from `config/channels.json`.
- [ ] T006 Implement email-whitelist validation logic.

## Phase 3: Iteration 1 - Authentication & Access Control (AC-LOGIN-01, AC-LOGIN-02, AC-LOGIN-03)
- [ ] T007 Implement Login Screen UI with `login_google_button` and error feedback handling.
- [ ] T008 Add mockAuthEmail bypass in UI Test Mode to sign in immediately.
- [ ] T009 Add whitelist verification and error handling.
- [ ] T010 Implement logout functionality returning to Login Screen.

## Phase 4: Iteration 2 - Video List (AC-LIST-01, AC-LIST-02, AC-LIST-03, AC-COUNT-01, AC-LINK-01)
- [ ] T011 Implement scrollable `video_list` matching `video_list_item` selectors.
- [ ] T012 Put `video_list_item` on the title `Text` component itself for Compose-specific matching.
- [ ] T013 Expose total loaded videos count in screen title as `video_count`.
- [ ] T014 Implement refresh control with manual retry capability.
- [ ] T015 Implement "open in YouTube" support, checking `captureExternalLinks` to render `external_open_url` or perform a real launch with error handling (`external_open_error`).

## Phase 5: Iteration 3 - Caching, Filtering, Sorting (AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
- [ ] T016 Persist full list of aggregate videos to SharedPreferences cache after each successful fetch.
- [ ] T017 Implement stale-cache fallback when offline.
- [ ] T018 Implement sorting panel by date/title and filtering panel by source-channel label, replacing the list view when open to prevent text collisions.

## Phase 6: Iteration 4 - Map & Bottom Sheet (AC-MAP-01, AC-MAP-02, AC-MAP-03)
- [ ] T019 Integrate OpenStreetMap (`osmdroid`) into Map Screen inside an `AndroidView`.
- [ ] T020 Implement a horizontal/scrollable Row of reachable Compose `AssistChip`s carrying `map_marker` for E2E coordinate-less tapping.
- [ ] T021 Implement `detail_bottom_sheet` shown when tapping a marker or chip, containing `detail_video_url` and `detail_open_youtube_button`.
- [ ] T022 Bind the Map Bottom Sheet button to deep-link launch matching the `captureExternalLinks` mechanism.
