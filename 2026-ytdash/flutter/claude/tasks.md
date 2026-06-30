# Tasks — YouTube Dashboard (Flutter)

> Spec-Kit `/tasks` artifact: dependency-ordered, traced to the acceptance criteria. All complete.

## Phase 0 — Foundation
- [x] T001 Pick stack, write `plan.md`.
- [x] T002 Add deps (`provider`, `http`, `shared_preferences`, `flutter_map`, `latlong2`,
  `url_launcher`, `google_sign_in`); bundle `config/channels.json` as an asset.
- [x] T003 Android test-mode plumbing: `MainActivity` MethodChannel for intent extras; INTERNET
  permission, `usesCleartextTraffic`, url_launcher `<queries>`. → constitution §4

## Phase 1 — Core + data (constitution §1.1 layer c)
- [x] T010 `core/test_config.dart` — read extras (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`,
  `apiKey`, `authorizedEmails`, `captureExternalLinks`); base-URL + whitelist resolution.
- [x] T011 `core/result.dart` — sealed `Result`/`Failure`. → §1.6
- [x] T012 `data/models/video.dart` — domain model + JSON.
- [x] T013 `data/channel_config.dart` — load configured channels.
- [x] T014 `data/youtube_api.dart` — search.list (paginated) per channel, merge/dedupe,
  videos.list location enrichment. → AC-LIST-01, AC-COUNT-01, anti-overfit
- [x] T015 `data/video_cache.dart` — shared_preferences persistence. → AC-CACHE-01
- [x] T016 `data/video_repository.dart` — abstraction + impl: network→save, stale-fallback. → §1.2, §1.5

## Phase 2 — Domain (layer b)
- [x] T020 `domain/auth.dart` — whitelist policy. → AC-LOGIN-01/02
- [x] T021 `domain/video_query.dart` — filter / sort / categories. → AC-FILTER-01, AC-SORT-01

## Phase 3 — Presentation (layer a)
- [x] T030 `widgets/test_id.dart` — `Semantics(identifier)` + merge rule. → §3
- [x] T031 `presentation/*_controller.dart` — auth / video / external-open view-state. → §1.3
- [x] T032 `login_screen.dart` — `screen_login`, `login_google_button`, `login_error_message`. → AC-LOGIN-01/02
- [x] T033 `home_screen.dart` — `screen_home`, `video_list`/`video_list_item`, `video_count`,
  `refresh_control`, `filter_button`/`filter_apply_button`, `sort_button`/`sort_apply_button`,
  `logout_button`, `map_nav_button`, error/loading/empty states. → AC-LIST-*, AC-COUNT, AC-FILTER,
  AC-SORT, AC-LOGIN-03
- [x] T034 `map_screen.dart` — `screen_map`, `map_marker` chips + flutter_map pins,
  `detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`. → AC-MAP-01/02/03
- [x] T035 `widgets/external_open_banner.dart` + app-root wiring — `external_open_url`,
  `external_open_error`. → AC-LIST-03, AC-MAP-03, AC-LINK-01
- [x] T036 `app.dart` / `main.dart` — providers, ensureSemantics, root login/home switch.

## Phase 4 — Validation
- [x] T040 Unit tests: auth, filter, sort, cache round-trip (`test/domain_test.dart`).
- [x] T041 `flutter analyze` clean (0 errors), `flutter test` green.
- [x] T042 Build release APK, install on `25251FDF60029V`, `adb reverse tcp:8090`.
- [x] T043 Run `flows/` against the mock; iterate to **14/14**, 3× (no flakiness).
- [x] T044 `BUILD-REPORT.md`; create `.build-complete`.
