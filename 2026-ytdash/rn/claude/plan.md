# Implementation Plan — ytdash (React Native / Expo)

**Spec**: `spec/spec.md` + `spec/acceptance-criteria.md` (frozen) · **Constitution**: `spec/constitution.md`

## Summary
A single-activity Expo/React Native (Android) app that signs a user in (whitelist-gated), fetches
videos from N configured YouTube channels (paginated, merged, deduped), caches them locally,
supports filter/sort, and shows geolocated videos on a map. Built to the constitution's selector,
UI-test-mode, and map-marker contracts so the shared Maestro flow set drives it unmodified.

## Technical Context
- **Language/Version**: TypeScript 6, React Native 0.86, Expo SDK 57 (New Arch on), React 19.
- **Navigation**: `expo-router` (file-based, matches the "RN/Expo" reference stack).
- **State management**: `zustand` — one store per bounded context (`authStore`, `videoStore`), thin
  and easily unit-testable without a React tree.
- **DI**: manual — a small `container.ts` wires concrete implementations (YouTube HTTP client,
  AsyncStorage cache) behind interfaces (`VideoRepository`, `CacheStore`) so presentation code only
  depends on the interface, never `fetch`/`AsyncStorage` directly (constitution §1.2).
- **Networking**: native `fetch` + hand-written types (no runtime schema validation library — the
  YouTube response shape is small and fixed; parsing is centralized in one module so the boundary
  is still isolated).
- **Storage/cache**: `@react-native-async-storage/async-storage`, storing the merged video list as
  one JSON blob + a `lastFetchedAt` timestamp. Chosen over `expo-sqlite` for this data shape (a
  single flat list, no relational queries) — less native surface, same testable
  replace-on-refresh + stale-fallback behavior the constitution asks for.
- **Map**: **Leaflet-in-WebView** (`react-native-webview`) for the real rendered map (OSM tiles +
  pins), **plus** a native `Pressable` marker-chip row (`testID="map_marker"`) and a native
  absolutely-positioned `View` bottom sheet (not a RN `Modal`) for `detail_bottom_sheet` — this is
  the verified-working split the cross-framework doc records for RN (WebView DOM markers are not
  a11y-reachable; the native chip row is). `map_marker_fallback_used=false` is NOT applicable here —
  we're not falling back to coordinate taps, we render an intentional native affordance alongside
  the WebView, per constitution §5.
- **UI-test-mode / launch args**: a local Expo module (`modules/test-config`, package
  `expo.modules.testconfig`) with a Kotlin `Function("getConfig")` reading
  `appContext.currentActivity?.intent?.extras` — read once at app boot before first render.
- **Auth**: `mockAuthEmail` (test mode) short-circuits sign-in. Real mode uses
  `expo-auth-session`'s Google OAuth provider (`expo-web-browser` + `expo-crypto` for PKCE) — no
  `google-services.json`/Firebase native SDK needed for an Expo-managed OAuth code flow. See
  BUILD-REPORT.md for the one deviation this implies (no OAuth client id was present in this
  workspace's `config/secrets.env`, only `YOUTUBE_API_KEY`).
- **External links**: `Linking.openURL` in production; in `captureExternalLinks=true` mode the
  banner shows `external_open_url` instead; a thrown/rejected `Linking.openURL` in real mode
  surfaces `external_open_error` (root-level state, lifted above both the list and the map sheet
  per cross-framework-setup.md's "lift to app root" note).
- **Testing**: `jest` (ts-jest) for the domain layer — `auth.ts` whitelist, `filterSort.ts`, and a
  cache read/write persistence test against a mocked AsyncStorage. No UI test runner: the black-box
  Maestro flows are the UI-level tests, per constitution §2.
- **Target platform**: Android only (per spec "Out of scope"). `usesCleartextTraffic` (already in
  `app.json`) so the app can reach the mock at `10.0.2.2`/`127.0.0.1`.
- **Constraints**: no secrets committed; `apiBaseUrl`/`apiKey`/`authorizedEmails` all overridable at
  runtime via intent extras (constitution §4); every screen has loading/empty/error states.

## Constitution check
- Layered separation ✅ — `src/domain` (pure), `src/data` (network+cache, behind interfaces),
  `app/*` + `src/components` (presentation, reads only from zustand stores).
- Dependency inversion ✅ — stores depend on `VideoRepository`/`CacheStore` interfaces from
  `src/data/container.ts`, not concrete `fetch`/`AsyncStorage` calls.
- Unidirectional observable state ✅ — `videoStore` exposes a single `status:
  'loading'|'content'|'empty'|'error'` discriminant; screens are dumb renderers of it.
- No UI-thread blocking work ✅ — `fetch`/AsyncStorage are already async; no sync IO.
- Single source of truth ✅ — the AsyncStorage cache is read on boot; network refresh replaces it;
  UI always reads the store, never the network response directly.
- Explicit error handling ✅ — every async boundary (auth, fetch, parse, persistence, external
  link, map load) sets an explicit error state with a retry affordance (`error_view` +
  `error_retry_button`) or `external_open_error`.

## Project structure
```
app/                        # expo-router routes (thin — delegate to src/components + stores)
  _layout.tsx                # boot: load TestConfig, init container, render Stack + root banner
  index.tsx                  # redirect: login vs home depending on authStore
  login.tsx                  # screen_login
  home.tsx                   # screen_home (video_list, filter/sort panels, map_nav_button)
  map.tsx                    # screen_map

src/
  domain/
    types.ts                 # Video, SourceChannel, SortKey, FilterCategory
    auth.ts                  # isAuthorizedEmail(email, whitelistCsv)
    filterSort.ts            # filterByCategory(videos, cat), sortVideos(videos, key, dir)
  data/
    youtubeApi.ts            # search.list + videos.list, pagination, base URL + key from TestConfig
    channels.ts               # loads config/channels.json (bundled, not secret)
    videoRepository.ts        # fetch-all-channels -> merge/dedupe -> attach location -> cache
    cacheStore.ts             # AsyncStorage get/set video cache + timestamp
    container.ts              # wires the concrete repository + cache (the DI seam)
  state/
    testConfig.ts             # loads TestConfig once at boot (native module wrapper + JS default)
    authStore.ts               # zustand: email, status, signIn(mock|google), signOut, error
    videoStore.ts              # zustand: status, videos, filter, sort, load(), refresh()
    externalLinkStore.ts       # zustand: capturedUrl | error — the app-root banner state
  components/
    ExternalLinkBanner.tsx     # renders external_open_url / external_open_error at app root
    VideoListItem.tsx
    FilterPanel.tsx / SortPanel.tsx   # replace the list while open (cross-framework-setup note 2)
    LoadingView.tsx / ErrorView.tsx / EmptyView.tsx
    MapMarkers.tsx              # native chip row, testID="map_marker" per located video
    DetailBottomSheet.tsx       # absolutely-positioned View, not RN Modal
    LeafletMap.tsx              # WebView + Leaflet HTML, receives pins via postMessage

modules/test-config/          # local Expo module — launch-intent extras -> JS

config/channels.json          # source channels (bundled; not a secret)
config/secrets.env            # gitignored; YOUTUBE_API_KEY for local/manual real-mode runs

__tests__/                    # jest unit tests (domain + cache)
```

## Data flow (iteration 2/3 core)
1. `videoStore.load()` calls `videoRepository.getAll()`.
2. Repository, for each configured channel: calls `search.list?channelId=...`, follows
   `nextPageToken` until absent, collects `videoId`s + partial snippet.
3. Merges all channels' results, dedupes by `videoId`.
4. Calls `videos.list?id=<comma-joined ids>` (chunked ≤50) to get `recordingDetails.location` +
   canonical snippet/publishedAt.
5. Maps to the domain `Video` type (category = the channel's configured `label`, not YouTube's
   `categoryId` — per `youtube-api.md`).
6. Writes the merged, deduped list to `cacheStore` (replace-on-refresh).
7. Returns to `videoStore`, which sets `status: 'content'` (or `'empty'` if zero videos) and drives
   `video_count` from `videos.length`.
8. On network failure: `videoRepository.getAll()` falls back to `cacheStore.read()`; if that has
   data, `status: 'content'` with the stale set (no blocking `error_view` — AC-CACHE-01); if empty,
   `status: 'error'`.

## Map marker contract (constitution §5) — concretely
- `LeafletMap` renders the real WebView/Leaflet pins (human-facing, matches the "verified working"
  RN reference).
- `MapMarkers` renders one `Pressable` per located video, `testID="map_marker"`, laid out as a
  horizontal chip row below/over the map — this is what Maestro taps (`tapOn: {id: map_marker,
  index: 0}`).
- Tapping either the WebView pin (via `postMessage`) or the native chip sets the same
  `selectedVideoId` state, which renders `DetailBottomSheet` (`detail_bottom_sheet`,
  `detail_video_url`, `detail_open_youtube_button`) as a plain `View`, not a `Modal` — so its
  `testID`s stay in the main tree (avoiding the §5a popup trap).

## Deviations / risks (tracked, resolved in BUILD-REPORT.md)
- No OAuth client id / `google-services.json` present in this workspace → real Google sign-in is
  implemented against `expo-auth-session`'s Google provider but cannot be smoke-tested end-to-end
  here; `mockAuthEmail` path (which IS what all 12 ACs exercise) is fully implemented and tested.
- AsyncStorage instead of `expo-sqlite` for cache (see Storage/cache above) — simpler surface for a
  single flat list, same tested behavior.
