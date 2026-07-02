# Tasks: ytdash (React Native / Expo)

**Input**: `plan.md`, `spec/spec.md`, `spec/acceptance-criteria.md`, `spec/constitution.md`
**Tests**: included (constitution §2 requires domain + persistence unit tests)
**Organization**: grouped by iteration (matches spec.md's 4 iterations), each independently
runnable against the mock and checkable via its `AC-*` flows.

## Phase 1: Setup

- [x] T001 Read spec/constitution/acceptance-criteria/cross-framework-setup/youtube-api docs
- [x] T002 Confirm device (`25251FDF60029V`) + mock server (`127.0.0.1:8090`) reachable; `adb reverse tcp:8090 tcp:8090`
- [x] T003 Install deps: `zustand`, `@react-native-async-storage/async-storage`, `react-native-webview`, `expo-auth-session`, `expo-web-browser`, `expo-crypto`
- [x] T004 [P] Create `src/{domain,data,native,state,ui/screens,ui/components,__tests__}` folders
- [x] T005 [P] Configure jest (Expo preset) + `npm test` script; configure eslint (`expo lint`)

## Phase 2: Foundational (blocks all iterations)

- [x] T006 Scaffold local Expo module `modules/test-config` (`npx create-expo-module --local`), Kotlin
      `Function("get")` reading `appContext.currentActivity?.intent?.extras` → `{uiTestMode,
      mockAuthEmail, apiBaseUrl, apiKey, authorizedEmails, captureExternalLinks}`
- [x] T007 `src/native/testConfig.ts` — JS wrapper with production defaults (uiTestMode=false,
      apiBaseUrl=real YouTube host, apiKey='', authorizedEmails from `config/secrets.env`-style env)
- [x] T008 `src/state/testConfigStore.ts` — resolves once at boot (awaited in `App.tsx` before mounting screens)
- [x] T009 `src/domain/types.ts` — `Video`, `Result<T,E>`, `UiStatus`
- [x] T010 `expo prebuild` (android/) once the module exists; set `applicationId com.example.ytdash_rn`,
      `usesCleartextTraffic` (already in app.json), `INTERNET` permission

**Checkpoint**: app boots, reads launch extras, no screens yet.

## Phase 3: Iteration 1 — Authentication & access control (AC-LOGIN-01/02/03)

### Tests
- [x] T011 [P] `src/__tests__/auth.test.ts` — `isAuthorized()` allow/deny/case-sensitivity cases

### Implementation
- [x] T012 [P] `src/domain/auth.ts` — `isAuthorized(email, whitelist: string[]): boolean`
- [x] T013 `src/state/authStore.ts` — `status`, `email`, `errorMessage`, `signIn()`, `signOut()`
- [x] T014 `signIn()`: if `uiTestMode && mockAuthEmail` → skip Google, use that email; else real Google
      OAuth via `expo-auth-session` (best-effort; see plan.md Deviations)
- [x] T015 `src/ui/screens/LoginScreen.tsx` — `screen_login`, `login_google_button`, `login_error_message`
- [x] T016 `src/ui/screens/HomeScreen.tsx` shell — `screen_home` root, `logout_button` (+ optional
      `overflow_menu_button`), wired to `authStore.signOut()`
- [x] T017 `navStore` wiring: authorized → `home`; unauthorized → stay on `login` + show error

**Checkpoint**: AC-LOGIN-01/02/03 pass against the mock.

## Phase 4: Iteration 2 — Video list (AC-LIST-01/02/03, AC-COUNT-01, AC-LINK-01)

### Tests
- [x] T018 [P] `src/__tests__/sort.test.ts`, `filter.test.ts` (written against Phase 5 functions too;
      colocated here since both land before Phase 4 checkpoint)

### Implementation
- [x] T019 `src/data/channels.ts` — typed loader for `config/channels.json`
- [x] T020 `src/data/youtubeApi.ts` — `fetchChannelVideos(baseUrl, apiKey, channelId)` follows
      `nextPageToken` in a loop until exhausted (search.list); `fetchVideoDetails(baseUrl, apiKey,
      ids[])` batches ≤50 ids via videos.list for location/duration
- [x] T021 `src/data/videoRepository.ts` — `refresh()`: iterate ALL configured channels, merge+dedupe
      by id, hydrate details, persist, return `Result<Video[]>`; `load()`: read persisted cache
- [x] T022 `src/state/videoStore.ts` — `status`, `videos`, `refresh()`/`load()`, wraps repository
- [x] T023 `src/ui/components/VideoListItem.tsx` — `video_list_item` (title text carries the id/text
      Maestro asserts — RN aggregates descendant text onto the `testID`'d row automatically)
- [x] T024 HomeScreen: `video_list` (FlatList), `video_count` (title, total videos), `refresh_control`
      (pull-to-refresh AND a tappable control, since AC-LIST-02 taps it), `loading_indicator`,
      `error_view` + `error_retry_button`
- [x] T025 `src/state/externalLinkStore.ts` + `src/ui/components/ExternalLinkBanner.tsx` mounted once
      in `App.tsx` (root-level, per plan.md) — `external_open_url`, `external_open_error`
- [x] T026 Row tap → `openExternal(video.youtubeUrl)`: `captureExternalLinks` true → set banner text;
      false → `Linking.openURL` in try/catch → `external_open_error` on throw/`canOpenURL` false

**Checkpoint**: AC-LIST-01/02/03, AC-COUNT-01, AC-LINK-01 (list half) pass against the mock.

## Phase 5: Iteration 3 — Caching, filtering, sorting (AC-CACHE-01, AC-FILTER-01, AC-SORT-01)

### Tests
- [x] T027 [P] `src/__tests__/videoCache.test.ts` — AsyncStorage round-trip (write then read back equal)

### Implementation
- [x] T028 `src/data/videoCache.ts` — `save(videos)`/`load(): Video[] | null` via AsyncStorage JSON blob
- [x] T029 `videoRepository.refresh()`: on network failure, fall back to `videoCache.load()` (stale
      cache) instead of surfacing `error_view` — only a genuinely empty cache + failed fetch is an error
- [x] T030 `src/domain/sort.ts` — `sortVideos(videos, 'date', 'asc'|'desc')`
- [x] T031 `src/domain/filter.ts` — `filterVideosByCategory(videos, category | null)`
- [x] T032 `src/ui/components/SortPanel.tsx` / `FilterPanel.tsx` — replace the list while open (not an
      overlay on top of it — avoids text-collision per cross-framework-setup.md §D.2); labels end
      with the matched keyword (`"Date — Newest"`, `(?i)tech`) per §D.3
- [x] T033 HomeScreen: `filter_button`/`filter_apply_button`, `sort_button`/`sort_apply_button` wiring
      into `videoStore` filter/sort state; list re-renders from `sortVideos(filterVideosByCategory(...))`

**Checkpoint**: AC-CACHE-01, AC-FILTER-01, AC-SORT-01 pass against the mock.

## Phase 6: Iteration 4 — Map (AC-MAP-01/02/03, AC-LINK-01 map half)

### Implementation
- [x] T034 `src/ui/screens/MapScreen.tsx` — `screen_map` root; `map_nav_button` on HomeScreen navigates here
- [x] T035 Leaflet/OSM `react-native-webview` — plots a pin per video with `location` (human path only)
- [x] T036 `src/ui/components/MapMarkersOverlay.tsx` — native `Pressable` row, one per located video,
      `testID="map_marker"` (all share the id) — the Maestro-reachable affordance (constitution §5)
- [x] T037 `src/ui/components/DetailBottomSheet.tsx` — plain absolutely-positioned `View` (not RN
      `Modal`), `detail_bottom_sheet`, `detail_video_url` (exact `youtube.com/watch?v=…` text),
      `detail_open_youtube_button` — reuses the same `openExternal()` as the list row
- [x] T038 Tapping a marker (native chip OR WebView `postMessage` from a real pin tap) sets the same
      "selected video" state → same bottom sheet

**Checkpoint**: AC-MAP-01/02/03 pass against the mock; AC-LINK-01 passes for both list + map paths.

## Phase 7: Real-mode wiring

- [x] T039 Verify `apiBaseUrl=https://www.googleapis.com` + `apiKey` from `config/secrets.env` works
      unmodified through `youtubeApi.ts` (same parsing code, per youtube-api.md)
- [x] T040 Smoke-run against real API (list populates, map has markers, external link opens real YouTube)

## Phase 8: Validation & polish

- [x] T041 `npm run lint` — zero errors
- [x] T042 `npm test` — all unit tests pass
- [x] T043 `eas build`-free local build: `cd android && ./gradlew assembleRelease`
- [x] T044 `adb install -r` the release APK on `25251FDF60029V`
- [x] T045 `maestro --device 25251FDF60029V test -e APP_ID=com.example.ytdash_rn -e
      MOCK_API_BASE=http://127.0.0.1:8090 -e AUTHORIZED_EMAIL=... -e UNAUTHORIZED_EMAIL=... -e
      VIDEO_COUNT=8 -e FILTER_LABEL=... flows/` — iterate until all 14 flows pass
- [x] T046 Write `BUILD-REPORT.md`
- [x] T047 Create `.build-complete` (only once T045 is 14/14 green)

## Dependencies

- Phase 2 blocks everything (test-config module + prebuild needed before any screen can be
  Maestro-driven).
- Phase 3 (auth) blocks Phase 4 (list lives behind login).
- Phase 4 blocks Phase 5 (filter/sort operate on the loaded list) and Phase 6 (map nav button lives
  on the home screen).
- Phase 7/8 depend on all iterations being implemented.
