# Tasks — ytdash (Flutter)

> Spec-Kit `tasks` artifact, generated from `plan.md`. Ordered by dependency; iteration numbers map
> to `spec/spec.md`.

## Setup
- [x] T001 Add dependencies (`flutter_riverpod`, `http`, `shared_preferences`, `flutter_map`,
      `latlong2`, `url_launcher`, `google_sign_in`) via `flutter pub add`.
- [x] T002 AndroidManifest: `usesCleartextTraffic=true` (mock is http), confirm `INTERNET`
      permission present.
- [x] T003 `MainActivity.kt`: `ytdash/testconfig` MethodChannel reading `intent.extras`.
- [x] T004 Bundle `config/channels.json` as a Flutter asset (declared in `pubspec.yaml`).

## Iteration 1 — Auth & access control (AC-LOGIN-01/02/03)
- [x] T010 `domain/auth/auth_whitelist.dart` — pure `isAuthorized(email, whitelist)`.
- [x] T011 `core/test_config.dart` — `TestConfig` model + `MethodChannel` loader with production
      fallback (default whitelist, default base URL, `--dart-define` key).
- [x] T012 `state/auth_controller.dart` — `AuthState` sealed (initial/authenticating/authenticated/
      unauthorized/loggedOut); mock-auth path (uiTestMode) vs real `google_sign_in` path.
- [x] T013 `features/login/login_screen.dart` — `screen_login`, `login_google_button`,
      `login_error_message`.
- [x] T014 `features/home/home_screen.dart` shell — `screen_home`, logout (`logout_button`) back to
      login.

## Iteration 2 — Video list (AC-LIST-01/02/03, AC-COUNT-01, AC-LINK-01)
- [x] T020 `data/models/video.dart`.
- [x] T021 `data/remote/youtube_api_client.dart` — `search.list` pagination per channel;
      `videos.list` batched location/detail fetch.
- [x] T022 `data/repository/video_repository.dart` (abstract) + `_impl.dart` — iterate
      `config/channels.json`, merge/dedupe by id, persist to cache.
- [x] T023 `state/home_controller.dart` — `HomeState` (loading/content/empty/error), `load()`,
      `refresh()`.
- [x] T024 List UI — `video_list`, `video_list_item` (title+thumbnail+description), `video_count`
      in the app-bar title, `loading_indicator`, `error_view` + `error_retry_button`,
      `refresh_control`.
- [x] T025 `state/external_link_controller.dart` (app-root) + `widgets/external_link_banner.dart` —
      `external_open_url` / `external_open_error`; row tap wires into it.

## Iteration 3 — Cache, filter, sort (AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
- [x] T030 `data/local/video_cache_store.dart` — `shared_preferences` JSON round-trip.
- [x] T031 Repository stale-fallback: network failure → serve last cached list, no `error_view`.
- [x] T032 `domain/filtering/video_filter.dart`, `domain/sorting/video_sort.dart` (pure).
- [x] T033 `features/home/filter_screen.dart` — full-screen route, plain-text category options
      (`filter_button` → push → tap label → instant apply → pop).
- [x] T034 `features/home/sort_screen.dart` — full-screen route, `Date - Newest`/`Date - Oldest`/
      `Title A-Z`/`Title Z-A` (`sort_button` → push → tap label → instant apply → pop).

## Iteration 4 — Map (AC-MAP-01/02/03)
- [x] T040 `features/map/map_screen.dart` — `screen_map`, `flutter_map` with OSM tiles,
      `Semantics(identifier:'map_marker')` on each real marker widget + a guaranteed marker-chip
      row (same id) for parity/off-viewport safety.
- [x] T041 In-tree `detail_bottom_sheet` overlay (Align+Material, not a modal route) —
      `detail_video_url`, `detail_open_youtube_button` wired to the shared
      `ExternalLinkController`.
- [x] T042 `map_nav_button` in the home app bar pushes `MapScreen`.

## Cross-cutting
- [x] T050 Unit tests: `auth_whitelist_test.dart`, `video_sort_test.dart`, `video_filter_test.dart`,
      `video_cache_store_test.dart`.
- [x] T051 `flutter analyze` clean.
- [x] T052 Build APK, install on `25251FDF60029V`.
- [x] T053 Run `maestro --device 25251FDF60029V test` against the mock for all `flows/AC-*.yaml`;
      iterate until 12/12 pass. (14/14 including AC-LOGIN-03/AC-LINK-01, 2 consecutive clean runs.)
- [x] T054 Real-mode smoke: point at `https://www.googleapis.com` + real key; confirm list/map/
      external-open still work (`flows/REAL-LIST.yaml`, `flows/REAL-CACHE.yaml` as a sanity check,
      not scored). Both passed against live data.
- [x] T055 `BUILD-REPORT.md` + create `.build-complete` once all mock ACs pass.
