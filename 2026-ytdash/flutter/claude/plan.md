# Implementation Plan: ytdash (Flutter)

**Spec**: `spec/spec.md` + `spec/acceptance-criteria.md` (frozen) | **Constitution**: `spec/constitution.md`

> Produced manually per `speckit/templates/plan-template.md` (this workspace is not a git repo, so
> the branch-based `/speckit-plan` scaffolding script does not apply; the spec is already frozen so
> no `/speckit-specify` step is needed). Iterations 1-4 map directly to the spec's iterations, not to
> independent user stories, since the AC suite requires the whole app.

## Summary
A single-screen-flow Android app (built with Flutter) that: signs a user in against a whitelist,
aggregates videos from 4 configured YouTube channels (paginated, deduped), shows them in a
cached/filterable/sortable list, and plots geolocated videos on an OpenStreetMap-based map with
accessible markers. Everything is driven by Android intent-extra launch args in UI test mode so the
same build is Maestro-testable and swappable to the real YouTube Data API v3 at runtime.

## Technical Context
- **Language/Version**: Dart 3.10 / Flutter 3.38 (stable channel, already installed).
- **Primary dependencies**:
  - `flutter_riverpod` — state management + DI (idiomatic Flutter answer to constitution §1.2/1.3:
    presentation depends on provider abstractions, not concrete data sources; screens rebuild from
    explicit `AsyncValue`/sealed UI-state).
  - `http` — network client (simple, matches the 3 plain REST endpoints in `youtube-api.md`; no need
    for Retrofit-style codegen for 3 endpoints).
  - `shared_preferences` — local cache (single JSON blob keyed by cache version; satisfies
    constitution §1.5 "local store is the source of truth" + AC-CACHE-01's persistence-across-relaunch
    requirement without adding a full SQL dependency for 8-ish rows of data).
  - `flutter_map` + `latlong2` — OSM map. Per constitution §5/cross-framework-setup §C, this is the
    *one* of the three reference map engines whose markers are real widgets, so
    `Semantics(identifier: 'map_marker')` on the marker child makes the **rendered pin itself**
    reachable — no separate native-only overlay is structurally required (we still add a fallback
    "Markers" chip row for parity/robustness, see Home/Map section below).
  - `google_sign_in` — real Google auth for production mode (gated behind UI-test-mode; the mock path
    never touches it).
  - `url_launcher` — external "open in YouTube" launch (real mode); UI-test-mode intercepts this at
    the app layer per constitution §4 (`captureExternalLinks`).
  - `flutter_lints` (already present) — static cleanliness gate (constitution §2).
- **Storage**: `shared_preferences` (JSON), see above.
- **Testing**: `flutter_test` for domain unit tests (whitelist, sort, filter) + a persistence
  (cache read/write) test, per constitution §2. Maestro (external, in `flows/`) for E2E/AC validation.
- **Target platform**: Android (minSdk/compileSdk = Flutter defaults), applicationId
  `com.example.ytdash_flutter` (already scaffolded).
- **Project type**: Single mobile app.
- **Performance/Constraints**: No blocking work on the UI thread (constitution §1.4) — network/cache
  I/O is all `async`/`await` off the render frame by construction (Dart's single-isolate event loop +
  `http`/`shared_preferences` being non-blocking I/O calls). Must run against a mock and the real API
  by swapping only `apiBaseUrl`/`apiKey` runtime extras.
- **Scale/Scope**: ~8-video fixture (hidden held-out set may differ in size) across 4 channels; small
  single-user app, no backend of our own.

## Constitution Check
- **Layered separation (§1.1)** → `lib/domain` (entities + pure logic: whitelist, sort, filter — zero
  Flutter imports), `lib/data` (remote API client + local cache, implements repository interfaces
  domain/presentation depend on), `lib/presentation` (screens/widgets + Riverpod notifiers holding
  UI state only). PASS.
- **Dependency inversion (§1.2)** → `VideoRepository` abstract interface in `domain/repositories`;
  concrete `VideoRepositoryImpl` in `data/`, injected via Riverpod `Provider` override (real vs. a
  future test double). Presentation only sees the interface via providers. PASS.
- **Unidirectional, observable state (§1.3)** → sealed `UiState<T>` (`Loading` / `Content` / `Empty`
  / `Error`) exposed by `AsyncNotifier`s; screens are pure functions of that state. PASS.
- **No blocking UI-thread work (§1.4)** → all I/O is `async`; no `dart:io` sync calls. PASS.
- **Single source of truth (§1.5)** → the cache (`shared_preferences`) is what the list provider
  reads/emits; a network fetch success replaces the cache and re-emits, a network failure falls back
  to whatever is cached without a blocking error. PASS.
- **Explicit error handling (§1.6)** → `Result<T, AppFailure>`-shaped repository returns; every
  screen has `error_view` + `error_retry_button`; external-link failures surface
  `external_open_error` instead of throwing. PASS.
- **Selector contract (§3)** → every listed ID is applied via `Semantics(identifier: '...')` (Flutter
  3.19+ stable field), never `label`. `SemanticsBinding.instance.ensureSemantics()` called at the top
  of `main()`. PASS (see Project Structure below for where each ID lives).
- **UI-test-mode contract (§4)** → `lib/core/test_config.dart` reads a `MethodChannel
  ('ytdash/testconfig')` once at startup; `MainActivity.kt` answers it from `intent.extras`. `apiKey`
  is read from that same channel at runtime (never compiled in), so one build serves mock and real.
  PASS.
- **Popup reachability (§5a)** → Flutter routes (dialogs/bottom sheets) share the same semantics tree
  (unlike Compose's separate-window popups), so no extra work is needed beyond tagging the sheet and
  its button — verified against the cross-framework doc's explicit note that Flutter dialogs are
  reachable by default. PASS.
- **Map markers (§5)** → `flutter_map` marker widgets wrapped in `Semantics(identifier: 'map_marker')`
  are reachable directly (the documented exception). A "Markers" horizontal chip list (also tagged
  `map_marker`) is rendered as a robustness fallback in case a pin is scrolled off-viewport by the
  map's initial camera fit. `map_marker_fallback_used=false` expected; recorded in BUILD-REPORT.md
  either way after real validation.
- **No secrets in source (§2)** → `config/secrets.env` and `config/channels.json`'s real values are
  read at runtime/build-time only; `config/secrets.env` is already gitignored. `channels.json` is
  bundled as a Flutter asset (it is not a secret — it is a public channel list) and read at startup.

No constitution violations requiring the Complexity Tracking table.

## Project Structure

### Documentation (this feature)
```text
plan.md              # this file
tasks.md             # /speckit-tasks output (task breakdown by iteration)
BUILD-REPORT.md       # written last: stack summary + 12-AC results + deviations
```

### Source Code (repository root)
```text
lib/
├── main.dart                         # ensureSemantics(), reads TestConfig, ProviderScope, MaterialApp
├── core/
│   ├── test_config.dart              # UI-test-mode extras via MethodChannel('ytdash/testconfig')
│   ├── app_config.dart               # merges TestConfig + compiled defaults -> baseUrl/apiKey/whitelist
│   └── external_launch.dart          # url_launcher wrapper + captureExternalLinks intercept + app-root banner state
├── domain/
│   ├── entities/
│   │   └── video.dart                # Video entity (id,title,description,publishedAt,category,thumbnailUrl,lat,lng,youtubeUrl)
│   ├── auth/
│   │   └── whitelist.dart            # pure isAuthorized(email, whitelist) - unit tested
│   ├── sorting/
│   │   └── video_sort.dart           # pure comparators - unit tested
│   ├── filtering/
│   │   └── video_filter.dart         # pure filter-by-category - unit tested
│   └── repositories/
│       └── video_repository.dart     # abstract interface (fetchAll(), cached getters)
├── data/
│   ├── remote/
│   │   ├── youtube_api_client.dart   # search.list (paginated) + videos.list per channels.json
│   │   └── youtube_dtos.dart         # response parsing (raw JSON -> domain Video)
│   ├── local/
│   │   └── video_cache.dart          # shared_preferences JSON cache (read/write/clear)
│   └── video_repository_impl.dart    # network-first, stale-cache-fallback, single source of truth
├── presentation/
│   ├── app_root.dart                 # hosts the global external_open_url/error banner (constitution note: lift to app root)
│   ├── auth/
│   │   ├── auth_controller.dart      # Riverpod notifier: signIn(mock|real), signOut, whitelist check
│   │   ├── login_screen.dart         # screen_login, login_google_button, login_error_message
│   ├── home/
│   │   ├── home_controller.dart      # Riverpod AsyncNotifier<UiState<List<Video>>>, filter/sort state
│   │   ├── home_screen.dart          # screen_home, video_list, video_count, refresh_control, logout_button/overflow_menu_button, filter_button, sort_button, map_nav_button, loading/error views
│   │   ├── filter_sheet.dart         # filter_apply_button, replaces list while open
│   │   └── sort_sheet.dart           # sort_apply_button, replaces list while open
│   └── map/
│       ├── map_screen.dart           # screen_map, flutter_map + map_marker widgets + chip fallback row
│       └── marker_detail_sheet.dart  # detail_bottom_sheet, detail_video_url, detail_open_youtube_button
└── assets/ (pubspec) -> config/channels.json bundled read-only

test/
├── domain/
│   ├── whitelist_test.dart
│   ├── video_sort_test.dart
│   └── video_filter_test.dart
└── data/
    └── video_cache_test.dart          # persistence read/write test

android/app/src/main/kotlin/.../MainActivity.kt   # MethodChannel handler reading intent.extras
```

**Structure Decision**: Single Flutter mobile project (no separate backend); the "layers" from the
constitution are Dart package-private folders (`domain`/`data`/`presentation`) inside the one
`lib/`, not separate packages — appropriate for this scope (~15-20 source files), while still
enforcing the dependency direction (domain has zero imports from data/presentation; presentation
imports domain interfaces + Riverpod providers that data implements).

## Complexity Tracking
Not applicable — no constitution violations.
