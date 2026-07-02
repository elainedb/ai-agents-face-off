# Build Report — ytdash (React Native / Expo)

## Stack
See `plan.md` for the full rationale. Summary: Expo SDK 57 / RN 0.86 / TypeScript, `expo-router`
(file-based navigation), `zustand` (one store per bounded context: auth, videos, external-link
banner), manual DI (`src/data/container.ts` wires an interface-typed `VideoRepository` and
`CacheStore`), `fetch` + hand-written YouTube API types, `@react-native-async-storage/async-storage`
for the local cache, Leaflet-in-WebView + a native `Pressable` chip row for the map (the
verified-working RN split from `spec/cross-framework-setup.md` §C), a local Expo module
(`modules/test-config`) for reading launch-intent extras, and `jest`/`ts-jest` for domain-layer unit
tests.

## Acceptance-criteria result
Ran the full `flows/` suite (14 flow files covering all 14 AC-IDs in `acceptance-criteria.md`)
against the mock (`http://192.168.2.13:8091`, reached over LAN — see Deviations) on device
`25251FDF60029V`, 3 independent runs:

| Run | Result |
|---|---|
| 1 | 14/14 passed |
| 2 | 14/14 passed |
| 3 | 14/14 passed |

**min / median / max = 14/14 / 14/14 / 14/14 (100%).** No flakiness observed across 3 runs.
JUnit reports: `results/run1.xml`, `results/run2.xml`, `results/run3.xml`.

`map_marker_fallback_used=false` — markers are exposed via an intentional native chip-row
affordance (not a coordinate-tap fallback), per constitution §5.

## Static checks
- `npx tsc --noEmit` — clean, no errors.
- `eslint .` — 0 errors, 5 warnings (import ordering in a test file, and two `{}` type warnings in
  the generated Expo-module template code). Warnings acceptable per constitution §2.
- `npx jest` — 17/17 tests passing: `auth.test.ts` (whitelist logic), `filterSort.test.ts`
  (filter/sort domain logic), `cacheStore.test.ts` (AsyncStorage read/write/replace/clear
  persistence, with a mocked AsyncStorage).

## Real-mode wiring
- `apiBaseUrl`/`apiKey` are read at runtime from launch-intent extras (`src/state/testConfig.ts`);
  outside UI-test-mode they default to `https://www.googleapis.com` and
  `process.env.EXPO_PUBLIC_YOUTUBE_API_KEY` respectively — the exact same `HttpVideoRepository` /
  `youtubeApi.ts` code path serves both mock and real traffic, only the two extras differ.
- Real external-link launch uses `Linking.openURL` wrapped in try/catch → `external_open_error` on
  failure (exercised by `AC-LINK-01`, which passed).
- Real Google Sign-In is implemented against `expo-auth-session`'s Google OAuth provider
  (`app/login.tsx`). See Deviations below for the one thing that couldn't be exercised end-to-end.
- **Live-verified against the real YouTube Data API**, not just structurally: launched the build
  with `apiBaseUrl=https://www.googleapis.com` and the real `apiKey` from `config/secrets.env`
  (mock auth email, so only the network layer was real). Result: **181 real videos** aggregated and
  deduped across all 4 configured channels (`config/channels.json`), full pagination followed
  (181 ≫ one page of 50), real thumbnails loaded, category labels showing the configured channel
  labels (not YouTube's internal `channelTitle`/`categoryId`). Navigated to the map screen: real
  OSM/Leaflet pins rendered at the real `recordingDetails.location` coordinates returned by
  `videos.list` (visible spread across Western Europe), alongside the native `map_marker` chip row.
  This exercises the exact "list populates, map shows markers" real-mode requirement live, not just
  by code-path inspection.

## Deviations
1. **No OAuth client id / `google-services.json` in this workspace.** `config/secrets.env` only
   contained `YOUTUBE_API_KEY`; no Google OAuth client id (Android or web) or Firebase config was
   provided. Real Google Sign-In is fully implemented, but `Google.useAuthRequest` throws
   synchronously if `androidClientId` is `undefined` (an early, real bug this caught — see below),
   so `app/login.tsx` falls back to a placeholder id and gates the actual `promptAsync()` call
   behind `isGoogleConfigured`, surfacing "Google Sign-In is not configured in this build" instead
   of crashing. To ship production real-mode sign-in, set `extra.googleAndroidClientId` /
   `extra.googleWebClientId` in `app.json` (or inject at build time) to real OAuth client ids. The
   `mockAuthEmail` path — which is what all 14 ACs exercise — is fully implemented and tested.
2. **AsyncStorage instead of `expo-sqlite`** for the local cache (`src/data/cacheStore.ts`): the
   cached data is one flat list with a timestamp, no relational queries, so a single JSON blob is
   simpler with identical tested behavior (replace-on-refresh, stale-fallback — `AC-CACHE-01`
   passed all 3 runs).
3. **Physical-device networking note (harness/environment, not app code):** on the target device
   (`25251FDF60029V`, a physical Pixel 6 over USB), `adb reverse tcp:8091 tcp:8091` was reachable
   from an `adb shell` process (verified with `nc`) but NOT from the app's own networking stack
   (`java.net.ConnectException` on every request). The device and host share the same Wi-Fi subnet,
   so pointing `apiBaseUrl` at the host's LAN IP (`http://192.168.2.13:8091`) instead of
   `127.0.0.1` resolved it immediately and reproducibly across all 3 runs. This looks like a
   device/adb-reverse quirk specific to this physical device's network sandboxing, not an app bug —
   flagged here since `flows/README.md`'s documented recipe (`127.0.0.1` via `adb reverse` for
   physical devices) did not work as written in this environment.

## Real bugs this build caught and fixed pre-submission
1. **Infinite render loop** (`app/home.tsx` / `src/state/videoStore.ts`): an initial implementation
   exposed a zustand selector (`useVideoStore(selectVisibleVideos)`) that allocated a new filtered
   +sorted array on every call. `useSyncExternalStore` requires a selector's snapshot to be
   reference-stable when nothing relevant changed; a selector that always returns a new array
   breaks that contract and React throws "Maximum update depth exceeded" the moment the store
   updates once. Fixed by reading the raw primitives (`videos`, `filterCategory`, `sortKey`,
   `sortDirection`) from the store and deriving the visible list with `useMemo` in the component
   instead (`computeVisibleVideos`, no longer a store selector).
2. **`Google.useAuthRequest` synchronous crash** when no OAuth client id is configured (see
   Deviation 1) — caught via a real on-device crash during flow validation, fixed with a placeholder
   id + an `isGoogleConfigured` gate before ever calling `promptAsync()`.
3. **Default sort order broke `AC-LIST-03`:** an initial implementation defaulted the list to
   "date descending", which reordered the natural fetch order and put a different video first
   (breaking the fixture's `VIDEO_ID_1`-is-first assumption). Fixed by defaulting `sortKey` to
   `null` ("natural order, as fetched/merged across channels") until the user explicitly picks a
   sort option — matching what the spec's fixture comment implies the default should be.

## Definition-of-done checklist
- [x] `flows/AC-*.yaml` all pass against the mock build (14/14, 3/3 runs).
- [x] `plan.md`, `tasks.md`, `BUILD-REPORT.md` present.
- [x] No secrets committed (`config/secrets.env` is gitignored; `app.json`'s `extra.*ClientId`
      fields are empty placeholders).
- [x] App runs against the real API: live-verified against `https://www.googleapis.com` with the
      real key from `config/secrets.env` — 181 real videos loaded (all 4 channels, fully paginated),
      real map markers rendered from real `recordingDetails.location` data. The one real-mode path
      NOT independently verified live is Google Sign-In itself, since no OAuth client id was present
      in this workspace (mock auth was used to isolate the network-layer smoke test) — see
      Deviations #1.
