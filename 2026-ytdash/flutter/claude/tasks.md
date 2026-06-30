# Tasks — YouTube Dashboard ("ytdash"), Flutter

> Spec-Kit `/tasks` artifact derived from `plan.md`. Dependency-ordered; each task
> notes the acceptance criteria it serves. `[x]` = done and validated.

## Phase 0 — Scaffolding & contracts
- [x] T01 Add deps: flutter_riverpod, http, shared_preferences, url_launcher, flutter_map, latlong2, google_sign_in.
- [x] T02 `MainActivity` MethodChannel (`ytdash/testconfig`) exposing intent extras → UI-test-mode (§4).
- [x] T03 Manifest: INTERNET permission, `usesCleartextTraffic`, `<queries>` for http/https VIEW (url_launcher).
- [x] T04 Bundle `config/channels.json` as a Flutter asset.
- [x] T05 `Identified`/`IdentifiedScope` stable-id helpers; `ensureSemantics()` in `main()` (§3).

## Phase 1 — Domain (pure, unit-tested)
- [x] T10 `Video` model + cache (de)serialization.
- [x] T11 `AuthPolicy` whitelist (case-insensitive). → AC-LOGIN-01/02.
- [x] T12 `VideoQuery` filter + sort; null sort preserves API order. → AC-FILTER-01, AC-SORT-01, AC-LIST-03.

## Phase 2 — Data
- [x] T20 `YoutubeApi`: per-channel pagination, cross-channel merge/dedupe, location enrichment. → AC-COUNT-01, AC-MAP-01.
- [x] T21 `VideoCache` (shared_preferences) persistence. → AC-CACHE-01.
- [x] T22 `VideoRepository`: refresh writes store; network failure → stale fallback. → AC-CACHE-01, AC-LIST-02.
- [x] T23 `AuthService` (Mock + Google). → AC-LOGIN-*.

## Phase 3 — State (Riverpod)
- [x] T30 Providers + overrides wiring `TestConfig`/`AppConfig`.
- [x] T31 `AuthController` (signedOut/signingIn/signedIn/error).
- [x] T32 `VideosController` (loading/content/empty/error + query application).
- [x] T33 `ExternalLinkController` (capture vs real launch; error surfacing). → AC-LIST-03, AC-MAP-03, AC-LINK-01.

## Phase 4 — Presentation
- [x] T40 `LoginScreen`: `screen_login`, `login_google_button`, `login_error_message`. → AC-LOGIN-01/02/03.
- [x] T41 `HomeScreen`: `screen_home`, `video_list`/`video_list_item`, `video_count`, refresh/filter/sort/logout, map FAB. → AC-LIST-*, AC-COUNT-01, AC-FILTER-01, AC-SORT-01.
- [x] T42 Filter/sort panels that **replace** the list while open (avoids text collisions). → AC-FILTER-01, AC-SORT-01.
- [x] T43 `MapScreen`: flutter_map + accessible `map_marker` chip strip; `detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`. → AC-MAP-01/02/03.
- [x] T44 App-root `external_open_url` / `external_open_error` banner serving list + map. → AC-LIST-03, AC-MAP-03, AC-LINK-01.

## Phase 5 — Validate
- [x] T50 `flutter analyze` clean; unit tests pass.
- [ ] T51 Build APK, `adb reverse`, run all 14 `flows/AC-*.yaml` on `25251FDF60029V` until green.
- [ ] T52 Real-mode wiring check (base URL + key swap; Google sign-in present).
- [ ] T53 `BUILD-REPORT.md`; create `.build-complete` only after all flows pass.
