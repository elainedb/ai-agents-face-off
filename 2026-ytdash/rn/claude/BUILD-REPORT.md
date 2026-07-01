# Build Report — YouTube Dashboard ("ytdash"), React Native / Expo

## 1. Stack chosen

| Concern | Choice |
|---|---|
| Framework | React Native 0.86 on **Expo SDK 57** (TypeScript, Hermes, New Architecture), prebuilt to a native Android project and shipped as a **debug-signed release APK** (`assembleRelease`). |
| Navigation | State-driven (a `zustand` `navStore` + conditional render of Login / Home / Map). No router — three screens + overlays don't justify the native surface. |
| State management | **zustand** — four small stores: `authStore`, `videoStore`, `externalStore`, `navStore`. Unidirectional, observable view-state. |
| Networking / parsing | `fetch` + defensive optional-chained mapping from the YouTube wire shapes to the domain model. `zod` available. |
| Persistence / cache | **@react-native-async-storage/async-storage** (JSON envelope). Single source of truth; replace-on-refresh; stale-cache fallback on network failure. |
| Map | **react-native-webview + Leaflet + OpenStreetMap tiles** for the real OSM map, plus a **native `map_marker` chip overlay** (one per located video) as the black-box-reachable affordance. |
| Launch-extras bridge | Local Expo module `modules/test-config` (Kotlin `Function("getTestConfig")` reading `currentActivity.intent.extras`). |
| Auth | Mock-email sign-in (UI-test-mode) → whitelist rule. Real Google Sign-In is a documented seam (see §4). |
| Tests | `jest-expo` — 13 unit tests over auth / sort / filter / cache. |

Architecture is layered per the constitution: `data/` (network + AsyncStorage) → `domain/` (pure
auth/sort/filter/models) → `state/` (zustand view-state) → `ui/` (presentation). Presentation
depends on the repository/store abstractions, never on `fetch`/AsyncStorage directly.

## 2. Acceptance-criteria result (mock build)

All **14** Maestro flows pass against the mock, run on the physical target device `25251FDF60029V`
(Pixel 6), mock reached via `adb reverse tcp:8090`.

| AC | Result | AC | Result |
|---|---|---|---|
| AC-LOGIN-01 | ✅ | AC-CACHE-01 | ✅ |
| AC-LOGIN-02 | ✅ | AC-FILTER-01 | ✅ |
| AC-LOGIN-03 | ✅ | AC-SORT-01 | ✅ |
| AC-LIST-01 | ✅ | AC-MAP-01 | ✅ |
| AC-LIST-02 | ✅ | AC-MAP-02 | ✅ |
| AC-LIST-03 | ✅ | AC-MAP-03 | ✅ |
| AC-COUNT-01 | ✅ | AC-LINK-01 | ✅ |

`map_marker_fallback_used = false` for *reachability* (the native chip is a real, accessible node —
not a coordinate tap). Per constitution §5, the WebView/Leaflet DOM pins are intentionally **not**
the harness affordance; the native chips are. Both render; human taps on pins postMessage back to
select the same video.

JUnit reports are in `results/`.

## 3. Anti-overfit / data flow

- Channels are read from `config/channels.json` at build time — never hard-coded.
- The client iterates every configured channel, follows `nextPageToken` to the last page (mock page
  size = 2), and dedupes by `videoId`. Nothing is keyed to fixture ids, counts, or titles.
- `video_count` = total loaded across all channels (surfaced only after all pages are fetched).
- Locations come from `videos.list?part=...,recordingDetails`; category = the source channel label.
- Default list order = API/aggregation order (so "the first row opens the first video"); date/title
  sorts apply only when the user chooses them.

## 4. Real-API mode & deviations

- **Real API data:** the same build talks to real YouTube by swapping the `apiBaseUrl` + `apiKey`
  launch extras (read at runtime). The base URL is never hard-coded (default host
  `https://www.googleapis.com`, overridable). The provided key lives in `config/secrets.env` (git-
  ignored) and is supplied at runtime — never committed.
- **Deviation — real Google Sign-In:** a full interactive Google sign-in needs
  `google-services.json` / Firebase config, which is **not present** in this workspace (only a
  YouTube Data API key was provided). The sign-in *seam* (`src/auth/googleSignIn.ts`) and the
  **whitelist domain rule** it feeds are implemented and unit-tested; the interactive account picker
  is the only unbuilt piece. Because every AC runs in UI-test-mode (fixed mock email, per
  constitution §4), this does not affect the functional score. To finish production auth: add
  `@react-native-google-signin/google-signin`, drop in `google-services.json`, and the existing
  `signInWithEmail(email, cfg)` path handles the whitelist unchanged.

## 5. Quality

- `tsc --noEmit`: clean.
- `jest`: 13/13 passing (auth whitelist, sort, filter, cache round-trip).
- No secrets committed (`config/secrets.env` git-ignored; key read from launch extra at runtime).
- Every screen has explicit loading / empty / error(+retry) states; no silent failures.

## 6. How to reproduce

```bash
# 1. mock already running on host:  python3 mock/youtube-mock-server.py --port 8090 \
#      --channels "$(python3 -c 'import json;print(",".join(f"{c[\"id\"]}:{c[\"label\"]}" for c in json.load(open("config/channels.json"))))')"
npx expo prebuild --platform android --clean
(cd android && ./gradlew assembleRelease)
adb -s 25251FDF60029V install -r android/app/build/outputs/apk/release/app-release.apk
adb -s 25251FDF60029V reverse tcp:8090 tcp:8090
maestro --device 25251FDF60029V test \
  -e APP_ID=com.example.ytdash_rn -e MOCK_API_BASE=http://127.0.0.1:8090 \
  -e AUTHORIZED_EMAIL=user2@example.com -e UNAUTHORIZED_EMAIL=intruder@gmail.com \
  -e VIDEO_COUNT=8 -e FILTER_LABEL=cronicas flows/
```
