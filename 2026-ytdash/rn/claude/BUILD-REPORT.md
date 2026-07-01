# BUILD-REPORT — YouTube Dashboard ("ytdash") · React Native / Expo

## Result summary

| Check | Result |
|---|---|
| **Mock AC suite** (`flows/AC-*.yaml`, 14 flows) | **14 / 14 PASS** — run twice back-to-back, identical (no flakiness) |
| **Real-API smoke** (`flows/REAL-LIST.yaml`, live YouTube Data API) | **PASS** — list populates from live data, no error state |
| **Unit tests** (`npm test`, ts-jest) | **14 / 14 PASS** across 4 suites (auth, sort, filter, cache round-trip) |
| **Typecheck** (`npx tsc --noEmit`) | **Clean** (0 errors) |
| **Build** | `assembleRelease` → standalone, embedded-JS release APK, installed on `25251FDF60029V` |

Target device: `25251FDF60029V` (physical). Mock reached via `adb reverse tcp:8090` → `http://127.0.0.1:8090`.

## Stack chosen (the engineering decision under evaluation)

| Concern | Choice |
|---|---|
| Platform | Expo SDK 57, RN 0.86, React 19, Hermes, New Architecture |
| Language | TypeScript (`strict`) |
| Navigation | Explicit root state machine (`login → home → map`) in the store — no router; keeps every harness-asserted element in one view tree |
| State | **zustand** (single observable store), sealed `UiStatus` (`idle/loading/content/empty/error`) |
| HTTP / parse | `fetch` + hand-written typed mappers (raw API JSON ⇄ domain `Video`) |
| Persistence | **`@react-native-async-storage/async-storage`** (JSON envelope + 24h TTL, replace-on-refresh, stale-fallback) |
| Auth | Pluggable `AuthService`: `MockAuthService` (UI-test-mode) + `GoogleAuthService` (production) |
| Map | **Leaflet in `react-native-webview`** (real OSM pins) + **native `map_marker` overlay row** (the accessible affordance) |
| External open | `Linking.openURL` behind a root capture/error seam |
| Test-mode seam | Local Expo module `modules/test-config` (Kotlin) reading `intent.extras` |

Full rationale in `plan.md`; dependency-ordered work in `tasks.md`.

## How each constitution contract was met

- **§3 Selectors** — every logical ID in the table is exposed as a `testID` (RN → Android resource-id).
  Row `testID` sits on the `Pressable` so `id + text` resolves on the same node (AC-SORT/AC-LIST).
- **§4 UI-test-mode** — `modules/test-config` surfaces the 6 launch extras to JS; `mockAuthEmail`
  short-circuits the account picker, `apiBaseUrl`/`apiKey` are injected at **runtime** (same build hits
  mock or real), `captureExternalLinks` toggles the open seam. Booleans are coerced defensively.
- **§5 Map markers** — osmdroid/Leaflet-DOM pins are unreachable to Maestro, so a native `map_marker`
  Pressable per located video is the harness affordance; the WebView pins `postMessage` taps to native
  as the human path. `map_marker_fallback_used = false` (native affordance, not coordinate taps).
- **§5a Overlays** — filter/sort panels, the detail sheet, the overflow menu, and the external-open
  banner are plain absolutely-positioned Views in the **main tree** (not separate windows), so their
  testIDs are always reachable — the RN analogue of the Compose popup trap.
- **§6 Error handling** — every failure point resolves to a visible state: `login_error_message`,
  `error_view` + `error_retry_button`, `external_open_error`, stale-cache fallback (no blocking error
  offline).

## Anti-overfit compliance

- Channels are read from `config/channels.json`; the app iterates all of them and **merges/dedupes by
  videoId** (first-wins → stable order). No catch-all endpoint, no `channelId=ALL` shortcut.
- **Pagination is followed** (`nextPageToken`) to exhaustion for every channel — this is why
  `video_count = 8` passes (the mock paginates with page-size 2).
- `category` = the **source channel's configured label**, derived at fetch time — not YouTube's
  numeric `categoryId`, not a hardcoded bucket.
- Locations come from `videos.list` `recordingDetails.location`; nothing is keyed off fixture ids,
  titles, counts, or coordinates. The same code passed the live-API smoke unchanged.

## The one real bug found and fixed

Initial run was **12/14**; `AC-FILTER-01` and `AC-SORT-01` crashed the app
("Maximum update depth exceeded" in `HomeScreen`). Root cause: a zustand v5 selector
(`useStore(selectVisibleVideos)`) returned a **fresh filtered/sorted array on every call**, failing the
store's `Object.is` snapshot check and looping forever. It only manifested once a filter/sort was
active (an unfiltered pass returned the same `videos` reference), which is why list/login passed but
filter/sort crashed. Fixed by deriving the visible list with `useMemo` over the raw
`(videos, filterLabel, sortKey)` state in the component. → 14/14, stable across repeat runs.

## Deviations / known limitations

- **Real Google Sign-In is implemented as a guarded path but not activated**: no `google-services.json`
  / OAuth web-client is provisioned anywhere in this workspace. `GoogleAuthService` therefore surfaces
  an explicit, visible error (rendered as `login_error_message`) instead of crashing — honoring §6.
  Dropping in `google-services.json` + `@react-native-google-signin` and calling `GoogleSignin.signIn()`
  is the only change needed; the whitelist logic (`isAuthorized`) is shared and already tested. **All
  14 scored ACs run in UI-test-mode (`mockAuthEmail`), so this does not affect the functional score**,
  and the live-API data path is proven by `REAL-LIST`.
- `jest-expo@57` peers to RN 0.85's moved jest-preset; tests run via **ts-jest** on the pure domain +
  cache layers instead (14 passing). UI is validated end-to-end by Maestro rather than by unit tests.

## No secrets committed

The API key and whitelist are read at runtime from launch extras (mock/harness) or from
`config/secrets.env` (gitignored) for production. No key or `google-services.json` is written into
source or these reports.

## Reproduce

```bash
# mock is served at http://127.0.0.1:8090 (config channels, page-size 2)
adb -s 25251FDF60029V reverse tcp:8090 tcp:8090
adb -s 25251FDF60029V install -r android/app/build/outputs/apk/release/app-release.apk
maestro --device 25251FDF60029V test \
  -e APP_ID=com.example.ytdash_rn -e MOCK_API_BASE=http://127.0.0.1:8090 \
  -e AUTHORIZED_EMAIL=user2@example.com -e UNAUTHORIZED_EMAIL=deny@example.com \
  -e VIDEO_COUNT=8 -e FILTER_LABEL=cronicas flows/
npm test          # unit tests
```
