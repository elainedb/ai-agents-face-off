# Tasks: ytdash (Flutter)

**Input**: `plan.md` (this workspace) + `spec/spec.md` + `spec/acceptance-criteria.md`
**Tests**: unit tests are explicitly required by the constitution (§2 quality bar), so included.

> Iterations below mirror `spec/spec.md`'s 4 iterations (which map to `AC-*` groups), not
> independent user stories — the AC suite exercises the whole app, so "independently shippable"
> doesn't apply the way it would for a multi-tenant web feature. Still organized so each iteration
> is independently *testable* against its own AC group once Setup+Foundational land.

## Phase 1: Setup
- [x] T001 Update `pubspec.yaml`: add `flutter_riverpod`, `http`, `shared_preferences`,
      `flutter_map`, `latlong2`, `google_sign_in`, `url_launcher`; bundle `config/channels.json` as
      an asset.
- [x] T002 `flutter pub get`; confirm `flutter analyze` is clean on the scaffold.
- [x] T003 [P] Create `lib/domain`, `lib/data`, `lib/presentation`, `lib/core` folder skeleton.

## Phase 2: Foundational (blocks all iterations)
- [x] T004 `lib/core/test_config.dart` — `TestConfig` model + `MethodChannel('ytdash/testconfig')`
      reader (uiTestMode, mockAuthEmail, apiBaseUrl, apiKey, authorizedEmails, captureExternalLinks).
- [x] T005 `android/app/src/main/kotlin/.../MainActivity.kt` — handle the `ytdash/testconfig`
      channel from `intent.extras`; override `onNewIntent` to keep extras fresh.
- [x] T006 `android/app/src/main/AndroidManifest.xml` — cleartext traffic (mock server is http) +
      confirm INTERNET permission.
- [x] T007 `lib/domain/entities/video.dart` — the `Video` entity all layers share.
- [x] T008 `lib/main.dart` — `WidgetsFlutterBinding.ensureInitialized()`,
      `SemanticsBinding.instance.ensureSemantics()`, load `TestConfig`, `ProviderScope` root,
      `MaterialApp` with `screen_login`/`screen_home`/`screen_map` routes.
- [x] T009 `lib/presentation/app_root.dart` — global external-open banner
      (`external_open_url`/`external_open_error`) lifted to app root per cross-framework-setup note.

**Checkpoint**: app builds and launches to a blank login screen honoring launch extras.

## Phase 3: Iteration 1 — Auth & access control (AC-LOGIN-01/02/03)
### Tests
- [x] T010 [P] `test/domain/whitelist_test.dart` — authorized/unauthorized/case-sensitivity cases.

### Implementation
- [x] T011 [P] `lib/domain/auth/whitelist.dart` — pure `isAuthorized(email, whitelist)`.
- [x] T012 `lib/presentation/auth/auth_controller.dart` — Riverpod notifier: mock sign-in (test
      mode) vs. `google_sign_in` (real), whitelist check, sign-out.
- [x] T013 `lib/presentation/auth/login_screen.dart` — `screen_login`, `login_google_button`,
      `login_error_message`.
- [x] T014 `lib/presentation/home/home_screen.dart` (stub) — `screen_home`, `logout_button`
      (+ `overflow_menu_button` if behind a menu) wired to `auth_controller.signOut()`.

**Checkpoint**: AC-LOGIN-01/02/03 flows pass standalone.

## Phase 4: Iteration 2 — Video list (AC-LIST-01/02/03, AC-COUNT-01)
### Tests
- [x] T015 [P] `test/domain/video_sort_test.dart` and `video_filter_test.dart` written now (used
      more in iteration 3, but the `Video` sort key / category fields are locked here).

### Implementation
- [x] T016 [P] `lib/data/remote/youtube_api_client.dart` — `search.list` per channel in
      `config/channels.json`, follow `nextPageToken` until exhausted, then batch `videos.list` for
      `recordingDetails`/`contentDetails`; category = the *channel's own config label*, not
      `snippet.channelTitle` or `categoryId` (real-API-safe per `youtube-api.md`).
- [x] T017 `lib/data/remote/youtube_dtos.dart` — JSON → `Video` mapping, dedupe by `id`.
- [x] T018 `lib/domain/repositories/video_repository.dart` — abstract interface.
- [x] T019 `lib/data/video_repository_impl.dart` — network fetch (all channels, all pages) with
      Result-style error handling; no cache logic yet (iteration 3 adds it) beyond an in-memory hold.
- [x] T020 `lib/presentation/home/home_controller.dart` — `AsyncNotifier` exposing
      `UiState<List<Video>>` (Loading/Empty/Content/Error), `video_count` = total loaded count.
- [x] T021 `lib/presentation/home/home_screen.dart` — `video_list`, `video_list_item` (title,
      thumbnail, description), `video_count` in the title, `refresh_control`, `loading_indicator`,
      `error_view`/`error_retry_button`.
- [x] T022 Tap `video_list_item` → `lib/core/external_launch.dart` open (captured in test mode via
      `external_open_url`, real launch via `url_launcher` otherwise, `external_open_error` on
      failure).

**Checkpoint**: AC-LIST-01/02/03 + AC-COUNT-01 pass standalone.

## Phase 5: Iteration 3 — Cache, filter, sort (AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
### Tests
- [x] T023 [P] `test/data/video_cache_test.dart` — write then read back a video list; persistence
      round-trip (constitution §2's required persistence test).

### Implementation
- [x] T024 `lib/data/local/video_cache.dart` — `shared_preferences` JSON read/write/clear.
- [x] T025 Wire cache into `video_repository_impl.dart` — replace-on-successful-refresh,
      stale-cache-fallback on network error, cache is what `home_controller` actually reads
      (constitution §1.5 single source of truth).
- [x] T026 `lib/domain/filtering/video_filter.dart` + `test/domain/video_filter_test.dart` —
      filter-by-category-label (pure).
- [x] T027 `lib/domain/sorting/video_sort.dart` + `test/domain/video_sort_test.dart` — sort by date
      (asc/desc) and title (pure).
- [x] T028 `lib/presentation/home/filter_sheet.dart` (`filter_button`, `filter_apply_button`) and
      `lib/presentation/home/sort_sheet.dart` (`sort_button`, `sort_apply_button`) — **replace the
      list while open** (not overlay it) per cross-framework-setup §D.2 text-collision rule; sort
      labels end with the regex keyword the flows match (`(?i)date.*(desc|newest)` etc.) per §D.3.

**Checkpoint**: AC-CACHE-01/FILTER-01/SORT-01 pass standalone; iteration 2 ACs still pass.

## Phase 6: Iteration 4 — Map (AC-MAP-01/02/03, AC-LINK-01)
### Implementation
- [x] T029 `lib/presentation/map/map_screen.dart` — `screen_map`, `flutter_map` centered/fit to
      located videos, each marker wrapped `Semantics(identifier: 'map_marker')`; fallback "Markers"
      chip row (also `map_marker`) for robustness.
- [x] T030 `map_nav_button` on `home_screen.dart` navigating to `map_screen.dart`.
- [x] T031 `lib/presentation/map/marker_detail_sheet.dart` — `detail_bottom_sheet`,
      `detail_video_url` (exact `youtube.com/watch?v=…`), `detail_open_youtube_button` wired to the
      same `external_launch.dart` used by the list.
- [x] T032 Real external-link smoke path (AC-LINK-01): confirm `url_launcher` failure surfaces
      `external_open_error` rather than throwing/no-op, with `captureExternalLinks=false`.

**Checkpoint**: all 12 ACs pass standalone iterations; run the full suite together next.

## Phase 7: Real-mode wiring
- [x] T033 `google_sign_in` real path in `auth_controller.dart`, gated so it only runs when
      `uiTestMode=false`/no `mockAuthEmail`.
- [x] T034 Confirm `apiBaseUrl`/`apiKey` swap is a pure runtime change (no rebuild) by pointing a
      built APK at `https://www.googleapis.com` + the real key from `config/secrets.env` and
      checking the list/map populate.

## Phase 8: Polish & validation
- [x] T035 `flutter analyze` — zero errors.
- [x] T036 `flutter test` — all unit tests green.
- [x] T037 Build APK, install on `25251FDF60029V`, run
      `maestro --device 25251FDF60029V test -e ... flows/` against the mock; iterate until 12/12.
- [x] T038 Write `BUILD-REPORT.md`.
- [x] T039 Create `.build-complete` (only once T037 is a clean 12/12 run).

## Dependencies
Setup → Foundational → Iteration 1 → Iteration 2 → Iteration 3 → Iteration 4 → Real-mode wiring →
Polish. Iterations are sequential here (not parallel workstreams) because the AC suite drives the
same compiled app end-to-end and later iterations reuse widgets/state from earlier ones (e.g. the
external-link banner from iteration 2 is reused by iteration 4's map sheet).
