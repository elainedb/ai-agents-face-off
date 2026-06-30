# Implementation Plan — YouTube Dashboard (Flutter)

> Spec-Kit `/plan` artifact. The **what** is frozen (`spec/spec.md`, `spec/acceptance-criteria.md`,
> `spec/constitution.md`); this document is the **how** — the engineering decisions that are being
> evaluated. The constitution is framework-neutral by design; everything below is my choice for the
> Flutter build.

## 1. Stack (and why)

| Concern | Choice | Why this one |
|---|---|---|
| Language / SDK | Dart 3.10, Flutter 3.38 (stable) | Provided toolchain; `flutter_lints` for static cleanliness. |
| State management | **`provider` + `ChangeNotifier`** | Idiomatic, lightweight, gives the constitution's *unidirectional, observable* view-state (§1.3) without the ceremony (codegen, build_runner) of bloc/freezed. Three focused controllers keep concerns separable. |
| DI | `provider` (`MultiProvider`) | Presentation depends on the `VideoRepository` **abstraction**, not the concrete data source (constitution §1.2). The repo is constructed in `main()` and injected. |
| HTTP / JSON | **`http`** + hand-written `fromJson` | The API surface is tiny (3 endpoints). Manual mapping avoids build_runner and makes the real↔mock shape-mirroring explicit. |
| Local store | **`shared_preferences`** (JSON blob) | The single source of truth the UI reads from (§1.5). Must survive a *fresh-process* offline relaunch (AC-CACHE-01), so it's on disk, not in memory. The store is replaceable behind `VideoCache`. |
| Map | **`flutter_map`** + `latlong2` (OpenStreetMap tiles) | The one map engine whose markers are *real widgets*, so they're a11y-reachable (cross-framework-setup §C). Still backed by an accessible chip affordance for determinism. |
| External open | **`url_launcher`** | Real external launch in production; captured deterministically in UI-test mode. |
| Auth | **`google_sign_in`** + email whitelist | Real Google sign-in on the production path; the mock-auth extra swaps only the account-picker edge in test mode (constitution §4). |

## 2. Architecture — three separable layers (constitution §1.1)

```
presentation/         (a) view-state + screens — depends only on abstractions
  auth_controller         ChangeNotifier: login/whitelist view-state
  video_controller        ChangeNotifier: Loading/Content/Empty/Error + filter/sort projection
  external_open_controller ChangeNotifier: capture-or-launch, lifted to app root
  login/home/map screens   render from observable state; no business logic in handlers
  widgets/test_id          stable Semantics(identifier) wrapper (constitution §3)
domain/               (b) pure business logic — no IO, unit-tested
  auth                     AuthPolicy.isAuthorized (whitelist)
  video_query              filter / sort / categoriesOf
data/                 (c) data access — network + persistence
  youtube_api              search.list + videos.list, pagination, channel aggregation
  video_cache              shared_preferences read/write
  video_repository         abstraction + impl (network → cache, stale-fallback)
  channel_config           loads config/channels.json (bundled asset)
  models/video             domain model
core/
  test_config              reads launch-intent extras over a MethodChannel (§4)
  result                   sealed Result<T> / Failure (typed errors, §1.6)
```

State flow is unidirectional: events call controller methods → controllers mutate state and
`notifyListeners()` → `Consumer`/`watch` rebuilds. No business logic lives in UI callbacks.

## 3. How the mandatory contracts are honored

- **Selector contract (§3).** Every asserted element is wrapped in `Semantics(identifier: '<id>')`
  via `TestId`. On-device finding: an `identifier` placed as an *ancestor* of a widget that
  produces its own clickable/text node does **not** surface on that node — Maestro sees the label
  but no `id`. `TestId` therefore wraps non-container elements in `MergeSemantics`, collapsing the
  identifier and the label/clickable into a single node. Large containers (screens, the list) stay
  un-merged so their children remain individually addressable.
- **UI-test-mode (§4).** `MainActivity` exposes `intent.extras` over the `ytdash/testconfig`
  MethodChannel; `TestConfig.load()` reads them once in `main()`. `apiBaseUrl` + `apiKey` are read
  at **runtime**, so one build talks to the mock or real YouTube by swapping extras — nothing is
  baked in.
- **Map markers (§5).** The reachable affordance is a native `ActionChip` row (one `map_marker` per
  located video), rendered **first** so `map_marker` index 0 is deterministic. flutter_map's
  rendered pins are *also* tagged `map_marker` (the engine allows it), but the chips are the
  guaranteed path. `map_marker_fallback_used=false`.
- **Overlays reachable (§5a).** The detail sheet is an in-tree `Align`+`Material` overlay (Flutter
  routes/overlays share the semantics tree), and the `external_open_url`/`external_open_error`
  banner is lifted into `MaterialApp.builder` above the Navigator so the same surface serves the
  list and the map sheet.

## 4. Anti-overfit guarantees
- **No catch-all.** `YoutubeApi.fetchAllVideos` iterates every channel in `config/channels.json`
  and merges/dedupes by videoId. There is no `channelId=ALL` shortcut.
- **All pages.** Each channel follows `nextPageToken` until exhausted (the mock paginates at
  page_size=2; AC-COUNT-01 = 8 proves the full walk).
- **Read everything from responses.** Titles, ids, dates, thumbnails come from the snippet;
  locations from `videos.list` `recordingDetails`. `category` = the **source-channel label** from
  config. No fixture value is hardcoded.

## 5. Quality bar
- Unit tests for the domain layer (auth whitelist, filter, sort) + a persistence round-trip test.
- `flutter analyze`: 0 errors (2 info-level style hints, reported).
- No secrets in source control: the API key and whitelist arrive at runtime; `config/secrets.env`
  is gitignored.
