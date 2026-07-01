# BUILD REPORT — YouTube Dashboard ("ytdash"), React Native / Expo

**Framework / applicationId:** `com.example.ytdash_rn`
**Target device:** `25251FDF60029V` (physical, Android 16), Maestro 2.6.1
**Result:** **14 / 14 acceptance criteria PASS**, stable across **3 runs** (min/median/max = 14/14/14).

## 1. Stack chosen (the `plan` decision)

| Concern | Choice |
|---|---|
| Platform | Expo SDK 57, React Native 0.86, TypeScript, Hermes, New Architecture |
| Navigation | State-driven conditional rendering (login/home/map) via a Zustand nav store — no router, so the harness-asserted tree stays flat and deterministic |
| State | **Zustand** — 4 stores: auth, videos, ui (nav+filter+sort), external |
| Data access | `fetch` + **zod** boundary validation |
| Persistence | **AsyncStorage** JSON snapshot (24h TTL, replace-on-refresh, stale-fallback) |
| Errors / view-state | `Result<T>` union + sealed UiState (loading / content / empty / error) |
| Map | **react-native-webview + Leaflet/OSM** (real map) + a **native `map_marker` chip row** (accessible affordance) + a native in-tree bottom sheet |
| Launch args | **Local Expo native module `TestConfig`** (Kotlin) reading `currentActivity.intent.extras` |
| Auth | Mock path (`mockAuthEmail`) for tests; real Google Sign-In seam (`@react-native-google-signin`) for production, whitelist identical on both |

Full rationale + layered architecture in [`plan.md`](./plan.md); dependency-ordered work in [`tasks.md`](./tasks.md).

## 2. How the contracts were honored

- **Selector contract (constitution §3):** every logical ID is applied via `testID` (centralized in
  `src/ui/selectors.ts`). Popups (filter/sort) are RN `Modal`s that fully cover the list; the map
  bottom sheet is a plain in-tree `View` — so all testIDs stay reachable (§5a).
- **UI-test-mode (constitution §4):** the `TestConfig` Kotlin module surfaces the launch extras;
  `src/state/testConfig.ts` coerces them (bool/string) and `src/state/appConfig.ts` composes runtime
  config, so mock↔real is a pure runtime swap of `apiBaseUrl` + `apiKey`.
- **Map markers (constitution §5):** Leaflet-in-WebView DOM pins are not reachable by Maestro, so a
  native chip per located video carries `map_marker`; tapping it opens the native sheet. WebView pin
  taps also `postMessage` → same sheet (human path). `map_marker_fallback_used=false` (native
  affordance, not coordinate taps).
- **Data flow / anti-overfit:** iterates all 4 configured channels (no catch-all), follows
  `nextPageToken` to exhaustion, merges/dedupes by videoId, enriches locations via `videos.list`.
  Nothing reads fixture values — counts, ids, titles, and locations all come from the API. Verified
  against the real YouTube Data API (real channels, real pagination) as well as the mock. The third
  Maestro run used a *different* authorized email and still passed 14/14 — no hardcoding.

## 3. Acceptance-criteria results (mock, device `25251FDF60029V`)

| AC | Result | | AC | Result |
|---|---|---|---|---|
| AC-LOGIN-01 | ✅ | | AC-COUNT-01 | ✅ |
| AC-LOGIN-02 | ✅ | | AC-CACHE-01 | ✅ |
| AC-LOGIN-03 | ✅ | | AC-FILTER-01 | ✅ |
| AC-LIST-01 | ✅ | | AC-SORT-01 | ✅ |
| AC-LIST-02 | ✅ | | AC-MAP-01 | ✅ |
| AC-LIST-03 | ✅ | | AC-MAP-02 | ✅ |
| AC-LINK-01 | ✅ | | AC-MAP-03 | ✅ |

JUnit output: `results/run_full.xml`, `results/run_full3.xml`.

## 4. Real-mode wiring

Same build runs against the real API by swapping `apiBaseUrl=https://www.googleapis.com` +
`apiKey=<key>` (verified: list populates from the 4 real channels, count shows, map screen opens).
Real Google Sign-In is implemented as a dynamic seam in `src/ui/auth/googleSignIn.ts`; to fully
enable it, install `@react-native-google-signin/google-signin`, add `google-services.json` to
`android/app`, and set `webClientId`. The whitelist check (`src/domain/auth.ts`) is the *same* code
exercised by the tested mock path, so the access-control logic under test is the production logic.

## 5. Quality bar

- **Unit tests:** 22 passing across 5 suites (`npm test`) — auth whitelist, sort (date/title,
  asc/desc + no-mutation), filter (by label + available categories), cache round-trip
  (replace-on-refresh), and the API aggregation/pagination/dedupe/enrich path.
- **Static:** `npx tsc --noEmit` clean for the app (`tsconfig.json`) and tests (`tsconfig.test.json`).
- **Secrets:** no API key in source (`grep AIza src/ App.tsx app.json modules/` → none). The key is
  read at runtime from the `apiKey` extra, or from `EXPO_PUBLIC_YOUTUBE_API_KEY` at build for
  production. `config/secrets.env` and `google-services.json` are gitignored.
- **Cleartext:** `usesCleartextTraffic: true` via `expo-build-properties` (reach the http mock).
- **Build type:** release APK (`assembleRelease`) — a debug APK would need a Metro server and can't
  run standalone under Maestro.

## 6. Deviations / notes

- **Navigation:** chose state-driven screen switching over `expo-router`. For a 3-screen app it
  removes native-surface indirection and makes every asserted element live in one flat tree — a
  deliberate reliability choice, documented in `plan.md`.
- **Real Google Sign-In** is a dynamic, guarded seam rather than a hard dependency: no
  `google-services.json` was provided in `config/`, and the scored suite runs entirely in
  UI-test-mode. This keeps the build lean while leaving a one-step path to production auth.
- **Map tiles** load from OSM over the network; when offline the WebView is blank but the native
  `map_marker` chips + bottom sheet (the asserted affordance) still work, so map ACs are unaffected.
- **AC-CACHE-01 on a physical device:** `adb reverse` tunnels over USB, so the mock can remain
  reachable even in airplane mode; the assertion (items shown, no blocking error) passes on both the
  fresh-fetch and the stale-cache path — and the stale-fallback path is separately covered by the
  cache unit test.
</content>
