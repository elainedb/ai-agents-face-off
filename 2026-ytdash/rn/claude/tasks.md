# Tasks — ytdash (React Native / Expo)

Derived from `plan.md`. Ordered so each task is independently buildable/testable where possible.

## Phase 0 — Scaffolding
- [x] T001 Install deps: expo-router, react-native-webview, async-storage, zustand, screens,
      safe-area-context, gesture-handler, expo-auth-session/web-browser/crypto, build-properties.
- [x] T002 Scaffold local Expo module `modules/test-config` (Kotlin `getConfig()` reading intent
      extras); JS wrapper + types.
- [x] T003 Switch entry point to `expo-router/entry`; delete legacy `App.tsx`; configure
      `app.json` (scheme, plugins, permissions, cleartext).

## Phase 1 — Domain layer (pure, unit-tested)
- [x] T010 `src/domain/types.ts` — `Video`, `SourceChannel`, `SortKey`, `SortDirection`.
- [x] T011 `src/domain/auth.ts` — `isAuthorizedEmail`; unit tests.
- [x] T012 `src/domain/filterSort.ts` — `filterByCategory`, `sortVideos`; unit tests.

## Phase 2 — Data layer
- [x] T020 `src/data/channels.ts` — load `config/channels.json`.
- [x] T021 `src/data/youtubeApi.ts` — `search.list` w/ pagination, `videos.list` (chunked ids),
      base URL/key injected (not hardcoded).
- [x] T022 `src/data/cacheStore.ts` — AsyncStorage get/set + timestamp; persistence unit test.
- [x] T023 `src/data/videoRepository.ts` — aggregate all channels, dedupe, attach location,
      cache-write-through, stale-fallback on network error.
- [x] T024 `src/data/container.ts` — DI wiring.

## Phase 3 — State
- [x] T030 `src/state/testConfig.ts` — load native module config once at boot, JS-side defaults
      outside test mode.
- [x] T031 `src/state/authStore.ts` — sign-in (mock + google), whitelist check, sign-out, error.
- [x] T032 `src/state/videoStore.ts` — status machine, load/refresh, filter/sort application.
- [x] T033 `src/state/externalLinkStore.ts` — capture-vs-real external link handling, root banner
      state.

## Phase 4 — Screens & selector contract
- [x] T040 `app/_layout.tsx` — boot sequence + `ExternalLinkBanner` mounted at root.
- [x] T041 `app/login.tsx` — `screen_login`, `login_google_button`, `login_error_message`.
- [x] T042 `app/home.tsx` — `screen_home`, `video_list`, `video_list_item`, `video_count`,
      `logout_button`, `refresh_control`, `filter_button`/`filter_apply_button`,
      `sort_button`/`sort_apply_button`, `map_nav_button`, `loading_indicator`, `error_view`,
      `error_retry_button`.
- [x] T043 `app/map.tsx` — `screen_map`, `LeafletMap` + `MapMarkers` (`map_marker`),
      `DetailBottomSheet` (`detail_bottom_sheet`, `detail_video_url`,
      `detail_open_youtube_button`).
- [x] T044 `src/components/ExternalLinkBanner.tsx` — `external_open_url`, `external_open_error`.

## Phase 5 — Real-mode wiring
- [x] T050 Google OAuth via `expo-auth-session` for non-test-mode sign-in.
- [x] T051 Real `Linking.openURL` path with try/catch → `external_open_error`.
- [x] T052 Runtime `apiBaseUrl`/`apiKey` swap verified against real API shapes (code path shared
      with mock).

## Phase 6 — Validation
- [x] T060 `npx tsc --noEmit` clean.
- [x] T061 `npx eslint .` (or `expo lint`) clean (warnings ok).
- [x] T062 `npm test` (jest) green.
- [x] T063 Build APK (`eas build` local / `expo run:android --variant release` /
      `./gradlew assembleRelease`), install on `25251FDF60029V`.
- [x] T064 Run `maestro --device 25251FDF60029V test flows/` against the mock; iterate until
      12/12 AC pass.
- [x] T065 Write `BUILD-REPORT.md`.
- [x] T066 Create `.build-complete` once T064 is fully green.
