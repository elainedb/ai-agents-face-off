# Tasks: YouTube Dashboard ("ytdash")

**Date**: 2026-07-02 | **Prerequisites**: `plan.md`, `spec/spec.md`, `spec/constitution.md`

---

## Phase 1: Setup (Shared Infrastructure)
- [ ] T001 Initialize the empty activity project structure using the CLI: `android create empty-activity --name="ytdash" -o=.`
- [ ] T002 Configure `app/build.gradle` and root `build.gradle` with dependencies (`OkHttp`, `Gson`, `Coil`, `osmdroid`) and ensure minSdk=29, compileSdk=35/36, Kotlin 2.x
- [ ] T003 Setup AndroidManifest.xml permissions (Internet, Network State, Location) and configuration parameters

---

## Phase 2: Foundational (Models & UI Test Mode Config)
- [ ] T004 Create `Video.kt` domain data class with properties: id, title, description, publishedAt, category, thumbnailUrl, lat, lng, and youtubeWatchUrl
- [ ] T005 Create `TestConfig.kt` to parse Android launch intent extras (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`, `captureExternalLinks`)
- [ ] T006 Implement manual Dependency Container / Service Locator in `MainApplication.kt` and parse `TestConfig` on startup in `MainActivity`

---

## Phase 3: User Story 1 - Authentication & Access Control (AC-LOGIN-01, AC-LOGIN-02, AC-LOGIN-03)
- [ ] T007 Implement whitelisting/authorization checker in `AuthRepository.kt`
- [ ] T008 Implement `LoginScreen.kt` featuring Google Sign-In button (`login_google_button`) and login error message (`login_error_message`) with proper test tags
- [ ] T009 Implement logout trigger (`logout_button`) returning user to login screen

---

## Phase 4: User Story 2 - Video List Aggregation (AC-LIST-01, AC-LIST-02, AC-LIST-03, AC-COUNT-01, AC-LINK-01)
- [ ] T010 Implement YouTube Data API paging and aggregation across all channels in `YouTubeApiService.kt`
- [ ] T011 Create `VideoRepository.kt` combining API fetching and SharedPreferences cache
- [ ] T012 Implement `VideoListTab.kt` with scrollable list (`video_list`), list items (`video_list_item` with test ID on the title Text), total loaded count display (`video_count`), pull-to-refresh (`refresh_control`), and loading/empty/error views
- [ ] T013 Implement external link launching with optional mock capture mechanism (`external_open_url`, `external_open_error`) in `TestUtils.kt`

---

## Phase 5: User Story 3 - Caching, Filtering, and Sorting (AC-CACHE-01, AC-FILTER-01, AC-SORT-01)
- [ ] T014 Implement disk-based cache saving/loading in `VideoRepository` (using JSON/SharedPreferences fallback)
- [ ] T015 Implement filtering UI with filter options panel that replaces the list while open to avoid text collisions
- [ ] T016 Implement sorting UI with sort options panel (sort labels ending with regex keywords like "Date — newest" or "Date — oldest")

---

## Phase 6: User Story 4 - OpenStreetMap Map & Bottom Sheet Details (AC-MAP-01, AC-MAP-02, AC-MAP-03)
- [ ] T017 Integrate `osmdroid` in `MapTab.kt` within a Compose `AndroidView`, handling tile-caching and marker drawing
- [ ] T018 Expose native accessible `map_marker` selection chips (AssistChip row) in the Map screen to ensure E2E testability
- [ ] T019 Implement custom inline absolute-positioned bottom sheet (`detail_bottom_sheet`) with text URL (`detail_video_url`) and YouTube launcher button (`detail_open_youtube_button`)

---

## Phase 7: Polish & Self-Validation (Complete all Maestro flows)
- [ ] T020 Complete local build, deploy to target device, and run Maestro flows
- [ ] T021 Resolve any timing/interaction issues and ensure cleartext is permitted for local server connections
- [ ] T022 Generate `BUILD-REPORT.md` and touch `.build-complete` file once all flows pass
