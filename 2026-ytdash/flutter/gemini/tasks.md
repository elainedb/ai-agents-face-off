# Tasks: YouTube Dashboard

## Phase 1: Setup
- [x] T001: Add dependencies (flutter_bloc, get_it, http, shared_preferences, flutter_map, etc.)
- [ ] T002: Implement `test_config.dart` (MethodChannel to read Maestro intent extras)
- [ ] T003: Setup DI (`get_it`) and core failure/result classes

## Phase 2: Auth (Iteration 1)
- [ ] T004: Create Auth Repository using `google_sign_in` and mock auth fallback.
- [ ] T005: Create Auth BLoC and Login Screen.
- [ ] T006: Add `screen_login`, `login_google_button`, `login_error_message`, `screen_home`, `logout_button` semantics.

## Phase 3: Video List (Iteration 2)
- [ ] T007: Implement Video Model (JSON parsing).
- [ ] T008: Implement YouTube API Repository (fetch channels, pagination, parse data).
- [ ] T009: Implement Video List Screen and BLoC.
- [ ] T010: Add list semantics (`video_list`, `video_list_item`, `video_count`, `refresh_control`, `loading_indicator`, `error_view`, `error_retry_button`, `external_open_url`, `external_open_error`).

## Phase 4: Caching, Filter, Sort (Iteration 3)
- [ ] T011: Implement local caching via `shared_preferences`.
- [ ] T012: Implement filtering and sorting logic in BLoC.
- [ ] T013: Implement filter/sort UI panels replacing list. Add semantics (`filter_button`, `filter_apply_button`, `sort_button`, `sort_apply_button`).

## Phase 5: Map (Iteration 4)
- [ ] T014: Implement Map Screen using `flutter_map`.
- [ ] T015: Add `map_nav_button`, `screen_map`, `map_marker`, `detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button` semantics.
- [ ] T016: Ensure UI Test Mode uses mock URLs and correctly skips external intents.

## Phase 6: Run Maestro
- [ ] T017: Start mock server.
- [ ] T018: Run maestro tests for Android emulator 25251FDF60029V.
