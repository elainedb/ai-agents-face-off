# Tasks: YouTube Dashboard ("ytdash")

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: User story grouping (Iter 1, Iter 2, Iter 3, Iter 4)

## Phase 1: Setup (Shared Infrastructure)
- [ ] T001 Initialize Android project (`com.example.ytdash`) with Jetpack Compose.
- [ ] T002 Add dependencies: Hilt, Retrofit, Room, Coil, kotlinx.serialization, Play Services Auth, osmdroid.
- [ ] T003 Setup `TestConfig` reader from `intent.extras` in `MainActivity`.
- [ ] T004 Setup config injection for base URL and API keys.

## Phase 2: Foundational
- [ ] T005 Setup Room database and `VideoEntity`.
- [ ] T006 Setup Retrofit interfaces for `youtube/v3/search`, `youtube/v3/videos`, and `Nominatim`.
- [ ] T007 Setup `VideoRepository` (network fetch + cache + DB fallback).

## Phase 3: Iteration 1 - Authentication & access control
- [ ] T008 [Iter1] Create `LoginScreen` and `LoginViewModel` with Google Sign-In and mock intercept (`mockAuthEmail`).
- [ ] T009 [Iter1] Implement whitelist check logic using `authorizedEmails` config/secrets.
- [ ] T010 [Iter1] Handle error states (`login_error_message`) and success routing.

## Phase 4: Iteration 2 - Video list
- [ ] T011 [Iter2] Implement paginated fetch logic for all source channels in `config/channels.json`.
- [ ] T012 [Iter2] Create `HomeScreen` and `video_list` component using `LazyColumn`.
- [ ] T013 [Iter2] Display `video_count` in top bar.
- [ ] T014 [Iter2] Implement external app launch intent for YouTube videos (and mock `captureExternalLinks` banner).
- [ ] T015 [Iter2] Implement pull-to-refresh (`refresh_control`).

## Phase 5: Iteration 3 - Caching, filtering, sorting
- [ ] T016 [Iter3] Connect Room cache for offline fallback.
- [ ] T017 [Iter3] Implement Filter UI (`filter_button`, `filter_apply_button`) and logic to filter by category.
- [ ] T018 [Iter3] Implement Sort UI (`sort_button`, `sort_apply_button`) and logic to sort by date.

## Phase 6: Iteration 4 - Map
- [ ] T019 [Iter4] Add `osmdroid` map view (`AndroidView`).
- [ ] T020 [Iter4] Fetch/reverse-geocode locations via OSM/Nominatim.
- [ ] T021 [Iter4] Render Compose `AssistChip` overlay row for `map_marker` reachability.
- [ ] T022 [Iter4] Implement bottom sheet (`detail_bottom_sheet`) with `detail_video_url` and `detail_open_youtube_button`.

## Phase 7: Polish & E2E Run
- [ ] T023 Setup real google-services.json and channels.json.
- [ ] T024 Add necessary AndroidManifest permissions (INTERNET, ACCESS_NETWORK_STATE, cleartext for mock).
- [ ] T025 Run Maestro flows and ensure all pass.
