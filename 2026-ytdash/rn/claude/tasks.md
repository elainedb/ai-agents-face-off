# Tasks: ytdash (React Native / Expo)

**Input**: `plan.md`, `spec/spec.md`, `spec/acceptance-criteria.md`, `spec/constitution.md`
**Tests**: unit tests included per constitution §2 (domain + one persistence test).

## Phase 1: Setup
- [x] T001 Confirm Expo scaffold (`App.tsx`, `app.json` with `com.example.ytdash_rn`,
  `expo-build-properties` cleartext) — already present.
- [ ] T002 Install deps: zustand, @react-native-async-storage/async-storage,
  react-native-webview, expo-auth-session, expo-web-browser, expo-linking, jest/@types.
- [ ] T003 [P] Create `src/{domain,data,state,ui/screens,ui/components}` and `__tests__/` dirs.
- [ ] T004 [P] `npx expo prebuild -p android` to generate `android/` for the native module + release build.

## Phase 2: Foundational (blocks all screens)
- [ ] T005 Scaffold local Expo module `modules/testconfig` (`create-expo-module --local`); implement
  Kotlin `getTestConfig()` reading intent extras (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`,
  `apiKey`, `authorizedEmails`, `captureExternalLinks`); TS wrapper in `modules/testconfig/index.ts`.
- [ ] T006 [P] `src/domain/models.ts` — `Video`, `SourceChannel`, `TestConfig`, `ViewState` types.
- [ ] T007 [P] `src/domain/auth.ts` — `isAuthorizedEmail(email, whitelistCsv)`.
- [ ] T008 [P] `src/domain/sortFilter.ts` — `sortVideos(videos, key)`, `filterVideos(videos, label)`.
- [ ] T009 `src/data/testConfig.ts` — read native module once, typed defaults for non-test-mode.
- [ ] T010 [P] `src/data/channels.ts` — load `config/channels.json` (bundled JSON import).
- [ ] T011 `src/data/youtubeApi.ts` — `fetchAllVideos(channels, baseUrl, apiKey)`: per channel,
  loop `search.list` following `nextPageToken` until exhausted, merge+dedupe by id across channels,
  batch `videos.list` (chunks of 50 ids) for `recordingDetails.location`, map to `Video` with
  `category = channelTitle` from the search snippet.
- [ ] T012 `src/data/cache.ts` — `readCache()`/`writeCache(videos)` via AsyncStorage JSON blob.
- [ ] T013 `src/state/authStore.ts` — signed-in email, whitelist, `login()/logout()`.
- [ ] T014 `src/state/videoStore.ts` — `videos`, `viewState`, `filterLabel`, `sortKey`, `load()`,
  `refresh()` (cache-first, network refresh, stale-fallback on failure).
- [ ] T015 `src/state/externalLinkStore.ts` — `capturedUrl | errored`, `open(url, testConfig)`.

**Checkpoint**: data/domain/state layers exist and are unit-testable before any UI is wired.

## Phase 3: User Story — Auth (Iteration 1 / AC-LOGIN-01..03)
- [ ] T016 [P] `src/ui/screens/LoginScreen.tsx` — `screen_login`, `login_google_button`,
  `login_error_message`. Test-mode: `mockAuthEmail` skips the picker; else `expo-auth-session`.
- [ ] T017 `App.tsx` root screen-state machine (`'login'|'home'|'map'`) wired to `authStore`.
- [ ] T018 `logout_button` on `HomeScreen` header (always visible, no menu) → `authStore.logout()`.

**Checkpoint**: AC-LOGIN-01/02/03 drivable end-to-end.

## Phase 4: User Story — Video List (Iteration 2 / AC-LIST-01..03, AC-COUNT-01)
- [ ] T019 [P] `src/ui/components/VideoListItem.tsx` — row `testID="video_list_item"` (title as
  direct/aggregated text child, thumbnail, description).
- [ ] T020 `src/ui/screens/HomeScreen.tsx` — `screen_home`, `video_list` (FlatList), `video_count`
  in header text, `loading_indicator`, `error_view` + `error_retry_button`, `refresh_control` button.
- [ ] T021 Row tap → `externalLinkStore.open(video.youtubeUrl)`.
- [ ] T022 [P] `src/ui/components/ExternalLinkBanner.tsx` mounted at `App.tsx` root — renders
  `external_open_url` (capture mode) or performs `Linking.openURL` (real mode), catching failures
  into `external_open_error`.

**Checkpoint**: AC-LIST-01/02/03, AC-COUNT-01 drivable.

## Phase 5: User Story — Cache/Filter/Sort (Iteration 3 / AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
- [ ] T023 Wire `videoStore.load()` to read cache first, then fetch; on fetch failure with cache
  present, keep showing cache (no `error_view`); on fetch failure with no cache, show `error_view`.
- [ ] T024 [P] `src/ui/components/FilterPanel.tsx` — replaces the list while open; options = distinct
  labels from loaded videos; `filter_button` opens it, `filter_apply_button` confirms.
- [ ] T025 [P] `src/ui/components/SortPanel.tsx` — replaces the list while open; options "Date —
  newest first" / "Date — oldest first" / "Title A–Z" (labels end with the flow's regex keywords);
  `sort_button` opens it, `sort_apply_button` confirms.

**Checkpoint**: AC-CACHE-01, AC-FILTER-01, AC-SORT-01 drivable.

## Phase 6: User Story — Map (Iteration 4 / AC-MAP-01..03)
- [ ] T026 [P] `src/ui/components/MapMarkers.tsx` — horizontal `Pressable` row, one per located
  video, `testID="map_marker"`; tap → `videoStore.selectMarker(video)`.
- [ ] T027 `src/ui/screens/MapScreen.tsx` — `screen_map`, WebView+Leaflet HTML (OSM tiles, pins at
  each located video's lat/lng, `postMessage` on pin tap), `map_nav_button` added to `HomeScreen`.
- [ ] T028 [P] `src/ui/components/DetailBottomSheet.tsx` — absolute `View` (not `Modal`),
  `detail_bottom_sheet`, `detail_video_url` (exact watch URL text), `detail_open_youtube_button` →
  `externalLinkStore.open(selected.youtubeUrl)`.

**Checkpoint**: AC-MAP-01/02/03 drivable; full 12+2 AC surface implemented.

## Phase 7: Real-mode wiring (AC-LINK-01 + REAL-* smoke)
- [ ] T029 Confirm `apiBaseUrl`/`apiKey` extras override cleanly to `https://www.googleapis.com` +
  real key with zero code branching (same `fetchAllVideos` call).
- [ ] T030 `captureExternalLinks=false` path: real `Linking.openURL`, error → `external_open_error`.

## Phase 8: Tests
- [ ] T031 [P] `__tests__/auth.test.ts`
- [ ] T032 [P] `__tests__/sortFilter.test.ts`
- [ ] T033 [P] `__tests__/cache.test.ts` (AsyncStorage mock — persistence test per constitution §2)
- [ ] T034 `npx eslint .` clean (or documented warnings only, per constitution §2).

## Phase 9: Build & Validate
- [ ] T035 `cd android && ./gradlew assembleRelease`; `adb install -r` onto `25251FDF60029V`.
- [ ] T036 Start mock server (`python3 mock/youtube-mock-server.py --port 8090 --channels
  "<from config/channels.json>"`); `adb reverse tcp:8090 tcp:8090` (physical device).
- [ ] T037 `maestro --device 25251FDF60029V test -e APP_ID=com.example.ytdash_rn -e
  MOCK_API_BASE=http://127.0.0.1:8090 -e AUTHORIZED_EMAIL=... -e UNAUTHORIZED_EMAIL=... flows/`
  iterate to green.
- [ ] T038 Write `BUILD-REPORT.md`; create `.build-complete` only once all flows pass.

## Dependencies
Phase 2 blocks 3-7. Phases 3→4→5→6 are additive (each builds on the previous screen) but their
domain/data pieces (T006-T015) are all foundational. Phase 8 can run anytime after Phase 2. Phase 9
requires Phases 3-8 done.
