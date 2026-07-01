# Tasks — YouTube Dashboard ("ytdash"), RN/Expo

> Spec-Kit `tasks` artifact. Dependency-ordered. Each task lists the AC(s) / constitution
> section it serves. `[x]` = done.

## Phase 0 — Setup
- [x] T001 Install deps: zustand, async-storage, react-native-webview, expo-build-properties, zod, expo-linking.
- [x] T002 `usesCleartextTraffic: true` via expo-build-properties (app.json). (§cross-framework A)

## Phase 1 — Native seam (constitution §4)
- [x] T010 Local Expo module `TestConfig` (Kotlin) reading `currentActivity.intent.extras`.
- [x] T011 JS `state/testConfig.ts` loader coercing extras (bool/string) → typed `TestConfig`.

## Phase 2 — Data layer (constitution §1.1, §1.5)
- [x] T020 `data/types.ts`: `Video`, `Result<T>`, `UiState<T>`, zod schemas for search/videos responses.
- [x] T021 `data/api.ts`: per-channel `search.list` pagination + merge/dedupe + `videos.list` enrich. (spec §Iter2, AC-COUNT-01)
- [x] T022 `data/cache.ts`: AsyncStorage snapshot (24h TTL, replace-on-refresh, stale-fallback). (AC-CACHE-01)

## Phase 3 — Domain layer (pure, unit-tested) (constitution §1.1, §2)
- [x] T030 `domain/auth.ts`: whitelist check. (AC-LOGIN-01/02)
- [x] T031 `domain/sort.ts`: by date/title, asc/desc. (AC-SORT-01)
- [x] T032 `domain/filter.ts`: by category label. (AC-FILTER-01)

## Phase 4 — State (constitution §1.2, §1.3)
- [x] T040 Zustand stores: auth, videos (hydrate→refresh, UiState), ui (filter/sort/screen), external.
- [x] T041 DataSource built from runtime TestConfig (DI seam).

## Phase 5 — UI (constitution §3, §5, §5a)
- [x] T050 Root `App.tsx`: providers, screen switch, app-root `external_open_url`/`external_open_error` banner.
- [x] T051 `LoginScreen`: screen_login, login_google_button, login_error_message. (AC-LOGIN-*)
- [x] T052 `HomeScreen`: screen_home, video_list(+item), video_count, refresh_control, filter/sort buttons+panels, map_nav_button, logout_button, loading/error views. (AC-LIST/COUNT/FILTER/SORT)
- [x] T053 `MapScreen`: screen_map, Leaflet WebView, native map_marker chips, detail_bottom_sheet(+url+open button). (AC-MAP-*)
- [x] T054 External open: capture→banner; real→Linking.openURL, catch→external_open_error. (AC-LIST-03, AC-LINK-01, AC-MAP-03)

## Phase 6 — Build & validate
- [x] T060 `expo prebuild --platform android`.
- [x] T061 `assembleRelease`; install on `25251FDF60029V`.
- [x] T062 Run `flows/AC-*.yaml` via Maestro; iterate app code until 14/14.

## Phase 7 — Real mode, tests, report
- [x] T070 Jest unit tests: auth, sort, filter, count, cache round-trip.
- [x] T071 Real-mode wiring: Google Sign-In path + whitelist; base URL/key swap documented.
- [x] T072 `BUILD-REPORT.md` (stack, AC results, deviations); `.build-complete` after flows pass.
</content>
