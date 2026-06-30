# BUILD-REPORT — YouTube Dashboard ("ytdash"), Flutter

## Summary
A production-quality Flutter Android app implementing all 4 iterations (auth, video
list, cache/filter/sort, map) of the frozen spec. Built against the running mock at
`http://127.0.0.1:8093` and validated with the Maestro acceptance flows on the target
physical device `25251FDF60029V`.

**Acceptance result: 14 / 14 ACs PASS** (verified across 2 full runs; see Flakiness).

## Stack chosen (the engineering decision being measured)
| Concern | Choice |
|---|---|
| State / DI | **flutter_riverpod 3.x** — `Notifier` + `Provider`, no codegen |
| Networking | **http** + hand-written JSON parsing |
| Persistence | **shared_preferences** (JSON list; replace-on-refresh + stale fallback) |
| Map | **flutter_map 8.x** + **latlong2** (OpenStreetMap tiles) |
| External launch | **url_launcher** |
| Auth | **google_sign_in 7.x** (real) / injected mock service (UI-test-mode) |
| Errors / UI-state | `enum` status (loading/content/empty/error) + typed `ApiException`/`AuthException` |

Rationale is in `plan.md §1`. Layered architecture (data → domain → presentation),
dependency inversion via providers, unidirectional observable state, single source of
truth (cache), explicit error+retry everywhere — per `constitution.md §1`.

## How the three contracts are honored
- **Selector contract (§3):** `Semantics(identifier: '<id>')` via the `Identified` helper
  (stable `identifier`, not localized `label`); `ensureSemantics()` in `main()`. Leaf
  elements use `excludeSemantics: true` so an id and its text resolve to one node (needed
  for `id + text` assertions like AC-SORT-01 / AC-MAP-03). All 24 contract IDs exposed.
- **UI-test-mode (§4):** `MainActivity` exposes launch-intent extras over the
  `ytdash/testconfig` MethodChannel; `TestConfig.fromHost()` reads them once and they are
  injected via Riverpod provider overrides. `apiBaseUrl` + `apiKey` are read at **runtime**
  (never compile-time-only), so the same build serves mock and real. `captureExternalLinks`
  switches between surfacing `external_open_url` and a real `url_launcher` launch (which
  surfaces `external_open_error` on failure).
- **Map markers (§5):** harness-reachable `map_marker` lives on an always-visible,
  accessible **chip strip** (one per located video); flutter_map pins are tagged too but
  the chips are the guaranteed harness path. **`map_marker_fallback_used = false`** (taps
  resolve to real accessible widgets, not screen coordinates).

## Anti-overfit / data flow
- Aggregates **all** channels in `config/channels.json`; for each, follows `nextPageToken`
  to fetch **all pages** (mock page size = 2 → a single-page build would fail AC-COUNT-01).
- Merges across channels, **dedupes by videoId**, preserves API/insertion order so the
  "first video" is deterministic (AC-LIST-03 taps index 0 → `VIDEO_ID_1`).
- `category` = the **source-channel label** from config (AC-FILTER-01), not YouTube's
  numeric `categoryId`.
- Locations enriched via `videos.list?part=...,recordingDetails` (batched ≤50).
- No fixture ids/titles/counts are hardcoded anywhere — all values come from API responses.

## Real-API mode
The same build runs against real YouTube by swapping only `apiBaseUrl` →
`https://www.googleapis.com` and `apiKey` → the real key. Verified the real endpoint
returns the same response shape and real data for the configured channels (e.g. channel
`UCynoa1DjwnvHAowA_jiMEAQ` → "Cherbourg 2025 – 7º dia", …). Production auth uses
`google_sign_in` + the email whitelist (`user1@example.com`, `user2@example.com`).
The scored flows always run in UI-test-mode (mock auth), so real Google Sign-In is exercised
only in production.

## Tests & static analysis
- `flutter analyze`: **clean** (0 issues).
- Unit tests (`flutter test`): **13 pass** — `AuthPolicy` (whitelist), `VideoQuery`
  (sort/filter/order), `VideoCache` (persistence round-trip + replace), `Video`
  (serialization).

## Per-AC result (mock build)
| AC | Result |
|---|---|
| AC-LOGIN-01/02/03 | PASS |
| AC-LIST-01/02/03 | PASS |
| AC-COUNT-01 | PASS (count = 8, all pages of all channels) |
| AC-CACHE-01 | PASS (offline relaunch shows cached items, no error_view) |
| AC-FILTER-01 | PASS |
| AC-SORT-01 | PASS |
| AC-MAP-01/02/03 | PASS |
| AC-LINK-01 | PASS (real launch from list + map, no external_open_error) |

## Flakiness
2 consecutive full-suite runs on `25251FDF60029V`: **14/14 both runs** (min = median =
max = 14/14). No flaky criteria observed.

## Deviations
- **Logout is a direct AppBar action**, not behind an overflow menu. The selector contract
  permits this (`overflow_menu_button` is "if any"); the AC-LOGIN-03 flow's overflow tap is
  guarded by `when: visible`, so it is simply skipped. Keeping `logout_button` in the main
  view tree avoids the popup-window id-exposure trap (constitution §5a).
- **Filter/sort apply instantly** (no `*_apply_button`), which the contract explicitly
  allows. The filter/sort panels **replace** the list while open to avoid text-collision
  with row titles (cross-framework-setup §D.2). Sort labels end with the regex keyword
  ("Date — newest") per §D.3.
- No `google-services.json` was provided in `config/`, so real Google Sign-In uses
  `google_sign_in`'s default initialization (sufficient to obtain the account email for the
  whitelist check); this path is not exercised by the scored flows.
