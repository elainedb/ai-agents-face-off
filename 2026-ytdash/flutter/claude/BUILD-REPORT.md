# BUILD-REPORT — YouTube Dashboard ("ytdash"), Flutter

## Result summary

| Metric | Result |
|---|---|
| Acceptance criteria (mock build) | **14 / 14 flows PASS** |
| Stability | 3 full-suite runs (2× debug, 1× release) — all 14/14, no flakiness |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` (47.5 MB) — full suite 14/14 |
| Real YouTube Data API smoke | `REAL-LIST.yaml` PASS — live list populates, no error |
| Unit tests | 15 / 15 PASS (`flutter test`) |
| Static analysis | `flutter analyze` — **No issues found** |
| `map_marker_fallback_used` | **false** (flutter_map widget markers ARE reachable; chip row kept for parity) |
| Secrets committed | none (`config/secrets.env` git-ignored; API key read at runtime) |

Device: `25251FDF60029V` (physical). Mock reached via `adb reverse tcp:8090 tcp:8090` →
`http://127.0.0.1:8090`.

## Stack chosen (and why) — see `plan.md` for the full rationale

| Concern | Choice |
|---|---|
| State management | `provider` + `ChangeNotifier` view-models (sealed `ViewState`: loading/content/empty/error) |
| DI | `provider` `MultiProvider` at the root (presentation depends on the abstract `VideoRepository`) |
| HTTP / JSON | `http` + hand-written `fromJson` (mirrors both YouTube API shapes) |
| Local store | `shared_preferences` (JSON blob) — single source of truth, survives process death |
| Map | `flutter_map` + `latlong2` (OpenStreetMap tiles; markers are real widgets) |
| External launch | `url_launcher` |
| Auth (real) | `google_sign_in` |
| Test-mode seam | `MethodChannel('ytdash/testconfig')` reading `intent.extras` |

## How each constitution contract is honored

- **§3 Selectors.** Every contract id is exposed via Flutter `Semantics(identifier:)`, surfaced to
  Maestro as `resource-id`. Implemented with two helpers in `lib/src/presentation/widgets/test_id.dart`:
  - `IdNode` — structural/interactive ids, `explicitChildNodes: true` so nested ids are **not merged
    away** by an ancestor (the bug found and fixed during bring-up — see below).
  - `IdText` — ids that must carry id **and** text on one node (`video_list_item`, `video_count`,
    `detail_video_url`, `external_open_url`, `login_error_message`): text set as the semantics `label`
    with the visual subtree wrapped in `ExcludeSemantics` so exactly one leaf node carries both.
- **§4 UI-test-mode.** `MainActivity` exposes `intent.extras` over the MethodChannel; `TestConfig.load()`
  reads `uiTestMode, mockAuthEmail, apiBaseUrl, apiKey, authorizedEmails, captureExternalLinks` at
  startup. `apiKey` is read at **runtime** — the same APK hits the mock or the real API by swapping
  two extras (verified: mock 14/14 **and** live YouTube `REAL-LIST` both on one build).
- **§5 Map markers.** `flutter_map` markers wrapped in `Semantics(identifier:'map_marker')` (reachable
  — the flutter_map exception the contract predicts) **plus** a guaranteed-visible horizontal chip row
  (one `map_marker` per located video) so Maestro can always initiate the tap. `detail_bottom_sheet`
  is an in-tree `Align`+`Material` overlay (same semantics tree → reachable). `map_marker_fallback_used=false`.
- **§5a Overlays.** Logout menu, detail sheet, and the captured-URL banner all live in the main widget
  tree / shared semantics tree — no separate-window trap. The `external_open_url`/`external_open_error`
  surface is **lifted to the app root** (`ExternalLinkOverlay` via `MaterialApp.builder`) so the list
  (iter 2) and the map sheet (iter 4) share one banner.

## Anti-overfit / data flow

- Channels are read from `config/channels.json` (bundled asset) and **iterated** — no catch-all.
- `search.list` per channel **follows `nextPageToken` to exhaustion**; `videos.list` (batched ≤50)
  supplies `recordingDetails.location`. Results merged + **deduped by id**, channel+API order preserved.
- `video_count` = total distinct loaded → `8` only because all pages of all channels are fetched
  (AC-COUNT-01 passes). Nothing is keyed to fixture ids/titles/counts; all come from the responses.
- Verified by a unit test that drives a `MockClient` simulating 1-item pages across 2 channels and
  asserts full aggregation + pagination + location enrichment.

## Layering (constitution §1)

`lib/src/{config, data/{models,api,cache,repository}, domain, presentation}`. Domain
(`auth`/`sorting`/`filtering`) is pure Dart, unit-tested. Data never imports presentation. Presentation
depends only on the abstract `VideoRepository`. Errors are typed (`ApiException`) and every edge resolves
to a visible state with retry; offline → stale cache with **no blocking error** (AC-CACHE-01).

## Bring-up note (the one real bug found & fixed)

Initial run: only the **root** screen id surfaced; nested ids were dropped. Cause: a screen-level
`Semantics(identifier:)` without `explicitChildNodes` merged/swallowed descendant semantics, so child
identifiers never became their own nodes. Fix: the `IdNode`/`IdText` helpers above (explicit child
nodes for structure; explicit label + `ExcludeSemantics` for id+text leaves). After the fix: 14/14.

## Deviations / notes

- **Real Google Sign-In** is wired in code (`google_sign_in`, whitelist enforced in the domain layer,
  not the UI). Fully exercising the **interactive** OAuth picker requires a production
  `google-services.json` / OAuth client (SHA-1 + package registered in Google Cloud); only the API key
  was provisioned in this environment. The whitelist logic, the real **data** path, and caching of real
  data are all verified (`REAL-LIST`/`REAL-CACHE` shape; `REAL-LIST` run green). Maestro cannot drive
  the real Google account picker, so auth stays mocked for the real-data smoke (as the flow intends).
- `filter`/`sort` apply **instantly** (no `filter_apply_button`/`sort_apply_button`); the flows tolerate
  this via their `runFlow when visible` guards. The filter/sort panel **replaces** the list while open
  (cross-framework §D.2) so option text can't collide with item titles. Sort labels end with the regex
  keyword (`Date — newest`/`Date — oldest`) per §D.3.

## Artifacts

`plan.md`, `tasks.md`, this report, JUnit results in `results/`, release APK in
`build/app/outputs/flutter-apk/`.
