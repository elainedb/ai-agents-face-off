# Tasks — YouTube Dashboard ("ytdash"), Flutter build

> Spec-Kit `/tasks` artifact. Dependency-ordered, traceable to acceptance criteria.

## Phase 0 — Project setup
- [x] T001 Add deps: `provider`, `http`, `shared_preferences`, `url_launcher`, `flutter_map`,
  `latlong2`, `google_sign_in`. Bundle `config/channels.json` as an asset.
- [x] T002 Android: cleartext to mock (`usesCleartextTraffic`), `MainActivity` MethodChannel for
  intent extras, `<queries>` for `https` VIEW intent (url_launcher).

## Phase 1 — Data + domain  (constitution §1)
- [x] T010 `Video` model + JSON mapping for `search.list` and `videos.list` shapes.
- [x] T011 `YoutubeApi`: per-channel `search.list` with `nextPageToken` pagination; `videos.list`
  batched for locations. No catch-all. → AC-COUNT-01
- [x] T012 `VideoCache` (shared_preferences JSON): write/read; single source of truth. → AC-CACHE-01
- [x] T013 `VideoRepository`: aggregate all channels, dedupe by id, persist, **stale-fallback** on
  network error. → AC-LIST-01/02, AC-CACHE-01
- [x] T014 Domain: `isAuthorized(email, whitelist)`, `sortVideos`, `filterByLabel`. → AC-LOGIN-02,
  AC-SORT-01, AC-FILTER-01

## Phase 2 — Test-mode plumbing  (constitution §4)
- [x] T020 `TestConfig.load()` via MethodChannel: uiTestMode, mockAuthEmail, apiBaseUrl, apiKey,
  authorizedEmails, captureExternalLinks.
- [x] T021 App-root `AppState`: auth state, mock vs real sign-in, external-link capture surface
  (`external_open_url` / `external_open_error`). → AC-LIST-03, AC-MAP-03, AC-LINK-01

## Phase 3 — Presentation  (constitution §3, §5, §5a)
- [x] T030 Login screen: `screen_login`, `login_google_button`, `login_error_message`. → AC-LOGIN-01/02
- [x] T031 Home screen: `screen_home`, `video_list`, `video_list_item`, `video_count`,
  `refresh_control`, `filter_button`/`filter_apply_button`, `sort_button`/`sort_apply_button`,
  `overflow_menu_button`/`logout_button`, `map_nav_button`, loading/empty/error states.
  → AC-LIST-*, AC-COUNT-01, AC-FILTER-01, AC-SORT-01, AC-LOGIN-03
- [x] T032 Map screen: `screen_map`, flutter_map + `map_marker` (widget + chip row),
  `detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`. → AC-MAP-01/02/03

## Phase 4 — Quality
- [x] T040 Unit tests (auth, sort, filter) + cache round-trip test.
- [x] T041 `flutter analyze` clean.

## Phase 5 — Validation & real mode
- [x] T050 Build APK; `adb reverse`; run `flows/AC-*.yaml` on `25251FDF60029V`; iterate to 14/14.
- [x] T051 Real mode: real Google Sign-In + whitelist; base URL/key swap via extras (no rebuild).
- [x] T052 `BUILD-REPORT.md`; create `.build-complete` only after all flows pass.
