# Implementation Plan: ytdash (React Native / Expo)

**Framework**: React Native (Expo) | **Date**: 2026-07-02 | **Spec**: `spec/spec.md`, `spec/acceptance-criteria.md`, `spec/constitution.md`

## Summary

Build the ytdash YouTube dashboard on Expo/React Native: Google-gated login, a
paginated/aggregated video list with cache/filter/sort, and an OpenStreetMap
screen with reachable markers — honoring the constitution's selector,
UI-test-mode, and map-marker contracts so the shared Maestro flow set drives
the compiled APK unchanged.

## Technical Context

**Language/Version**: TypeScript 5 (strict), React Native 0.86, Expo SDK 57 (already scaffolded)

**Primary Dependencies**:
- `zustand` — state containers (auth, videos, ui/nav, external-link banner)
- `@react-native-async-storage/async-storage` — local persistence (source of truth for the video list)
- `react-native-webview` — Leaflet/OSM map rendering (WebView + DOM, per cross-framework-setup.md §C reference stack)
- A local Expo module (`modules/test-config`, Kotlin) — reads Android launch-intent extras for UI-test-mode (constitution §4); no JS-side workaround exists for extras
- `expo-build-properties` (already present) — `usesCleartextTraffic` for the mock's `http://` origin
- `expo-auth-session` — real-mode Google OAuth (no native Google-Sign-In SDK / `google-services.json` needed; this workspace has no `google-services.json`, see Deviations)
- Jest + `ts-jest`/`babel-jest` (Expo's default jest preset) — unit tests for the domain layer + one persistence test

**Storage**: AsyncStorage, one JSON blob per key (`ytdash:videos:v1`) — replace-on-successful-refresh, stale-fallback on network error. No TTL invalidation (none is specced; a TTL that hides stale-but-valid data would risk AC-CACHE-01).

**Testing**: `jest` (domain: `isAuthorized`, `sortVideos`, `filterVideosByCategory`; persistence: cache round-trip) + Maestro black-box flows in `flows/` (not written by the builder) for acceptance.

**Target Platform**: Android (physical device `25251FDF60029V` for self-validation), minSdk/targetSdk per Expo SDK 57 defaults.

**Project Type**: mobile-app (single Expo project, no backend — the mock/real YouTube API is the only backend)

**Performance Goals**: N/A (functional correctness app, out of scope per spec.md "Out of scope")

**Constraints**: no secrets in source control; `apiBaseUrl`/`apiKey`/whitelist are runtime launch-extras or `config/secrets.env` (gitignored) — never compiled-in constants; no blocking work on the UI thread (network/disk via async repository calls, not inline in render/handlers).

**Scale/Scope**: 3 screens (login, home/list, map) + 2 overlay panels (filter, sort) + 1 bottom sheet (map detail) + 1 app-root banner (external-link capture/error). ~8-video fixture locally; hidden held-out dataset at scoring time — no fixture values are hardcoded anywhere in app code.

## Constitution Check

*Gate: re-checked after design below — no violations.*

- **Layered separation (§1.1)**: `src/data` (network + AsyncStorage), `src/domain` (pure auth/sort/filter), `src/state` (zustand stores = presentation-facing view-state), `src/ui` (screens/components). Screens only call store actions; stores call the repository; the repository calls the API client + cache. No layer reaches over another.
- **Dependency inversion (§1.2)**: Screens depend on zustand store hooks (an abstraction over "wherever the data comes from"), never on `fetch`/AsyncStorage directly. The repository is injected into the store at creation (one constructor call in `src/state/videoStore.ts`), swappable for tests.
- **Unidirectional, observable state (§1.3)**: Each store exposes a `status: 'loading'|'content'|'empty'|'error'` plus data; screens are pure renders of that shape. No business logic (sorting, whitelist checks) lives in `onPress` handlers — handlers call domain functions or store actions only.
- **No blocking UI-thread work (§1.4)**: All network/AsyncStorage calls are `async` and awaited inside store actions, never synchronously in render.
- **Single source of truth (§1.5)**: The video list screen reads only from `videoStore` (which mirrors AsyncStorage). `refresh()` writes network results to AsyncStorage *then* updates the store — the UI never renders a raw fetch response.
- **Explicit error handling (§1.6)**: Every async boundary (auth, fetch, parse, persistence, external link, map) returns a discriminated `Result<T, AppError>`-shaped outcome; screens map `error` status to `error_view` + `error_retry_button`. External-link failures surface `external_open_error` instead of throwing.

## Project Structure

```text
App.tsx                       # root: loads test-config, mounts navigation shell + external-link banner
index.ts                      # unchanged entry (registerRootComponent)
modules/test-config/          # local Expo module (Kotlin) — reads intent extras
  android/src/main/java/.../TestConfigModule.kt
  index.ts                    # JS surface: getTestConfig(): Promise<TestConfig>

src/
  domain/
    auth.ts                   # isAuthorized(email, whitelist)
    sort.ts                   # sortVideos(videos, key, dir)
    filter.ts                 # filterVideosByCategory(videos, category)
    types.ts                  # Video, Result<T,E>, UiStatus
  data/
    youtubeApi.ts              # search.list pagination + videos.list batching, per youtube-api.md
    channels.ts                 # loads config/channels.json (bundled, non-secret config)
    videoCache.ts               # AsyncStorage read/write for the video list
    videoRepository.ts          # orchestrates api + cache + dedupe/merge; returns Result<Video[]>
  native/
    testConfig.ts               # thin wrapper around modules/test-config, with sane defaults outside test mode
  state/
    testConfigStore.ts           # resolved launch config (uiTestMode, apiBaseUrl, apiKey, authorizedEmails, captureExternalLinks)
    authStore.ts                  # signed-in email, authorized flag, login/logout actions, login_error_message text
    videoStore.ts                  # status, videos, filter, sort, refresh()/load()
    externalLinkStore.ts             # app-root banner state: capturedUrl | error
    navStore.ts                       # 'login' | 'home' | 'map' — hand-rolled, no nav library (3 screens, no deep-linking need)
  ui/
    screens/LoginScreen.tsx
    screens/HomeScreen.tsx
    screens/MapScreen.tsx
    components/VideoListItem.tsx
    components/FilterPanel.tsx
    components/SortPanel.tsx
    components/MapMarkersOverlay.tsx
    components/DetailBottomSheet.tsx
    components/ExternalLinkBanner.tsx
    components/LoadingView.tsx / ErrorView.tsx
  __tests__/
    auth.test.ts / sort.test.ts / filter.test.ts / videoCache.test.ts
```

**Structure Decision**: Single Expo project (mobile-app), no `expo-router` — 3 screens with no deep-link
requirement in the spec, so a hand-rolled `navStore` (`'login'|'home'|'map'`) keeps every screen in
**one view tree** (avoids the Android-popup-window a11y trap called out in constitution §5a /
cross-framework-setup.md §A; RN `testID` survives across windows too, but a single tree keeps it
simple and auditable). Filter/sort panels and the map bottom sheet are plain absolutely-positioned
`View`s that replace/overlay the list, not RN `Modal` — matches the "verified working" RN reference
pattern in `cross-framework-setup.md` §C.

### Key design choices & why

1. **Map**: `react-native-webview` renders a Leaflet/OSM map (real pins, human path) **and** a native
   `Pressable` row (one per located video, `testID="map_marker"`) rendered *outside* the WebView for
   Maestro to drive (constitution §5 — WebView DOM markers are not reachable by a black-box tool).
   Both paths converge on the same `detail_bottom_sheet` (a plain `View`, in the main tree).
2. **External-link banner lives at the app root** (`externalLinkStore` + `ExternalLinkBanner` mounted
   once in `App.tsx`), not per-screen, so both the list (iteration 2) and the map sheet (iteration 4)
   share one `external_open_url`/`external_open_error` surface without duplication.
3. **Pagination**: `youtubeApi.fetchChannelVideos` follows `nextPageToken` in a loop until absent, for
   *every* configured channel in `config/channels.json` (no catch-all query exists). Results are
   merged and deduped by video id before `videos.list` is called (batched ≤50 ids) for
   location/details — this is what makes `AC-COUNT-01` (needs all pages) and the anti-overfit
   requirement (hidden dataset, unknown page counts/channel counts) hold.
4. **Auth**: `uiTestMode && mockAuthEmail` short-circuits to that email (constitution §4); otherwise a
   real Google OAuth flow via `expo-auth-session` (Expo-idiomatic, no native SDK linking / no
   `google-services.json` requirement — see Deviations, this workspace has no such file). Either path
   feeds the same `isAuthorized()` domain check against `authorizedEmails` (extras override in test
   mode, `config/secrets.env`-provided whitelist otherwise).
5. **Cache**: AsyncStorage over SQLite — the spec only requires "persisted locally, source the list
   reads from, stale-fallback on network error"; a single JSON blob is sufficient, is trivially unit
   testable without a native DB layer, and avoids `expo-sqlite`'s extra prebuild surface for a
   dataset this small. (`expo-sqlite` remains the documented "reference" choice, not a requirement —
   constitution §6 explicitly leaves storage to the agent.)

## Complexity Tracking

No constitution violations to justify — the layered structure above satisfies §1 directly with no
extra indirection beyond what's needed for testability (repository swap in tests, store abstraction
over data access).

## Deviations from the "reference" stacks noted in cross-framework-setup.md

- Real Google Sign-In: the workspace does not actually contain a `google-services.json` (only
  `config/channels.json` and `config/secrets.env` with `YOUTUBE_API_KEY`), despite the run prompt
  referencing one. Real-mode sign-in is wired via `expo-auth-session`'s Google provider (needs an
  OAuth client id, read from config/env, currently unset) so the code path exists and is exercised in
  UI-test-mode (via `mockAuthEmail`); it cannot be end-to-end verified against a real Google account
  in this environment. Documented again in `BUILD-REPORT.md`.
