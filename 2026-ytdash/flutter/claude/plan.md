# Implementation Plan — YouTube Dashboard ("ytdash"), Flutter build

> Spec-Kit `/plan` artifact. Input is the **frozen** spec (`spec/spec.md`,
> `spec/acceptance-criteria.md`, `spec/constitution.md`). This document is the engineering
> decision record: stack, architecture, and how each constitution contract is honored.

## 1. Stack decision (and why)

| Concern | Choice | Rationale |
|---|---|---|
| Language / SDK | Dart 3.10, Flutter 3.38 (stable) | Provided toolchain; Semantics `identifier` (3.19+) is the mandated stable-selector mechanism. |
| State management | `provider` + `ChangeNotifier` view-models | Idiomatic, lightweight, gives explicit **unidirectional observable state** (sealed `ViewState`) without codegen overhead. Constitution §1.3. |
| DI | `provider` `MultiProvider` at the root | Presentation depends on **abstractions** (`VideoRepository`), constructed once and injected. Constitution §1.2. |
| HTTP / JSON | `http` + hand-written `fromJson` | Mirrors the real YouTube Data API shapes (`spec/youtube-api.md`); no codegen needed for 1 model. |
| Local store | `shared_preferences` (JSON blob) | Single source of truth the UI reads from; survives process death for the offline-relaunch test (AC-CACHE-01). Constitution §1.5. Behavior — *replace-on-refresh + stale-fallback* — is what is speced, not the engine. |
| Map | `flutter_map` (OpenStreetMap tiles) + `latlong2` | The one engine whose markers are **real widgets** → wrappable in `Semantics(identifier:'map_marker')` (cross-framework §C). |
| External launch | `url_launcher` | Real `https` launch in production / `captureExternalLinks=false`. |
| Auth (real) | `google_sign_in` | Real Google identity; whitelist enforced in the domain layer, not the UI. |
| Test-mode bridge | `MethodChannel('ytdash/testconfig')` | Reads Android `intent.extras` at startup (constitution §4) — the runtime seam v3 lacked. |

## 2. Layered architecture (constitution §1)

```
lib/src/
  config/        runtime config (test-mode extras), bundled channels + default whitelist
  data/
    models/      Video domain model (+ JSON mapping for both API shapes)
    api/         YoutubeApi  — search.list (paginated) + videos.list (locations), per-channel
    cache/       VideoCache  — shared_preferences JSON, single source of truth
    repository/  VideoRepository — aggregate channels, dedupe, persist, stale-fallback
  domain/        auth (whitelist), sorting, filtering  — pure functions, unit-tested
  presentation/  app_state (auth + external-link capture), login/home/map screens, view-models
```

- **(a) data** never imports presentation. **(b) domain** is pure Dart (no Flutter). **(c) presentation**
  depends only on `VideoRepository` (abstract) + view-models. Dependency inversion via `provider`.
- **Observable state:** `HomeViewModel extends ChangeNotifier` exposes `ViewState` =
  `loading | content | empty | error`. No business logic in widget callbacks.
- **Off the UI thread:** all network/disk via `async`/`await` (Dart isolate event loop; `http` +
  `shared_preferences` are async).
- **Explicit errors:** every edge returns a typed `Result`/throws into a caught path that resolves to
  `error_view` + `error_retry_button`. Offline → stale cache, no blocking error.

## 3. Data flow (the anti-overfit core)

1. Load `config/channels.json` (bundled asset) → list of `{id,label}` source channels.
2. For **each** channel: `GET {base}/youtube/v3/search?channelId=&part=snippet&type=video&order=date&maxResults=50&key=`,
   **following `nextPageToken`** until exhausted. Tag every returned video with that channel's **label**
   (= category; constitution/youtube-api mapping). There is **no catch-all** — channels are iterated.
3. Collect all video ids → `GET {base}/youtube/v3/videos?id=...&part=snippet,contentDetails,recordingDetails`
   (batched ≤50) to obtain `recordingDetails.location` for the located subset.
4. Merge by `id`, **dedupe**, preserve channel+API order (so list index 0 = first video of first channel
   → AC-LIST-03). Persist the merged list to the cache. UI renders from the cache.
5. `video_count` = total distinct loaded (8 for the fixture **only if all pages of all channels were
   fetched** — AC-COUNT-01).

Nothing is hardcoded to fixture values: ids, titles, counts, locations all come from the responses.

## 4. Constitution contract honoring

- **§3 Selectors:** every element in the table wrapped in `Semantics(identifier: '<id>')`. List rows
  carry the title text inside the same node (Flutter aggregates descendant text). `ensureSemantics()`
  called in `main()`.
- **§4 UI-test-mode:** `MainActivity` exposes `intent.extras` over a MethodChannel; `TestConfig.load()`
  reads `uiTestMode, mockAuthEmail, apiBaseUrl, apiKey, authorizedEmails, captureExternalLinks` at
  startup. `apiKey` read at **runtime** (not baked in) so one build hits mock or real.
- **§5 Map markers:** `flutter_map` markers wrapped in `Semantics(identifier:'map_marker')` **and** a
  guaranteed-visible "Markers" chip row (one `map_marker` per located video) so Maestro can always
  initiate the tap. `detail_bottom_sheet` is an in-tree `Align`+`Material` overlay (reachable).
  `map_marker_fallback_used=false`.
- **§5a Overlays:** all asserted popups (logout menu, detail sheet, captured-URL banner) live in the
  main widget tree / same semantics tree — no separate-window trap.
- **External capture lifted to app root** so the list (iter 2) and map sheet (iter 4) share one
  `external_open_url` / `external_open_error` surface.

## 5. Testing & quality (constitution §2)

- Domain unit tests: whitelist (authorized/!authorized/case-insensitive), sort (date asc/desc, title),
  filter (by label). Cache test: write→read round-trip.
- `flutter analyze` clean (flutter_lints).
- No secrets committed: API key + whitelist supplied at runtime; `config/secrets.env` git-ignored.
- Base URL overridable via `apiBaseUrl` extra; production host not hardcoded.

## 6. Validation

Build APK, `adb reverse tcp:8090 tcp:8090` (physical device `25251FDF60029V`), run `flows/AC-*.yaml`
against `http://127.0.0.1:8090` until all 14 pass. Then smoke-check real mode (real base URL + key).
