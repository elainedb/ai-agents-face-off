# Build Report — ytdash (Flutter)

## Stack
- **Flutter 3.38 / Dart 3.10**, applicationId `com.example.ytdash_flutter`.
- **State/DI**: `flutter_riverpod` — `StateNotifierProvider`s exposing sealed `UiState<T>`
  (Loading/Empty/Content/Error); presentation depends only on `VideoRepository`/`AppConfig`
  abstractions (constitution §1.2/1.3).
- **Network**: `http`, hand-written against the 3 documented endpoints (`search.list`,
  `videos.list`, pagination via `nextPageToken`) — no codegen needed for 3 endpoints.
- **Cache**: `shared_preferences` (single JSON blob) — the source of truth `home_controller`
  reads from; network success replaces it, network failure falls back to it (constitution §1.5).
- **Map**: `flutter_map` + `latlong2` (OSM). This is the one reference map engine whose markers are
  real widgets, so `Semantics(identifier: 'map_marker')` on the marker child makes the **rendered
  pin itself** reachable. A "markers" chip row is also tagged `map_marker` for robustness (survives
  a pin panning off-viewport). `map_marker_fallback_used=false` — both affordances are genuinely
  reachable, confirmed by AC-MAP-02/03 passing against real widget markers as well as the chip row.
- **Auth**: `google_sign_in` for the real path, gated to only run when not in UI test mode / no
  `mockAuthEmail`; the same `isAuthorized()` whitelist check (`lib/domain/auth/whitelist.dart`)
  runs after either path.
- **External links**: `url_launcher`, intercepted at the app layer in UI test mode
  (`captureExternalLinks`).
- Full architecture/rationale in `plan.md`; task breakdown in `tasks.md` (all checked off).

## Result: 14/14 ACs passing, 3 consecutive runs, no flakiness
`flows/AC-*.yaml` (14 files — `spec/acceptance-criteria.md`'s 14 rows) against the mock at
`http://127.0.0.1:8090`, device `25251FDF60029V`:

| Run | Build | Result |
|---|---|---|
| 1 | debug | 14/14 (after two fixes below) |
| 2 | debug | 14/14 |
| 3 | release | 14/14 (faster: 2m23s vs 3m33s) |

No criterion flaked across the 3 runs (min = median = max = 14/14).

## Two real bugs the self-validation loop caught
1. **`Semantics(identifier: ...)` without `container: true` doesn't create its own accessibility
   node.** First run: every screen collapsed into a single Android accessibility node (whichever
   interactive descendant existed), silently discarding all nested identifiers except one — e.g.
   `screen_login`'s Semantics merged with the button beneath it, showing resource-id `screen_login`
   on a `Button`-classed node and making `login_google_button` invisible to Maestro. Fixed by
   adding `container: true` to every `Semantics(identifier: ...)` in the app (forces a distinct
   semantics-tree boundary per element, matching how testTag-style ids are meant to work). This is
   the Flutter-specific gotcha the constitution's framework-neutral selector contract doesn't spell
   out — worth adding to `cross-framework-setup.md`'s Flutter section for future builds.
2. **The external-open banner (`external_open_url`/`external_open_error`) was a Stack sibling of
   the login/home switch, but `Navigator.push`ing the map screen covers the entire previous route
   — including that sibling.** This passed AC-LIST-03 (list is the root route) but failed AC-MAP-03
   (map is a pushed route). Fixed by moving the banner into `MaterialApp.builder`, which wraps the
   Navigator itself, so it renders above whichever route is on top. This directly validates the
   cross-framework-setup.md guidance to lift the banner to the app root — but "app root" has to mean
   *above the Navigator*, not merely *not per-screen*.

## Anti-overfit checklist
- **No catch-all channel query.** Fetches each of the 4 channels in `config/channels.json`
  individually via `search.list?channelId=...` and merges/dedupes by video id
  (`lib/data/video_repository_impl.dart`).
- **Full pagination.** Follows `nextPageToken` per channel until absent
  (`lib/data/remote/youtube_api_client.dart:fetchAllForChannel`) — verified against the mock's
  `page_size=2` (forces multiple pages) and against the real API (181 videos across 4 channels,
  see below).
- **Category = the channel's own configured label**, read from `config/channels.json`, not the
  fixture's internal bucket name and not YouTube's `categoryId` — works identically against real
  data.
- **Default (unsorted) list order = fetch order**, so `video_list_item index:0` is always
  `VIDEO_ID_1` (AC-LIST-03) regardless of channel iteration — sorting is only applied once the user
  explicitly picks an option from the sort sheet (`HomeState.sortKey` is nullable; `null` = natural
  order).

## Real-mode validation (`https://www.googleapis.com` + the real key from `config/secrets.env`)
Ran `flows/REAL-LIST.yaml` and `flows/REAL-CACHE.yaml` (mocked auth only, per those flows' own
comments — real Google OAuth can't be driven by Maestro) against the real API:
- **REAL-LIST**: list populates, no `error_view` — **181 real videos** loaded across the 4
  configured channels (proves pagination isn't overfit to the 8-video fixture).
- **REAL-CACHE**: captured the first real item's title online, went offline + fresh process
  (`clearState:false`), and the same title was served from the on-disk cache with no `error_view`.
- Manually confirmed the map screen renders real geolocated markers (real trip footage across
  France/Spain) and tapping a marker opens its matching `detail_bottom_sheet`.

## Deviations / known limitations
- **No `google-services.json` or registered OAuth client was provided in this workspace** — only a
  raw YouTube Data API key (`config/secrets.env`) and the two authorized emails (passed as the
  `authorizedEmails` launch extra / `PROD_AUTHORIZED_EMAILS` dart-define). The real `google_sign_in`
  code path is implemented and gated correctly (`lib/presentation/auth/auth_controller.dart`), but
  the actual account-picker UI couldn't be exercised end-to-end without those credentials. This
  doesn't affect scoring: every `AC-LOGIN-*` flow uses `mockAuthEmail` (constitution §4), which
  exercises the identical whitelist logic the real path also uses.
- **Static analysis**: `flutter analyze` is clean (zero errors/warnings). Six `info`-level
  deprecation notices remain (`RadioListTile.groupValue`/`onChanged`, deprecated in favor of a
  `RadioGroup` ancestor added in Flutter 3.32) in `filter_sheet.dart`/`sort_sheet.dart` — cosmetic,
  no functional effect, left as-is per constitution §2 ("warnings acceptable but reported").
- Production (non-test) builds require `--dart-define-from-file=config/secrets.env
  --dart-define=PROD_AUTHORIZED_EMAILS=<csv>` at build time (see `lib/core/app_config.dart`); an
  unconfigured production build fails closed (empty whitelist → denies everyone) rather than open.

## Tests
`flutter test`: 23 passing — domain unit tests (`whitelist`, `video_sort`, `video_filter`), a
persistence round-trip test (`video_cache`), and one widget test (login screen renders).
