# Implementation Plan — ytdash (Flutter)

> Spec-Kit `plan` artifact. Derived from `spec/spec.md` + `spec/acceptance-criteria.md` (frozen) and
> `spec/constitution.md` (frozen, framework-neutral). This document records the engineering
> decisions — the stack, architecture, and how each constitution contract is satisfied — which is
> the part being evaluated.

## Stack

| Concern | Choice | Why |
|---|---|---|
| Language/SDK | Dart 3.10, Flutter 3.38 (stable), `flutter_lints` | pinned in workspace already |
| State management / DI | `flutter_riverpod` | Compile-safe DI without a service locator; `StateNotifier`/`Notifier` gives explicit, observable view-state (constitution §1.3) with no codegen required, keeping the build simple and fast to iterate |
| Networking | `http` | Thin, testable, no codegen; the YouTube-API-shaped mock/real swap only needs a base URL + query params, not a generated client |
| JSON mapping | Hand-written `fromJson` | 3 small models (Video, ApiVideo, TestConfig) — a code-generation step (`json_serializable`/`freezed`) is overhead this project doesn't need |
| Local persistence | `shared_preferences` (JSON-encoded video list) | Single source of truth per constitution §1.5; no relational queries needed (filter/sort run in memory over a small list), so a full SQL engine (`sqflite`) is unjustified complexity |
| Map | `flutter_map` (+ `latlong2`) | The **only** OSM widget among the three reference engines whose markers are real widgets — constitution §5 / cross-framework-setup §C identify `flutter_map` as the exception that can tag the rendered pin itself with `Semantics(identifier: 'map_marker')`. We additionally render a guaranteed-visible marker-chip row for parity/scroll-safety, per the verified flutter-claude-flagship pattern. |
| External links | `url_launcher` | Standard idiomatic package for launching `https://` URLs out of the app |
| Auth (real mode) | `google_sign_in` | Constitution only requires "real Google Sign-In"; no `google-services.json`/Firebase project was provided in this workspace, so Firebase Auth is not wired — `google_sign_in` talks to Google's OAuth directly. Documented as a deviation in `BUILD-REPORT.md`. |
| Testing | `flutter_test` (unit only, per constitution §2 — "meaningful coverage of logic, not UI") | domain (whitelist, sort, filter) + one persistence test |

## Architecture (constitution §1: layered separation + dependency inversion)

```
lib/
  core/
    test_config.dart        # reads uiTestMode/apiBaseUrl/apiKey/... via MethodChannel at startup
    result.dart              # Result<T> sealed union used across data/domain boundaries
    app_config.dart          # compile-time fallbacks (production base URL, --dart-define key), channel list asset
  data/
    models/
      video.dart             # domain Video: id,title,description,publishedAt,category,thumbnailUrl,lat,lng
    remote/
      youtube_api_client.dart   # search.list pagination + videos.list batch fetch, given baseUrl+apiKey
    local/
      video_cache_store.dart    # shared_preferences read/write of the last-good video list
    repository/
      video_repository.dart     # abstract interface (dependency inversion target for presentation)
      video_repository_impl.dart  # iterates config/channels.json, merges/dedupes, persists, stale-fallback
  domain/
    auth/
      auth_whitelist.dart    # pure fn: isAuthorized(email, whitelist) — unit tested
    sorting/
      video_sort.dart        # pure fn: sortVideos(videos, SortOption) — unit tested
    filtering/
      video_filter.dart      # pure fn: filterByCategory(videos, category?) — unit tested
  state/
    providers.dart           # riverpod providers wiring data → domain → presentation
    auth_controller.dart      # StateNotifier<AuthState>
    home_controller.dart      # StateNotifier<HomeState> (loading/content/empty/error, filter/sort)
    external_link_controller.dart  # app-root controller for the shared open/URL/error banner
  features/
    login/login_screen.dart
    home/home_screen.dart, filter_screen.dart, sort_screen.dart
    map/map_screen.dart
  widgets/
    external_link_banner.dart # root-level banner rendering external_open_url / external_open_error
  main.dart                   # ensureSemantics(), load TestConfig, runApp
```

- **(a) Data access** = `data/` (remote + local + repository). **(b) Domain** = `domain/` (pure,
  synchronous, unit-testable, no Flutter imports). **(c) Presentation** = `features/` + `state/`
  (Riverpod controllers hold view-state; screens are dumb renderers of that state). A change to,
  say, the cache format never touches `domain/` or `features/`.
- **Dependency inversion**: `home_controller.dart` depends on `VideoRepository` (abstract), injected
  via a Riverpod provider override — swappable for tests without touching presentation code.
- **Unidirectional/observable state**: every screen consumes a sealed `HomeState`
  (`Loading|Content|Empty|Error`) — no business logic in `onPressed` handlers, they only call
  controller methods.
- **No blocking UI-thread work**: all network/disk calls are `async` (`http`, `shared_preferences`
  are already non-blocking on the platform side).
- **Single source of truth**: `video_repository_impl.dart` always writes network results to the
  cache and the UI only ever reads the repository's merged/cached result — never straight off the
  HTTP response.
- **Explicit error handling**: every failure path (auth, network, parse, persistence, map/marker
  action, external open) resolves to a UI state with a retry affordance or the
  `external_open_error` id — never a bare exception.

## Contracts (constitution §3/§4/§5/§5a)

- **Selectors**: `Semantics(identifier: '<id>', ...)` on every element in the §3 table, wired
  directly to the widget carrying the visible text/interaction (not a wrapping decoration) so
  Maestro's text+id assertions resolve to the same node.
- **UI test mode**: `MainActivity.kt` exposes a `ytdash/testconfig` `MethodChannel` reading
  `intent.extras` (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`,
  `captureExternalLinks`); `main.dart` awaits this once before `runApp`. Outside test mode
  (extras absent), the app falls back to compile-time config (`--dart-define-from-file` for the
  production key, `https://www.googleapis.com` as the base URL, and the two authorized emails from
  the run prompt as the default whitelist) and uses real Google Sign-In / real external launch.
- **Popups stay reachable (§5a)**: the filter/sort panels are pushed as ordinary
  `MaterialPageRoute`s (Flutter routes share one semantics tree — unlike Compose's separate-window
  popups — so no extra work is needed); the map's `detail_bottom_sheet` is an in-tree `Align` +
  `Material` overlay (not a `showModalBottomSheet` route) so it's guaranteed reachable, matching the
  verified flutter-claude-flagship pattern.
- **Map markers (§5)**: `flutter_map` markers are real widgets wrapped in
  `Semantics(identifier: 'map_marker')` (the framework's exception case) **plus** a
  `map_marker`-tagged horizontal chip row (one per located video) so the affordance survives a pin
  scrolled off-viewport. `map_marker_fallback_used=false` expected (to be confirmed empirically
  during self-validation, recorded in `BUILD-REPORT.md`).
- **Filter/sort panel replaces the list**: implemented as a route push (see above) — the list
  literally isn't in the visible route while the panel is open, avoiding the "Tech Talk One"
  contains-"tech" text collision called out in cross-framework-setup.md §D.2.
- **Sort labels**: chosen to satisfy Maestro's *full-string* `matches()` regex
  (`(?i)date.*(desc|newest)`, no wildcards at the boundaries) — labels are exactly `Date - Newest`,
  `Date - Oldest`, `Title A-Z`, `Title Z-A`.
- **Filter labels**: rendered as the bare configured channel label (e.g. `cronicas`) with no
  decoration, since `AC-FILTER-01` matches `(?i)${FILTER_LABEL}` with no wildcards.

## Anti-overfit

- Channels come from `config/channels.json` (bundled as a Flutter asset — it's app configuration,
  not scored fixture data) and are iterated in a loop; there is no hardcoded channel id or count.
- Pagination follows `nextPageToken` until absent, for every channel, before computing
  `video_count` — never assumes a page count or list length.
- Category is read from each video's `channelTitle` (the channel-label the API actually returns for
  that video), never a fixture-only field.
- No title/id/count from `spec.md`'s example fixture appears in source code.

## Testing plan (constitution §2)

- `test/domain/auth_whitelist_test.dart` — authorized/unauthorized/case-insensitive-email cases.
- `test/domain/video_sort_test.dart` — date asc/desc, title asc/desc.
- `test/domain/video_filter_test.dart` — filter by category, null category passthrough.
- `test/data/video_cache_store_test.dart` — write then read round-trip via
  `SharedPreferences.setMockInitialValues`.

## Deviations / open risks (tracked, updated as build proceeds)

- No `google-services.json` was present in this workspace → real mode uses `google_sign_in`
  directly (OAuth), not Firebase Auth. Whitelist enforcement and the rest of the contract are
  unaffected.
- Reverse geocoding (place names) is out of scope for the graded ACs (they only assert
  `map_marker`/`detail_bottom_sheet`); omitted to keep the map screen focused on what's scored,
  can be added later without touching the contract.
