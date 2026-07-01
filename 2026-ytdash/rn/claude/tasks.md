# Tasks — YouTube Dashboard ("ytdash"), RN/Expo

> Spec-Kit `tasks` artifact: dependency-ordered, derived from `plan.md`. `[x]` = done. Each task
> notes the acceptance criteria it advances.

## Phase 0 — Setup
- [x] T001 Add deps: `zustand`, `@react-native-async-storage/async-storage`, `react-native-webview`,
  `zod`, `expo-build-properties`. Enable `usesCleartextTraffic` for the mock. (constitution §2/§4)
- [x] T002 Create local Expo module `modules/test-config` reading intent extras. (constitution §4)
- [x] T003 `resolveJsonModule` + strict TS.

## Phase 1 — Domain (pure, TDD-friendly) — blocks Phase 3/4
- [x] T010 `domain/models.ts` — `Video`, `watchUrl`.
- [x] T011 `domain/auth.ts` — `isAuthorized` (whitelist, case-insensitive). → AC-LOGIN-01/02
- [x] T012 `domain/sort.ts` — `sortVideos` + `SORT_OPTIONS` (labels end with keyword). → AC-SORT-01
- [x] T013 `domain/filter.ts` — `filterByCategory` + `availableCategories`. → AC-FILTER-01

## Phase 2 — Data access — blocks Phase 3
- [x] T020 `data/youtubeApi.ts` — iterate channels, follow `nextPageToken`, dedupe by id, enrich
  locations via `videos.list`. NO catch-all. → AC-COUNT-01, AC-LIST-01, AC-MAP-01
- [x] T021 `data/cache.ts` — AsyncStorage source of truth. → AC-CACHE-01
- [x] T022 `data/repository.ts` — network → save → stale-fallback on failure. → AC-CACHE-01, AC-LIST-02

## Phase 3 — State (observable view-state)
- [x] T030 `state/authStore.ts` — sign-in + whitelist + logout. → AC-LOGIN-01/02/03
- [x] T031 `state/videoStore.ts` — load, sort, filter, derived `visible()`, `status`. → most ACs
- [x] T032 `state/externalStore.ts` — capture vs real launch; `external_open_error`. → AC-LIST-03,
  AC-MAP-03, AC-LINK-01
- [x] T033 `state/navStore.ts` — home/map.

## Phase 4 — Presentation (selector contract §3)
- [x] T040 `ui/LoginScreen.tsx` — `screen_login`, `login_google_button`, `login_error_message`.
- [x] T041 `ui/HomeScreen.tsx` — `screen_home`, `video_list(_item)`, `video_count`,
  `refresh_control`, `filter_button`, `sort_button`, `map_nav_button`, `logout_button`,
  `loading_indicator`, `error_view`, `error_retry_button`; filter/sort panels replace list.
- [x] T042 `ui/MapScreen.tsx` — `screen_map`, Leaflet WebView, native `map_marker` chips,
  `detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`.
- [x] T043 `ui/ExternalBanner.tsx` — `external_open_url` / `external_open_error` at app root.
- [x] T044 `App.tsx` — wire auth-gated navigation + banner.

## Phase 5 — Build & validate
- [x] T050 `expo prebuild`; native module autolinks; build `assembleRelease` (debug-signed).
- [x] T051 `adb reverse tcp:8090` so the physical device reaches the mock at 127.0.0.1:8090.
- [ ] T052 Run `flows/AC-*.yaml` on device `25251FDF60029V`; iterate app code to 14/14.
- [ ] T053 Unit tests (auth/sort/filter/cache) green.
- [ ] T054 `BUILD-REPORT.md`; `.build-complete` after all flows pass.

## Phase 6 — Real mode
- [x] T060 Same build hits real YouTube by swapping `apiBaseUrl`+`apiKey` extras (runtime).
- [ ] T061 Real Google Sign-In: documented gap (no google-services.json in workspace).
