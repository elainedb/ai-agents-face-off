# Implementation Plan: ytdash (React Native / Expo)

**Framework**: React Native (Expo, applicationId `com.example.ytdash_rn`) | **Date**: 2026-07-02
**Input**: `spec/spec.md` + `spec/acceptance-criteria.md` (frozen) + `spec/constitution.md`

## Summary
A single-Activity Expo/React Native app: Google-authenticated (whitelisted), aggregates videos
from 4 configured YouTube channels (paginated + merged), caches them locally, supports
filter/sort, and shows located videos on an OpenStreetMap (Leaflet-in-WebView) map with a native
accessible marker affordance. UI-test-mode is driven by Android intent extras surfaced to JS via a
local Expo native module. No navigation library — a manual, explicit screen-state machine renders
`screen_login` / `screen_home` / `screen_map` conditionally in one tree, which keeps every
harness-asserted id in a single, predictable view hierarchy (avoids router/portal reachability
edge cases entirely — see constitution §5a).

## Technical Context
**Language/Version**: TypeScript 6, React Native 0.86 / React 19, Expo SDK 57
**Primary Dependencies**: zustand (state), @react-native-async-storage/async-storage (cache),
react-native-webview (Leaflet map), expo-build-properties (cleartext traffic to mock),
expo-auth-session (real Google OAuth, no google-services.json needed), a local Expo module
(`testconfig`) for reading Android intent extras.
**Storage**: AsyncStorage — one JSON blob (`videos` + `fetchedAt`) per the "single source of
truth" principle; the UI always reads from this store, refreshed by the network.
**Testing**: Jest + ts-jest for domain/persistence unit tests; Maestro (external, in `flows/`) for
E2E against the compiled APK.
**Target Platform**: Android (release APK), minSdk per Expo SDK 57 defaults.
**Project Type**: mobile-app (single Expo project, no separate backend).
**Performance Goals**: n/a (functional correctness is scored, per spec "Out of scope: … beautiful").
**Constraints**: no blocking work on JS/UI thread (network/disk via async APIs); offline-capable
list (AC-CACHE-01); deterministic UI-test-mode.
**Scale/Scope**: 3 screens, ~8-video mock fixture / unbounded real fixture, 4 source channels.

## Constitution Check
- **Layered separation**: `src/data` (network + AsyncStorage), `src/domain` (whitelist, sort,
  filter — pure functions, unit-testable, framework-agnostic), `src/state` (zustand stores acting
  as the presentation-facing view-model), `src/ui` (screens/components). PASS.
- **Dependency inversion**: screens call zustand store actions; store actions call domain/data
  functions injected as plain module imports (small app — a full DI container would be
  over-engineering for 3 screens, but the seam is still a function boundary, not inlined fetches
  in components). PASS.
- **Unidirectional, observable state**: `videoStore` exposes an explicit
  `'loading'|'content'|'empty'|'error'` view-state; screens are pure functions of store state, no
  business logic in `onPress` handlers (handlers call store actions only). PASS.
- **No blocking UI-thread work**: `fetch` + AsyncStorage are both async; no sync FS/DB APIs used.
  PASS.
- **Single source of truth**: AsyncStorage cache is read on launch and after every successful
  fetch; the list the UI renders always comes from the store's `videos` field, which is populated
  from cache-then-network, never directly from a fetch response. PASS.
- **Explicit error handling**: every screen state includes `error` with `error_retry_button`;
  external-link failures render `external_open_error` instead of throwing. PASS.

No violations — Complexity Tracking table omitted.

## Project Structure

### Documentation (this feature)
```text
plan.md               # this file
tasks.md              # phase-ordered task breakdown
BUILD-REPORT.md        # written after validation (stack, AC results, deviations)
```

### Source Code (repository root)
```text
App.tsx                       # root: screen-state machine + external-open banner (lifted state)
index.ts                      # registerRootComponent (unchanged)
modules/testconfig/           # local Expo native module (Kotlin) reading intent extras
  android/src/main/java/.../TestconfigModule.kt
  index.ts
src/
  domain/
    models.ts                 # Video, ViewState, TestConfig types
    auth.ts                   # isAuthorizedEmail(email, whitelist)
    sortFilter.ts             # sortVideos(), filterVideos()
  data/
    testConfig.ts             # wraps modules/testconfig, provides defaults outside test mode
    youtubeApi.ts              # fetchAllVideos(channels, baseUrl, apiKey) — pagination + merge + videos.list batch
    cache.ts                  # readCache()/writeCache() via AsyncStorage
    channels.ts                # loads config/channels.json (bundled as JSON import)
  state/
    authStore.ts               # zustand: signedIn email, whitelist, login()/logout()
    videoStore.ts               # zustand: videos, viewState, filter, sort, selectedMarker, load()/refresh()
    externalLinkStore.ts        # zustand: capturedUrl | error, open(url)
  ui/
    screens/LoginScreen.tsx
    screens/HomeScreen.tsx
    screens/MapScreen.tsx
    components/VideoListItem.tsx
    components/FilterPanel.tsx
    components/SortPanel.tsx
    components/ExternalLinkBanner.tsx
    components/MapMarkers.tsx
    components/DetailBottomSheet.tsx
__tests__/
  auth.test.ts
  sortFilter.test.ts
  cache.test.ts
android/                       # generated by `expo prebuild`; local module autolinked
```

**Structure Decision**: Single Expo project (Option 1, adapted for RN/Expo). No `backend/` — the
mock/real YouTube API is external. No navigation library; `App.tsx` owns a
`'login'|'home'|'map'` screen enum plus a `'list'|'filter'|'sort'` home sub-mode enum, both in
zustand-free local `useState` at the root (pure UI routing, not business state, so it doesn't need
a store).

## Key decisions & rationale
1. **No React Navigation / expo-router.** Only 3 screens, launched exclusively via UI-test-mode
   intent extras (never deep-linked). A conditional-render state machine removes an entire class of
   "is this id reachable through the navigator's portal/host" risk (the exact class of bug
   constitution §5a warns about for Compose popups) for zero functional loss.
2. **WebView + Leaflet for the map, PLUS a native marker-chip row (constitution §5/§C).** Leaflet
   DOM markers are not accessibility-reachable from Maestro; a horizontal row of `Pressable`
   components (`testID="map_marker"`), one per located video, sits below the WebView and is the
   accessible affordance Maestro drives. The WebView also renders real OSM pins for visual parity
   and wires pin-tap → `postMessage` → the same native selection handler, so a human tapping a
   real pin gets the same bottom sheet.
3. **`detail_bottom_sheet` is a plain absolutely-positioned `View` at the screen root, not a RN
   `Modal`.** Modals mount in a separate native window on Android and RN's `testID`s are still
   discoverable via Espresso in a Modal, but to stay maximally safe against constitution §5a we
   avoid the extra surface entirely.
4. **`external_open_url`/`external_open_error` live in an app-root banner (`externalLinkStore`),
   not per-screen.** Both the list (iteration 2) and the map sheet (iteration 4) call the same
   `open(url)` action, so there is one implementation of "capture vs. real-launch-with-fallback".
5. **Cache = AsyncStorage JSON blob, not SQLite.** The spec only requires "persisted, source of
   truth, stale-fallback" — a JSON array + timestamp satisfies that with much less surface area
   than a schema/migration story, and is trivially unit-testable (mock AsyncStorage).
6. **Category = configured channel label**, read from each video's `snippet.channelTitle` as
   returned by the API for that channel request (never hardcoded "tech"/"music"/"news" — those are
   only the *mock's* internal test buckets, per `youtube-api.md`).
7. **Real Google Sign-In via `expo-auth-session`'s Google provider**, not
   `@react-native-google-signin` — the latter requires a committed `google-services.json`, which is
   not present in this workspace (only `YOUTUBE_API_KEY` is in `config/secrets.env`).
   `expo-auth-session` only needs an OAuth client id (documented as a config gap in
   `BUILD-REPORT.md`); the code path is fully wired and falls back cleanly. UI-test-mode's
   `mockAuthEmail` bypasses this entirely, which is what's scored.
8. **Local Expo module (`testconfig`)**, scaffolded with `create-expo-module --local`, exposes one
   `AsyncFunction` reading `appContext.currentActivity?.intent?.extras`. Read once at `App.tsx`
   mount before first render.
9. **Release build required for Maestro** — a debug RN build needs a Metro server; `assembleRelease`
   embeds the JS bundle so the harness can run it standalone (Expo's default release build is
   debug-signed, no keystore needed).
