# Implementation Plan — YouTube Dashboard ("ytdash"), Flutter

> Spec-Kit `/plan` artifact for the **frozen** spec (`spec/spec.md`,
> `spec/acceptance-criteria.md`) under the framework-neutral `spec/constitution.md`.
> This file records the engineering decisions (stack, architecture, contracts) that
> the spec deliberately leaves to the builder.

## 1. Stack choices (and why)

| Concern | Choice | Rationale |
|---|---|---|
| Language / SDK | Dart 3.10, Flutter 3.38 (stable) | Pinned by the scaffold; modern null-safety + records/patterns. |
| State management | **flutter_riverpod 3.x** (`Notifier` + `Provider`) | Compile-safe DI **and** observable, unidirectional view-state in one tool; provider overrides give a clean seam to inject the runtime `TestConfig`. No codegen → fewer build footguns. |
| Dependency inversion | Riverpod `Provider`s | Presentation depends on `AuthService` / `VideoRepository` abstractions, swapped via provider overrides (constitution §1.2). |
| Networking / JSON | **http** + hand-written `fromJson` | The 3 endpoints are simple; manual parsing avoids `build_runner` and keeps the mock↔real swap obvious. |
| Persistence (cache) | **shared_preferences** (JSON blob) | The spec only needs replace-on-refresh + stale-fallback (AC-CACHE-01); a relational store (sqflite) is overkill. Persists to disk so it survives the offline relaunch (fresh process). |
| Map | **flutter_map 8.x** + **latlong2** (OpenStreetMap tiles) | Idiomatic widget-based OSM map; markers are real widgets so they can carry `Semantics(identifier:'map_marker')` (cross-framework-setup §C). |
| External launch | **url_launcher** | Standard; real `https` launch in production, captured in UI-test-mode. |
| Auth | **google_sign_in 7.x** (real) / mock service (test) | Whitelist is the actual access gate; `GoogleAuthService` yields the account email, `MockAuthService` returns the injected `mockAuthEmail`. |
| Errors / UI-state | Sealed-style `enum` status + typed `ApiException`/`AuthException` | Loading / content / empty / error with a retry affordance everywhere (constitution §1.3, §1.6). |

## 2. Architecture (layered, constitution §1)

```
lib/src/
  config/    test_config.dart   — UI-test-mode extras via MethodChannel (§4)
             app_config.dart    — source channels (bundled asset) + prod fallbacks
  domain/    video.dart         — Video model (+ cache (de)serialization)
             auth_policy.dart   — pure whitelist logic (unit-tested)
             video_query.dart   — pure filter/sort (unit-tested)
  data/      youtube_api.dart   — paginate + aggregate + dedupe + enrich locations
             video_cache.dart   — shared_preferences persistence (unit-tested)
             video_repository.dart — network refreshes the store; store is SoT
             auth_service.dart  — Mock + Google implementations
  state/     providers.dart     — DI graph + provider overrides
             auth_controller.dart, videos_controller.dart, external_link_controller.dart
  ui/        app.dart, login_screen.dart, home_screen.dart, map_screen.dart,
             identified.dart (stable-id helper), external_link_overlay.dart
```

- **Data → Domain → Presentation**, one-way. UI reads observable `Notifier` state; no
  business logic in event handlers (constitution §1.3).
- **Single source of truth:** `VideoRepository.refresh()` writes the cache and the UI
  renders the returned list; on network failure it falls back to the cache (§1.5).
- **Off the UI thread:** all network/disk via `async`/`await` (§1.4).

## 3. Honoring the three contracts

- **Selector (§3):** every asserted element is wrapped in `Semantics(identifier: '<id>')`
  via the `Identified` helper (Flutter 3.19+ stable `identifier`, not `label`).
  `SemanticsBinding.instance.ensureSemantics()` is called in `main()`. Leaf elements use
  `excludeSemantics: true` so the id and its text resolve to one node (so
  `id + text` assertions like AC-SORT-01 match the same element). Screen roots use a
  container scope that keeps descendants individually addressable.
- **UI-test-mode (§4):** `MainActivity` exposes the launch-intent extras over the
  `ytdash/testconfig` MethodChannel; `TestConfig.fromHost()` reads them once in `main()`
  and they are injected through provider overrides. `apiBaseUrl`/`apiKey` are read at
  runtime — never baked in. `captureExternalLinks` toggles capture-vs-real-launch.
- **Map markers (§5):** the harness-reachable `map_marker` lives on an always-visible,
  accessible **chip strip** (one per located video); the flutter_map pins are tagged too.
  `map_marker_fallback_used = false`.

## 4. Data flow specifics (anti-overfit)

- Iterate **every** channel in `config/channels.json`; for each, follow `nextPageToken`
  until exhausted (mock page size = 2, so single-page builds fail AC-COUNT-01).
- Merge across channels, **dedupe by videoId**, preserve API/insertion order so the
  "first video" is deterministic (AC-LIST-03). No catch-all endpoint is assumed.
- `category` = the **source-channel label** (config), not YouTube's `categoryId`
  (AC-FILTER-01).
- Enrich locations via `videos.list?part=...,recordingDetails` in batches of 50.
- Nothing reads fixture-specific ids/titles/counts; all values come from the API.

## 5. Testing & quality

- Unit tests: `auth_policy` (whitelist), `video_query` (sort/filter/order), `video_cache`
  (persistence round-trip + replace), `video` (serialization). `flutter analyze` clean.
- E2E: the 14 `flows/AC-*.yaml` run against the mock on device `25251FDF60029V`.
