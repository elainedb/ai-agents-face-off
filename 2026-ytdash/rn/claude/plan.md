# Implementation Plan — YouTube Dashboard ("ytdash"), React Native / Expo

> Spec-Kit `plan` artifact. Built on the **frozen** spec (`spec/spec.md`,
> `spec/acceptance-criteria.md`) and the non-negotiable `spec/constitution.md`.
> The stack below is the engineering decision this step exists to make.

## 1. Stack choice & justification

| Concern | Choice | Why (idiomatic for RN/Expo) |
|---|---|---|
| Platform | **Expo SDK 57 / RN 0.86**, TypeScript, Hermes, New Arch | The scaffold's SDK; managed prebuild gives us a real Android project we can `assembleRelease`. |
| Navigation | **State-driven conditional rendering** via a nav store | Only 3 screens (login/home/map). A router adds native surfaces + testID indirection for no benefit; a single observable `screen` value keeps the harness-asserted tree flat and deterministic. |
| State | **Zustand** (auth, videos, ui, external stores) | The idiomatic lightweight RN store; gives unidirectional, observable view-state (constitution §1.3) with no boilerplate. |
| Data access | **`fetch` + `zod`** | Zod validates/parses the YouTube JSON shapes at the boundary → typed domain model, explicit parse errors (constitution §1.6). |
| Persistence | **AsyncStorage** (JSON snapshot) | Single source of truth the UI reads from (constitution §1.5); simplest reliable stale-fallback cache. 24h TTL, replace-on-refresh, serve-stale-on-error. |
| Errors / state | **`Result<T>` union** + sealed **UiState** (`loading` / `content` / `empty` / `error`) | The state contract the harness asserts (loading_indicator / error_view / video_list). |
| Map | **react-native-webview + Leaflet/OSM** for the real map, **native `map_marker` chip row** for the accessible affordance (constitution §5) | WebView DOM markers are unreachable by Maestro; a native chip per located video is the uniform, tappable affordance. Bottom sheet is a native absolutely-positioned View (not a separate window → testIDs reachable, constitution §5a). |
| Launch args | **Local Expo native module `TestConfig`** (Kotlin) reading `currentActivity.intent.extras` | RN doesn't surface intent extras to JS; the module returns them so UI-test-mode (constitution §4) works via Maestro `launchApp.arguments`. |
| Auth | Mock path via `mockAuthEmail`; real path via `@react-native-google-signin` (documented, guarded) | UI-test-mode swaps only the non-deterministic account picker; whitelist logic runs identically. |
| External open | `Linking.openURL` (no `canOpenURL` gate) wrapped in try/catch → `external_open_error` on throw; capture mode renders `external_open_url` at app root | Avoids the known RN `canOpenURL` false-negative bug (AC-LINK-01); the capture banner is lifted to the root so list + map share it. |

## 2. Layered architecture (constitution §1)

```
src/
  data/        network (api.ts), persistence (cache.ts), boundary types + zod schemas
  domain/      pure logic: auth whitelist, sort, filter, video-count  (unit-tested)
  state/       zustand stores + testConfig loader (DI seam: base URL/key/whitelist injected at runtime)
  ui/          screens + components; render purely from observable view-state
modules/test-config/   native Kotlin module (intent extras)
```

- **Dependency inversion:** UI reads stores; stores call a `DataSource` built from runtime
  `TestConfig` (base URL, key, whitelist). Nothing in UI knows the concrete host — it is injected,
  so the mock↔real swap is a runtime change (constitution §2, §4).
- **Off the UI thread:** all network/disk is `async` (JS is single-threaded but non-blocking;
  fetch + AsyncStorage never block rendering).
- **Single source of truth:** the videos store is hydrated from cache first, then refreshed from
  network; UI always renders the store.

## 3. Data flow (aggregate + paginate + enrich)

1. Read `config/channels.json` (bundled). **No catch-all** — iterate every channel.
2. For each channel: `GET /youtube/v3/search?channelId=..&part=snippet&type=video&order=date&maxResults=50`,
   follow `nextPageToken` until exhausted. Tag each video `category = channel.label`.
3. Merge all channels, **dedupe by videoId**.
4. Enrich: `GET /youtube/v3/videos?id=<batch of ≤50>&part=snippet,contentDetails,recordingDetails`
   → attach `location` from `recordingDetails.location` (only located videos get markers).
5. Map to domain `Video { id, title, description, publishedAt, category, thumbnailUrl, lat?, lng?, youtubeUrl }`.
   `youtubeUrl = https://www.youtube.com/watch?v=<id>`.
6. Persist snapshot; UI count = `videos.length` (surfaced via `video_count`).

**Default list order = fetch order** (channel order, page order) so the first row is the first
channel's first video (AC-LIST-03). Sorting/filtering are explicit user actions layered on top.
Nothing reads fixture values — counts, ids, titles, and locations all come from the API.

## 4. Selector & UI-test-mode contracts

All IDs from constitution §3 are applied via `testID` on the interactive/asserted element (RN
aggregates descendant text onto the tagged node, so `video_list_item` carries its title for
AC-SORT-01). Popups are plain in-tree Views/Modals so testIDs stay reachable (§5a). UI-test-mode
extras are read once at startup from the `TestConfig` module and drive: mock sign-in, base URL, API
key, whitelist, and capture-vs-real external open.

## 5. Testing & validation

- **Unit tests (Jest):** auth whitelist, sort (date/title asc+desc), filter (by label), video-count,
  cache read/write round-trip.
- **E2E:** the 14 `flows/AC-*.yaml` run via Maestro against a **release** APK on device
  `25251FDF60029V`, mock at `http://127.0.0.1:8090` via `adb reverse`.

## 6. Known RN gotchas honored (from cross-framework-setup §A/§C, playbook)

- Build **release** (`assembleRelease`), not debug (debug needs Metro).
- `usesCleartextTraffic: true` (reach the http mock).
- `testID` on the Pressable itself, not only inner Text.
- Native `map_marker` chips (WebView DOM pins unreachable); native bottom sheet.
- `external_open_url` banner lifted to app root (shared by list + map).
- No `canOpenURL` gate on the real launch path (AC-LINK-01).
</content>
</invoke>
