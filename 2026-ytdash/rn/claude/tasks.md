# Tasks — YouTube Dashboard ("ytdash") · RN/Expo

> Spec-Kit `tasks` artifact, dependency-ordered. Derived from `plan.md`. `[P]` = parallelizable.
> Each task cites the AC(s) / constitution clause it serves.

## Phase 0 — Native seam & scaffolding
- [x] T001 Local Expo module `test-config`: Kotlin `getConfig()` reads `intent.extras` → JS. (§4)
- [x] T002 Install deps: zustand, async-storage, react-native-webview, expo-linking, expo-build-properties.
- [x] T003 `app.json`: cleartext traffic, package `com.example.ytdash_rn`, intent-filter for https.

## Phase 1 — Config & domain (pure, unit-tested)
- [x] T010 `config/testConfig.ts` — merge native extras with defaults → `AppConfig`. (§4)
- [x] T011 `config/channels.ts` — load `config/channels.json`. (spec §Iteration 2)
- [x] T012 [P] `domain/types.ts` — `Video`, `AppConfig`, `UiState<T>`.
- [x] T013 [P] `domain/auth.ts` — `isAuthorized(email, whitelist)`. (AC-LOGIN-01/02)
- [x] T014 [P] `domain/sort.ts` — date asc/desc, title asc/desc. (AC-SORT-01)
- [x] T015 [P] `domain/filter.ts` — filter by source-channel label. (AC-FILTER-01)

## Phase 2 — Data layer
- [x] T020 `data/youtubeApi.ts` — paginate every channel, merge/dedupe by videoId, tag category =
  channel label, `videos.list` for `recordingDetails.location`. (AC-LIST-01, AC-COUNT-01, AC-MAP-01)
- [x] T021 `data/cache.ts` — AsyncStorage load/save last-good list + timestamp. (AC-CACHE-01)
- [x] T022 `data/repository.ts` — network→cache, stale-fallback on error. (AC-CACHE-01, AC-LIST-02)
- [x] T023 `data/auth/*` — AuthService interface + Mock + Google impls. (AC-LOGIN-*)

## Phase 3 — State
- [x] T030 `state/store.ts` — zustand: config, auth, videos, UiState, sort/filter, external-open seam.

## Phase 4 — UI (all required testIDs; loading/empty/error everywhere)
- [x] T040 `ui/LoginScreen` — `screen_login`, `login_google_button`, `login_error_message`. (AC-LOGIN-*)
- [x] T041 `ui/HomeScreen` — `screen_home`, `video_list`, `video_list_item`, `video_count`,
  `refresh_control`, `filter_button`/`filter_apply_button`, `sort_button`/`sort_apply_button`,
  `map_nav_button`, `overflow_menu_button`/`logout_button`. (AC-LIST-*, AC-COUNT/SORT/FILTER-01)
- [x] T042 `ui/MapScreen` — `screen_map`, Leaflet WebView, native `map_marker` row. (AC-MAP-01)
- [x] T043 `ui/DetailSheet` — `detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`. (AC-MAP-02/03)
- [x] T044 `ui/ExternalOpenBanner` (root) — `external_open_url` / `external_open_error`. (AC-LIST-03, AC-MAP-03, AC-LINK-01)
- [x] T045 `ui/StateViews` — `loading_indicator`, `error_view`, `error_retry_button`. (§6)
- [x] T046 `App.tsx` — read config once, app-state machine, mount root banner.

## Phase 5 — Verify
- [x] T050 Unit tests: auth, sort, filter, cache round-trip. (§2)
- [x] T051 `expo prebuild -p android`, `assembleRelease`, install on `25251FDF60029V`.
- [x] T052 Run `flows/AC-*.yaml` vs mock; iterate to 14/14.
- [x] T053 `BUILD-REPORT.md`; create `.build-complete` only after all flows pass.
