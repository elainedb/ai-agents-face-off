# Implementation Plan: ytdash (Flutter)

**Date**: 2026-07-01 | **Spec**: `spec/spec.md` + `spec/acceptance-criteria.md` (frozen)
**Constitution**: `spec/constitution.md` (frozen)

> No git repository exists in this workspace, so Spec-Kit's branch-per-feature scripts
> (`create-new-feature.sh` etc.) don't apply. This plan follows `speckit/templates/plan-template.md`
> manually, as the harness prompt permits, applied directly against the frozen spec.

## Summary
A single-Activity Flutter app that signs a user in (Google, whitelist-gated), aggregates videos
from the configured YouTube channels (`config/channels.json`), caches them locally, lets the user
filter/sort, and plots geolocated videos on an OpenStreetMap map. UI-test-mode reads Android intent
extras via a MethodChannel so the same build is driven deterministically by Maestro or points at the
real YouTube Data API v3 with real Google Sign-In.

## Technical Context
- **Language/Version**: Dart 3.10 / Flutter 3.38 (stable), Android minSdk/targetSdk per Flutter
  defaults (already scaffolded, applicationId `com.example.ytdash_flutter`).
- **State management**: `flutter_riverpod` (plain `StateNotifier`/`Notifier`, no code generation).
  Chosen over `provider`/`bloc` for testable, constructor-injected dependencies without a service
  locator, and over `flutter_bloc` to avoid the freezed/build_runner toolchain — Dart 3 sealed
  classes give exhaustive view-state (`Loading`/`Empty`/`Content`/`Error`) with pattern matching and
  no codegen step, which is faster to iterate and equally idiomatic post-Dart-3.
- **DI**: constructor injection wired through Riverpod `Provider`s — no separate DI framework needed.
- **HTTP**: `http` package (simplest idiomatic client; matches `spec/youtube-api.md` shapes directly).
- **JSON**: hand-written `fromJson`/`toJson` (`dart:convert`) — no `json_serializable`/`build_runner`,
  keeping the data layer legible and the build fast/deterministic.
- **Storage**: `shared_preferences` storing the merged video list as a JSON blob + a last-updated
  timestamp. Chosen over `sqflite` for this dataset's scale (a few dozen videos, no relational
  queries) — explicitly sanctioned as the Flutter option in `cross-framework-setup.md` §D.1.
- **Map**: `flutter_map` (+ `latlong2`) over OSM tiles — per constitution §5/cross-framework-setup §C
  this is the one map engine whose markers are real widgets, so `Semantics(identifier:'map_marker')`
  on the marker child makes the rendered pin itself reachable (no fallback overlay strictly
  required); a "Markers" chip row is added anyway for parity/visibility when a pin scrolls off
  viewport.
- **Auth**: `google_sign_in` for real mode; UI-test-mode bypasses it entirely via `mockAuthEmail`.
- **External links**: `url_launcher`, wrapped in try/catch; failures surface `external_open_error`
  rather than crash/no-op.
- **Testing**: `flutter_test` + `package:test` for the domain layer (auth whitelist, sort, filter)
  and one persistence round-trip test for the cache.
- **Target platform**: Android only (per spec "out of scope: any platform other than Android").
- **Project type**: mobile app, single Flutter project, layered (`data`/`domain`/`presentation`).

## Constitution check
- Layered separation / dependency inversion → `lib/data`, `lib/domain`, `lib/presentation`, wired via
  Riverpod providers; presentation only depends on domain interfaces/view-models. PASS.
- Unidirectional observable state → sealed `HomeViewState` (loading/content/empty/error) rendered by
  `HomeScreen`; no business logic in `onPressed` handlers (delegated to notifiers). PASS.
- No blocking UI-thread work → all network/disk calls are `async`/`await` inside notifiers/repos. PASS.
- Single source of truth → `VideoRepository` reads from `VideoCache` (local store); network refresh
  replaces the cache and republishes; UI always renders from the cache stream/state. PASS.
- Explicit error handling → every failure point (auth, network, parse, persistence, map, external
  link) maps to a visible state with retry (`error_view`/`error_retry_button`) or a captured banner
  (`external_open_error`). PASS.
- Selector/UI-test-mode/map contracts → see `spec/constitution.md` §3/§4/§5/§5a, implemented exactly
  (see "Selector inventory" in `tasks.md`).

## Project structure
```
lib/
├── main.dart                     # loads TestConfig, wraps app in ProviderScope
├── core/
│   ├── test_config.dart          # reads MethodChannel ytdash/testconfig at startup
│   └── app_shell.dart            # root widget; hosts the lifted external-link banner
├── domain/
│   ├── models/ (video.dart, source_channel.dart)
│   ├── auth/ (auth_state.dart, auth_service.dart)
│   └── sorting_filtering.dart    # pure functions: sortVideos, filterVideos
├── data/
│   ├── remote/youtube_api_client.dart
│   ├── local/video_cache.dart
│   └── video_repository.dart     # cache-first, stale-fallback
└── presentation/
    ├── auth/ (login_screen.dart, auth_providers.dart)
    ├── home/ (home_screen.dart, home_view_model.dart, filter_screen.dart, sort_screen.dart,
    │          video_list_item.dart)
    ├── map/ (map_screen.dart)
    └── external_link/ (external_link_notifier.dart, external_link_banner.dart)

android/app/src/main/kotlin/.../MainActivity.kt   # MethodChannel reading intent extras
config/channels.json                              # bundled as a Flutter asset (source of truth)
test/
├── domain/ (auth_test.dart, sort_test.dart, filter_test.dart)
└── data/video_cache_test.dart
```

## Data flow (per `spec/youtube-api.md`)
1. Load `config/channels.json` (asset) → list of `{id, label}`.
2. For each channel: `GET /youtube/v3/search?channelId=..&part=snippet&type=video&maxResults=50`,
   following `nextPageToken` until absent. Category = the channel's configured `label` (not
   `categoryId`), applied at merge time — never hardcoded per-video.
3. Dedupe collected video ids (a video could theoretically appear via more than one channel).
4. Batch `GET /youtube/v3/videos?id=<up to 50 ids>&part=snippet,contentDetails,recordingDetails` to
   pull `recordingDetails.location` (present on a subset only) for each video.
5. Merge into the domain `Video` model; write-through to `VideoCache`; UI reads from the cache.
6. No catch-all/"ALL channels" shortcut anywhere — every channel is iterated explicitly and pagination
   is always followed to exhaustion, so the app is correct against the hidden held-out dataset (not
   just the 8-video/2-per-page mock).

## Selector & UI-test-mode contracts
Implemented literally per constitution §3/§4/§5/§5a — see `tasks.md` "Selector inventory" for the
full mapping of logical ID → Flutter widget. `TestConfig` is read once before `runApp()` via the
`ytdash/testconfig` MethodChannel (falls back to a disabled/production default if the channel throws,
e.g. running on a platform without the native handler).

## Risks / deviations anticipated
- No `google-services.json` is present in this workspace (only `config/secrets.env` with the YouTube
  API key). Real Google Sign-In is wired in code but cannot be exercised end-to-end without that
  file; documented as a deviation in `BUILD-REPORT.md`. UI-test-mode (the scored path) does not
  depend on it.
- Reverse geocoding (place names) is out of scope for the 12 ACs (they don't assert on place-name
  text) — `flutter_map`/marker reachability is the graded map behavior; geocoding is not implemented
  unless time remains, to keep the network surface (and its failure points) minimal and testable.
