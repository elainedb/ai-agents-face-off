# Implementation Plan — YouTube Dashboard ("ytdash") · React Native / Expo

> Spec-Kit `plan` artifact. Input: the FROZEN `spec/spec.md`, `spec/acceptance-criteria.md`,
> `spec/constitution.md`, `spec/cross-framework-setup.md`. This documents the engineering decisions
> (the part under evaluation). Nothing here changes the spec.

## Stack decision (and why)

| Concern | Choice | Rationale |
|---|---|---|
| Platform | Expo SDK 57, RN 0.86, React 19, Hermes, New Arch | Given scaffold; idiomatic RN. Release APK embeds the JS bundle so it runs standalone under Maestro. |
| Language | TypeScript (`strict`) | Type-safe domain model; catches parse/shape bugs the spec is full of. |
| Navigation | Explicit root state machine (`login → home → map`) in a zustand store | The app is 3 screens + overlays. A file-based router adds native surface area and separate-window popups for no benefit here; a single observable app-state keeps every harness-asserted element in one view tree (constitution §5a) and makes the login/home/map transitions trivially testable. |
| State | **zustand** (one store) | Idiomatic lightweight unidirectional store. Screens render from an observable `UiState` union (`loading / content / empty / error`); no business logic in event handlers (constitution §1.3). |
| HTTP / parse | `fetch` + hand-written typed mappers | The YouTube shapes are small and well-specified; a mapper layer isolates the API JSON from the domain `Video` (dependency inversion, constitution §1.2). Base URL + key are injected at runtime, never hardcoded. |
| Persistence | **`@react-native-async-storage/async-storage`** (JSON blob, single source of truth + 24h TTL metadata) | Simple, durable across a fresh process (AC-CACHE-01 relaunch). The store the UI reads from is the cache; the network refreshes it (constitution §1.5). |
| Auth | Pluggable `AuthService`: `MockAuthService` (UI-test-mode `mockAuthEmail`) + `GoogleAuthService` (production) behind one interface | Whitelist logic (domain) is identical for both; only the identity source swaps. |
| Map | **Leaflet in a `react-native-webview`** (real OSM tiles + pins) **plus a native `map_marker` overlay row** | Per constitution §5 / cross-framework-setup §C: WebView DOM markers are unreachable by Maestro, so the reachable affordance is a native `Pressable` per located video carrying `map_marker`; the WebView also `postMessage`s pin taps to native (human path). |
| External open | `expo-linking` (`Linking.openURL`) with a root-level capture/error seam | `captureExternalLinks=true` → render `external_open_url` (text = URL); else real launch, and any failure surfaces `external_open_error` instead of crashing (constitution §4, §6). |
| Test-mode seam | Local Expo module `test-config` reading `intent.extras` | The v3 gap this whole experiment targets. `getConfig()` returns the 6 extras to JS at app root. |
| Unit tests | `jest-expo` | Domain (whitelist, sort, filter) + a persistence round-trip (constitution §2). |

## Architecture (layered, constitution §1)

```
modules/test-config/          native seam: intent extras → JS (UI-test-mode contract §4)
src/
  config/testConfig.ts        merge native extras with build defaults → AppConfig
  config/channels.ts          load config/channels.json (source channels + labels)
  domain/
    types.ts                  Video, AppConfig, UiState<T>
    auth.ts                   isAuthorized(email, whitelist)      ← pure, unit-tested
    sort.ts                   sortVideos(list, key)               ← pure, unit-tested
    filter.ts                 filterVideos(list, label)           ← pure, unit-tested
  data/
    youtubeApi.ts             fetchAllVideos(cfg): paginate every channel, merge/dedupe,
                              videos.list for recordingDetails.location   ← data access
    cache.ts                  load/save last-good list (AsyncStorage)     ← persistence
    repository.ts             VideoRepository: network→cache, stale-fallback on error
    auth/                     AuthService interface + Mock + Google impls
  state/store.ts              zustand: auth + videos + UiState + external-open seam
  ui/                         LoginScreen, HomeScreen, MapScreen, DetailSheet,
                              ExternalOpenBanner, StateViews (loading/empty/error)
App.tsx                       reads config once, renders the app-state machine + root banner
```

**Data flow (unidirectional).** `Repository.getVideos()` returns cached data immediately when
present, then a network refresh replaces the store; on network failure with a populated cache the UI
stays on the cached content (no blocking `error_view`) — that is exactly AC-CACHE-01. The screen
title binds to `videos.length` via `video_count`.

**Pagination + aggregation (anti-overfit).** `fetchAllVideos` iterates every channel in
`config/channels.json`, follows `nextPageToken` until exhausted, tags each video with its **source
channel's label** as `category`, dedupes by `videoId` (first wins → stable order), then batches
`videos.list?id=…&part=…,recordingDetails` to attach `location`. No catch-all, no fixture constants.

## Contract mapping (how each AC is satisfied)

- Selectors (§3): every element in the table gets its exact `testID`. Rows put `testID` on the
  `Pressable` (RN aggregates descendant text, so `id + text` resolves for AC-SORT/AC-LIST).
- UI-test-mode (§4): `test-config` native module; `mockAuthEmail` short-circuits the account picker;
  `apiBaseUrl`/`apiKey` injected at runtime; `captureExternalLinks` toggles the open seam.
- Overlays (§5a): filter/sort panels, detail sheet, and the external-open banner are plain
  absolutely-positioned Views in the main tree (not separate windows) → testIDs always reachable.
- Map (§5): native `map_marker` overlay row is the harness affordance; Leaflet pins are the human path.

## Risks / mitigations
- **Release build required** (debug loads from Metro) → `assembleRelease`, cleartext enabled for the mock.
- **Real Google sign-in** needs `google-services.json` (not provided in this workspace) → the
  `GoogleAuthService` path is implemented and guarded; absent config surfaces a visible error, never a
  crash. All 14 scored ACs run in UI-test-mode (`mockAuthEmail`), so this does not affect scoring.
