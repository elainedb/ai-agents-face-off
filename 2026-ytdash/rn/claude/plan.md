# Implementation Plan — YouTube Dashboard ("ytdash"), React Native / Expo

> Spec-Kit `plan` artifact. Input: the frozen `spec/spec.md`, `spec/acceptance-criteria.md`, and
> `spec/constitution.md`. This document records the **engineering decisions** — the stack, the
> layering, and how each mandatory contract is satisfied. The *what* is frozen; the *how* below is
> mine to choose (constitution §6).

## 1. Stack selection (and why)

| Concern | Choice | Rationale |
|---|---|---|
| Language / SDK | TypeScript, **Expo SDK 57**, React Native 0.86, Hermes, New Architecture | Idiomatic RN; Expo gives prebuild + a clean native-module story without ejecting by hand. |
| Navigation | **Lightweight state-driven navigation** (a `zustand` `navStore` + conditional render of `Login`/`Home`/`Map`) | Only three screens + overlays. A full router (expo-router/react-navigation) adds native surface and build risk for zero functional gain here. Screens are plain components; the choice is justified by the small, fixed screen graph. |
| State | **zustand** — 4 small stores (`auth`, `video`, `external`, `nav`) | Unidirectional, observable view-state (constitution §1.3) with almost no boilerplate; the reference RN best-run used the same. |
| HTTP / parse | `fetch` + defensive hand-mapping (optional-chained wire → domain), `zod` available | The API shapes are simple; explicit mapping keeps the data layer readable and null-safe. |
| Persistence | **@react-native-async-storage/async-storage** (JSON envelope) | Single source of truth the UI reads from (constitution §1.5); survives a `clearState:false` relaunch, which is exactly what AC-CACHE-01 exercises. Replace-on-refresh + stale-fallback. |
| Map | **react-native-webview + Leaflet + OSM tiles**, plus a native `map_marker` chip overlay | The idiomatic RN OSM stack. Constitution §5: DOM markers aren't reachable by a black-box tool, so the native chip row is the harness affordance; the WebView pins postMessage back for the human path. |
| Launch-extras bridge | **Local Expo module** `modules/test-config` (Kotlin `Function("getTestConfig")`) | RN doesn't surface intent extras to JS. A tiny autolinked module reads `currentActivity.intent.extras` (constitution §4 / cross-framework-setup §B). |
| External open | `Linking.openURL` behind an `externalStore`, capture-vs-launch switched by `captureExternalLinks` | Real launch in production; deterministic `external_open_url` capture under test; `external_open_error` on a failed real launch — never a crash/no-op. |
| Auth | Mock email (test mode) → whitelist rule; real Google Sign-In is a documented seam | The domain rule (whitelist) is what's tested and is fully implemented + unit-tested. |
| Tests | `jest-expo` unit tests for auth / sort / filter / cache | Constitution §2 quality bar: meaningful logic coverage. |

## 2. Layered architecture (constitution §1)

```
src/
  appConfig.ts        # resolve launch extras → typed AppConfig (base URL always overridable)
  channels.ts         # read config/channels.json (source channels; never hard-coded)
  domain/             # (b) business logic — pure, no RN imports
    models.ts  auth.ts  sort.ts  filter.ts
  data/               # (a) data access
    youtubeApi.ts     # aggregate channels, paginate, dedupe, enrich locations
    cache.ts          # AsyncStorage source of truth
    repository.ts     # network→cache→stale-fallback seam (dependency inversion boundary)
  state/              # observable view-state (zustand)
    authStore  videoStore  externalStore  navStore
  ui/                 # (c) presentation — renders from view-state, no business logic in handlers
    LoginScreen  HomeScreen  MapScreen  ExternalBanner
modules/test-config/  # native intent-extras bridge
```

Presentation depends on the stores and the repository *abstraction*, never on `fetch`/AsyncStorage
directly (constitution §1.2). Domain modules are pure and independently testable. Network + disk run
off the UI thread via async store actions (constitution §1.4).

## 3. How each mandatory contract is met

- **Selector contract (§3):** every asserted element carries the exact `testID` string. Rows use
  `testID="video_list_item"` on the `Pressable` (RN aggregates descendant text, so the title
  resolves on the same node for AC-SORT-01). `video_count` shows the **total loaded** count.
- **UI-test-mode (§4):** `getTestConfig()` reads `uiTestMode`, `mockAuthEmail`, `apiBaseUrl`,
  `apiKey`, `authorizedEmails`, `captureExternalLinks` at runtime. `apiKey`/base URL are read per-run
  so one build hits the mock or real YouTube unchanged.
- **Overlays reachable (§5a):** the detail sheet and external banner are plain absolutely-positioned
  `View`s (not `Modal`/separate windows), so their `testID`s are always reachable.
- **Map markers (§5):** native `map_marker` chip per located video is the reachable affordance;
  tapping selects the video and shows `detail_bottom_sheet` with `detail_open_youtube_button`.

## 4. Data flow (fetch-all, no shortcuts — anti-overfit)

1. For each channel in `config/channels.json`: `GET /youtube/v3/search?channelId=…` following
   `nextPageToken` to the last page (mock uses page size 2 to force this). Category = channel label.
2. Merge all channels, **dedupe by videoId**, preserve first-seen order.
3. `GET /youtube/v3/videos?id=…&part=…,recordingDetails` (chunks of 50) to attach locations.
4. Persist to AsyncStorage; UI reads from the store. Nothing is keyed to fixture ids/counts.

## 5. Known deviation

Real interactive Google Sign-In requires `google-services.json`, which is **not present** in this
workspace (only a YouTube API key is provided). The sign-in *seam* and the whitelist domain logic
are implemented and tested; the real account-picker is a documented gap. All 14 ACs run in
UI-test-mode (mock email), so this does not affect the functional score. See BUILD-REPORT.md.
