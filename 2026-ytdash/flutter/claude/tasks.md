# Tasks: ytdash (Flutter)

**Input**: `plan.md`, `spec/spec.md`, `spec/acceptance-criteria.md`, `spec/constitution.md`

## Selector inventory (constitution §3 → Flutter widget)

| Logical ID | Widget / mechanism |
|---|---|
| `screen_login` | `Semantics(identifier:)` on `LoginScreen`'s `Scaffold` |
| `login_google_button` | `Semantics(identifier:, button: true)` on the sign-in `ElevatedButton` |
| `login_error_message` | `Semantics(identifier:)` on the whitelist-rejection `Text` |
| `screen_home` | `Semantics(identifier:)` on `HomeScreen`'s `Scaffold` |
| `video_list` | `Semantics(identifier:)` on the `ListView`/`RefreshIndicator` |
| `video_list_item` | `Semantics(identifier:)` on each row (title text is a descendant, so it's aggregated) |
| `video_count` | `Semantics(identifier:)` on the `AppBar` title `Text` ("Videos (N)") |
| `logout_button` | `Semantics(identifier:)` on an always-visible `AppBar` action `IconButton` (no overflow menu needed) |
| `refresh_control` | `Semantics(identifier:)` on an `AppBar` action `IconButton` that calls the same refresh method as pull-to-refresh |
| `filter_button` / `filter_apply_button` | `AppBar` action → pushes `FilterScreen` (replaces list); its confirm button |
| `sort_button` / `sort_apply_button` | `AppBar` action → pushes `SortScreen` (replaces list); its confirm button |
| `map_nav_button` | `AppBar`/FAB action navigating to `MapScreen` |
| `screen_map` | `Semantics(identifier:)` on `MapScreen`'s `Scaffold` |
| `map_marker` | `Semantics(identifier:)` on each `flutter_map` `Marker` child AND each fallback chip |
| `detail_bottom_sheet` | `Semantics(identifier:)` on the modal sheet's root content |
| `detail_video_url` | `Semantics(identifier:)` on the sheet's URL `Text` |
| `detail_open_youtube_button` | `Semantics(identifier:)` on the sheet's action button |
| `loading_indicator` | `Semantics(identifier:)` on the `CircularProgressIndicator` wrapper |
| `error_view` | `Semantics(identifier:)` on the error `Column` |
| `error_retry_button` | `Semantics(identifier:)` on the retry button inside `error_view` |
| `external_open_url` / `external_open_error` | `Semantics(identifier:)` on the app-root banner text, driven by `ExternalLinkNotifier` |

## Phase 1 — Setup
- [x] T001 Read all specs (`constitution.md`, `spec.md`, `acceptance-criteria.md`,
      `cross-framework-setup.md`, `youtube-api.md`), inspect scaffold, mock server, flows.
- [x] T002 Write `plan.md`.
- [ ] T003 Add dependencies to `pubspec.yaml`: `flutter_riverpod`, `http`, `shared_preferences`,
      `flutter_map`, `latlong2`, `url_launcher`, `google_sign_in`. Bundle `config/channels.json` as
      an asset.

## Phase 2 — Foundational (blocking)
- [ ] T004 `MainActivity.kt`: MethodChannel `ytdash/testconfig` reading intent extras
      (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`,
      `captureExternalLinks`).
- [ ] T005 `lib/core/test_config.dart`: `TestConfig` model + `TestConfig.load()` calling the channel,
      with a safe fallback (production defaults) if the channel isn't available.
- [ ] T006 `lib/domain/models/video.dart`, `source_channel.dart`: hand-written `fromJson`.
- [ ] T007 `lib/domain/auth/auth_state.dart` (sealed: `SignedOut`/`SignedIn`/`Denied`),
      `auth_service.dart` (whitelist check, pure function `isAuthorized(email, whitelist)`).
- [ ] T008 `lib/domain/sorting_filtering.dart`: `sortVideos(videos, SortOrder)`,
      `filterVideos(videos, String? category)` — pure, unit-testable functions.

## Phase 3 — Data layer
- [ ] T009 `lib/data/remote/youtube_api_client.dart`: `search.list` per channel with pagination
      (follow `nextPageToken` to exhaustion), batched `videos.list` (chunks of 50 ids) for
      `recordingDetails.location`; merges using the channel's configured label as `category`.
      Base URL / API key sourced from `TestConfig` (test mode) or compiled `String.fromEnvironment`
      (production, via `--dart-define-from-file=config/secrets.env`).
- [ ] T010 `lib/data/local/video_cache.dart`: `shared_preferences`-backed store — `read()`/`write()`
      of the merged video list as JSON.
- [ ] T011 `lib/data/video_repository.dart`: cache-first read; `refresh()` fetches network, replaces
      cache on success, keeps serving the stale cache (no error) on failure if cache is non-empty;
      surfaces an error state only when there's nothing cached.

## Phase 4 — Auth UI (Iteration 1 → AC-LOGIN-01/02/03)
- [ ] T012 `presentation/auth/auth_providers.dart`: Riverpod `StateNotifier<AuthState>` wired to
      `TestConfig` (mock sign-in) and `google_sign_in` (real sign-in).
- [ ] T013 `presentation/auth/login_screen.dart`: `screen_login`, `login_google_button`,
      `login_error_message`.
- [ ] T014 `presentation/home/home_screen.dart` shell + `logout_button`, routes back to
      `LoginScreen` on sign-out.

## Phase 5 — Video list (Iteration 2 → AC-LIST-01/02/03, AC-COUNT-01)
- [ ] T015 `presentation/home/home_view_model.dart`: sealed `HomeViewState`
      (Loading/Content/Empty/Error), loads via `VideoRepository`, exposes `refresh()`.
- [ ] T016 `presentation/home/video_list_item.dart`: row with thumbnail/title/description,
      `video_list_item`, tap → external link (list index 0 → `VIDEO_ID_1`-equivalent URL).
- [ ] T017 Wire `video_list`, `video_count`, `refresh_control`, `loading_indicator`, `error_view`,
      `error_retry_button` into `HomeScreen`.

## Phase 6 — Cache / filter / sort (Iteration 3 → AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
- [ ] T018 Verify stale-cache fallback end-to-end (airplane mode relaunch keeps `video_list_item`s,
      no `error_view`).
- [ ] T019 `presentation/home/filter_screen.dart`: full-screen panel (replaces list), one option per
      configured channel label (exact-text match, no extra copy) + "All"; `filter_apply_button`.
- [ ] T020 `presentation/home/sort_screen.dart`: full-screen panel, date asc/desc + title asc/desc;
      descending-date label ends in "Newest" (matches `(?i)date.*(desc|newest)` as a full-string
      regex); `sort_apply_button`.

## Phase 7 — Map (Iteration 4 → AC-MAP-01/02/03)
- [ ] T021 `presentation/map/map_screen.dart`: `flutter_map` with OSM tiles, `screen_map`, marker per
      located video wrapped in `Semantics(identifier:'map_marker')`, plus a chip-row fallback for
      parity/visibility.
- [ ] T022 Detail bottom sheet: `detail_bottom_sheet`, `detail_video_url` (exact
      `youtube.com/watch?v=…`), `detail_open_youtube_button`.

## Phase 8 — External links (cross-cutting → AC-LIST-03, AC-MAP-03, AC-LINK-01)
- [ ] T023 `presentation/external_link/external_link_notifier.dart` + banner widget lifted to the
      app root (shared by list + map): `captureExternalLinks=true` → `external_open_url`;
      `=false` → real `url_launcher` open, `external_open_error` on throw/failure.

## Phase 9 — Tests & quality
- [ ] T024 Unit tests: `auth_test.dart`, `sort_test.dart`, `filter_test.dart`,
      `data/video_cache_test.dart` (persistence round-trip).
- [ ] T025 `flutter analyze` clean (no errors).

## Phase 10 — Validation
- [ ] T026 Build debug/release APK, install on device `25251FDF60029V`.
- [ ] T027 `adb reverse tcp:8090 tcp:8090` (physical device reaching the host mock at
      `127.0.0.1:8090`); run every `flows/AC-*.yaml` with
      `maestro --device 25251FDF60029V test -e APP_ID=com.example.ytdash_flutter -e
      MOCK_API_BASE=http://127.0.0.1:8090 -e AUTHORIZED_EMAIL=... -e UNAUTHORIZED_EMAIL=...`.
      Iterate until all pass.

## Phase 11 — Real mode
- [ ] T028 Real `google_sign_in` flow + email whitelist (`user1@example.com,
      user2@example.com` default), real API base URL swap, `apiKey` via `--dart-define-from-file`.

## Phase 12 — Wrap-up
- [ ] T029 `BUILD-REPORT.md`.
- [ ] T030 Create `.build-complete` only once every flow passes.
