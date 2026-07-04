# Tasks

## 1. Project Setup
- [ ] Add dependencies (`http`, `shared_preferences`, `flutter_riverpod`, `flutter_map`, `latlong2`, `url_launcher`, `google_sign_in`).
- [ ] Add `config/channels.json` as an asset in `pubspec.yaml`.
- [ ] Set up the Android MethodChannel in `MainActivity.kt` for test config.
- [ ] Implement `TestConfig` singleton/provider in Flutter.

## 2. Models & Data Layer
- [ ] Create `Video` model.
- [ ] Create `ChannelConfig` model.
- [ ] Implement `YoutubeRepository` with `http`. Fetch all pages per channel.
- [ ] Implement `CacheRepository` with `shared_preferences`.

## 3. Domain & State
- [ ] Implement `AuthRepository` with whitelist checking.
- [ ] Create Riverpod providers for auth state, video list state, map state.
- [ ] Implement sort and filter logic in the video list provider.

## 4. Presentation (UI)
- [ ] Implement Login Screen (`screen_login`, `login_google_button`, `login_error_message`).
- [ ] Implement Home Screen (`screen_home`, `video_list`, `video_list_item`, `video_count`, `logout_button`, `refresh_control`, `filter_button`, `sort_button`).
- [ ] Handle error states and retry buttons.
- [ ] Implement Map Screen (`screen_map`, `map_marker`, `detail_bottom_sheet`, `detail_video_url`, `detail_open_youtube_button`).

## 5. Integration & Polish
- [ ] Implement `url_launcher` handling, respecting `captureExternalLinks`.
- [ ] Apply `Semantics(identifier: ...)` throughout.
- [ ] Verify against Maestro flows (`AC-LOGIN-*`, `AC-LIST-*`, `AC-CACHE-*`, `AC-FILTER-*`, `AC-SORT-*`, `AC-MAP-*`, `AC-LINK-*`).
