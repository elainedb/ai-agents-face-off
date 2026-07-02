# Build Report — ytdash (React Native / Expo)

## Stack (see `plan.md` for full rationale)
- **Framework**: Expo SDK 57, React Native 0.86, React 19, TypeScript (strict).
- **State**: zustand (`authStore`, `videoStore`, `externalLinkStore`).
- **Data**: `fetch` against the YouTube-Data-API-v3-shaped mock/real endpoints; pagination
  followed via `nextPageToken` per channel; `videos.list` batched (≤50 ids) for
  `recordingDetails.location`. Cache = `@react-native-async-storage/async-storage`, one JSON blob
  (`videos` + `fetchedAt`), replace-on-refresh, stale-fallback on network error.
- **Navigation**: none — a manual `'login'|'home'|'map'` screen-state machine in `App.tsx`, plus a
  `'list'|'filter'|'sort'` sub-mode in `HomeScreen`. Deliberate: 3 screens, always launched via
  UI-test-mode extras, so a router added risk (portal/host reachability, constitution §5a) with no
  functional benefit.
- **Map**: `react-native-webview` rendering a Leaflet/OSM HTML page (real pins, real tile layer) +
  a native horizontal row of `Pressable` chips (`testID="map_marker"`, one per located video) —
  the accessible affordance Maestro drives, per constitution §5/§C (WebView DOM markers are not
  a11y-reachable). WebView pin-tap also `postMessage`s into the same native selection handler, so
  a human tapping a real pin gets the same bottom sheet.
- **UI-test-mode**: a local Expo native module (`modules/testconfig`, Kotlin `Function("getTestConfig")`
  reading `currentActivity.intent.extras`), read once at `App.tsx`/screen mount via
  `src/data/testConfig.ts`.
- **Auth**: `mockAuthEmail` bypasses real sign-in entirely in UI-test-mode (what's scored). Real
  mode uses `expo-auth-session`'s generic `useAuthRequest` (not the `providers/google` wrapper —
  see Deviations) against Google's OAuth endpoints.
- **Tests**: Jest + ts-jest, 17 tests across `__tests__/auth.test.ts`,
  `__tests__/sortFilter.test.ts` (domain layer — whitelist, sort, filter), and
  `__tests__/cache.test.ts` (AsyncStorage-mocked persistence round-trip, per constitution §2).
- **Lint**: `eslint-config-expo` flat config — 0 errors, 10 warnings (all cosmetic:
  `Array<T>` vs `T[]`, unused `err` bindings, exhaustive-deps on intentionally-one-shot effects).

## 12+2-AC result (flows/AC-*.yaml — 14 files, matching acceptance-criteria.md's 14 rows)
Ran 3× on device `25251FDF60029V` against the local mock (`mock/youtube-mock-server.py`,
`--channels` built from `config/channels.json`, default `--page-size 2` to force pagination):

| Run | Result |
|---|---|
| 1 | 14/14 passed |
| 2 | 14/14 passed |
| 3 | 14/14 passed |

**min / median / max = 14/14 / 14/14 / 14/14** — no flakiness observed across 3 clean runs.
JUnit XML for each run is in `results/run3.xml`, `run4.xml`, `run5.xml` (the two earlier runs,
`run1`/`run2`, are debugging iterations kept for the record — see Issues found & fixed below).

`map_marker_fallback_used=true` — per constitution §5, the WebView/Leaflet map's DOM-rendered pins
are not accessibility-reachable, so `map_marker` is served by the native chip-row affordance
(expected/required for this stack, not a defect).

## Real-mode smoke checks (flows/REAL-*.yaml, not part of the scored 12-AC suite)
Run against `https://www.googleapis.com` with the real key from `config/secrets.env`, same APK,
only `apiBaseUrl`/`apiKey` extras changed:
- `REAL-LIST.yaml` — **passed**: live channel data aggregated from all 4 configured channels,
  list populates, no `error_view`.
- `REAL-CACHE.yaml` — **passed**: the first real video title survives an airplane-mode relaunch
  (fresh process), proving the AsyncStorage cache — not just "some list" — persists real data.

Screenshots of the final app (login/list/map, mock data) are in `screenshots/`.

## Issues found & fixed during self-validation
1. **`expo-auth-session/providers/google`'s `useAuthRequest` throws synchronously** (`invariant`
   inside a `useMemo`) when no platform client id is configured — this crashed the app on *every*
   launch, including UI-test-mode, since the hook is unconditional. No `google-services.json` or
   OAuth client id was provided in this workspace. Fixed by switching to the generic
   `AuthSession.useAuthRequest` + `useAutoDiscovery`-style config, which only builds the request in
   an effect and degrades to an inert `request=null` instead of crashing.
2. **`AuthSession.makeRedirectUri()` throws** in a standalone/release build with no `scheme` in
   `app.json`. Added `"scheme": "ytdashrn"` and pass it explicitly to `makeRedirectUri`, wrapped in
   try/catch as defense-in-depth (this path is never exercised in UI-test-mode).
3. **Header content rendered under the status bar** (RN edge-to-edge default) caused `logout_button`
   to be intermittently unreachable and the `external_open_url`/`external_open_error` banner to
   fail Maestro's "visible" check when anchored `top:0`. Fixed by adding `StatusBar.currentHeight`
   top padding to `HomeScreen`/`MapScreen`/`FilterPanel`/`SortPanel` headers, and moving the
   external-link banner to `bottom:0` (clear of any system chrome).
4. **Default sort order broke AC-LIST-03's "first row = `VIDEO_ID_1`" assumption.** The list
   initially defaulted to `sortKey: 'date-desc'`; the AC (and the mock's fixture comment) assume
   the *natural fetch/merge order* is shown until the user explicitly sorts. Added a `'none'`
   `SortKey` (identity — no re-order) and made it the true default; `'date-desc'`/`'date-asc'`/
   `'title-asc'` remain the three options a user can pick from the sort panel.
5. **`Linking.canOpenURL` unreliably returns `false` for `https` URLs on this Android build** even
   though the OS can open them (confirmed independently via `maestro openLink`) — a known
   package-visibility/`MATCH_DEFAULT_ONLY` quirk. This was incorrectly surfacing
   `external_open_error` on every real-launch attempt (AC-LINK-01). Fixed by dropping the
   `canOpenURL` pre-check and relying solely on `Linking.openURL`'s own success/failure — which is
   exactly the class of bug constitution §4 calls out ("a broken deep-link call").

## Deviations from the reference stack table (cross-framework-setup.md)
- No `expo-router`/React Navigation (see Stack above) — a considered simplification, not a gap.
- No `@react-native-google-signin/google-signin` — no `google-services.json` was present in this
  workspace; used `expo-auth-session`'s generic OAuth flow instead, which only needs a client id
  (also absent — `config/secrets.env`'s `GOOGLE_WEB_CLIENT_ID` is empty). Tapping "Sign in with
  Google" outside UI-test-mode with no client id configured surfaces `login_error_message` (denied
  email `__unconfigured__`) rather than crashing or hanging — an explicit, visible error state per
  constitution §1.6, not a silent failure. This does not affect the scored AC suite, which only
  exercises `mockAuthEmail`.
- No SQLite — AsyncStorage JSON blob cache, sufficient for the spec'd "persist + stale-fallback"
  contract and simpler to unit-test.

## No secrets committed
`config/secrets.env` (gitignored) holds `YOUTUBE_API_KEY`, `AUTHORIZED_EMAILS`,
`GOOGLE_WEB_CLIENT_ID`; `app.config.js` reads it at build time into `Constants.expoConfig.extra`
as a build-time fallback only. All UI-test-mode runs override these via launch extras
(`apiBaseUrl`, `apiKey`, `authorizedEmails`) per constitution §4, so the same APK serves mock,
real, and any future key/whitelist without a rebuild.
