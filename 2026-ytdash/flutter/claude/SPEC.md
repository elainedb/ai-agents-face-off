# SPEC.md

This specification describes the Flutter YouTube Videos app. It is intended to be used by an AI Agent to build this project from scratch.

---

## 1. Project Overview

A Flutter application that authenticates users via Google Sign-In (with an email whitelist), displays YouTube videos from four specific channels, supports local caching, filtering, sorting, and a map view showing video recording locations.

**Target platforms:** Android and iOS (Firebase configured for both).

**Dart SDK:** ^3.9.2

---

## 2. Architecture

The project follows **Clean Architecture** organized by feature under `lib/features/`. Each feature has three layers:

- **Domain:** Entities (freezed immutable classes), abstract repository interfaces, and use cases. Use cases implement a common `UseCase<Type, Params>` base class. All repository methods return `Either<Failure, T>` (from the `dartz` package) for error handling.
- **Data:** Repository implementations, remote data sources (API calls), local data sources (SQLite caching), and freezed models with JSON serialization. Models have a `toEntity()` method to convert to domain entities.
- **Presentation:** BLoC classes for state management with freezed event/state unions, and Flutter widget pages.

### Dependency Injection

Use `get_it` with `injectable` for DI. A `RegisterModule` in `lib/di.dart` provides singleton instances of `FirebaseAuth`, `GoogleSignIn`, and `http.Client`. All data sources are `@LazySingleton`, repositories are `@LazySingleton`, and BLoCs/use cases are `@injectable` (factory). Run `dart run build_runner build` to regenerate `di.config.dart`.

### Error Handling

- **Exceptions** (`lib/core/error/exceptions.dart`): A base `AppException` class with subclasses `ServerException`, `CacheException`, `NetworkException`, and `AuthException`. Each carries a `String message`.
- **Failures** (`lib/core/error/failures.dart`): A freezed union `Failure` with variants: `server`, `cache`, `network`, `auth`, `validation`, `unexpected`. Each carries a `String message`. An extension `FailureX` provides a `message` getter.
- Data layer catches exceptions and returns `Left(Failure)`. Presentation layer maps failures to UI error messages.

### Use Case Base Class

`lib/core/usecases/usecase.dart` defines:
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
```
Use cases that take no parameters use a `NoParams` class.

---

## 3. Configuration & Security

Sensitive configuration files are **gitignored** and must be created from templates before running.

### Required Config Files

1. **`lib/config/auth_config.dart`** (from `auth_config.template.dart`):
   ```dart
   class AuthConfig {
     static const List<String> authorizedEmails = [
       'your-email@example.com',
     ];
   }
   ```

2. **`lib/config/config.dart`** (from `config.template.dart`):
   ```dart
   class Config {
     static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY_HERE';
   }
   ```

3. **Firebase config files:**
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### CI Setup

A script `scripts/ensure_config.dart` generates safe placeholder config files (empty email list, placeholder API key) when the real files are missing, allowing `flutter analyze` and `flutter test` to pass in CI.

---

## 4. App Initialization

`lib/main.dart` performs this startup sequence:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
3. `configureDependencies()` — initializes the GetIt service locator
4. `runApp(MyApp())`

`MyApp` is a `MaterialApp` using Material 3 with a deep purple color scheme seed. It wraps the root with a `BlocProvider<AuthBloc>` and dispatches `AuthEvent.checkAuthStatus()` on creation. The home widget is `AuthWrapper`.

---

## 5. Feature: Authentication

**Location:** `lib/features/authentication/`

### 5.1 Domain

**Entity — `User`** (freezed):
- `id` (String)
- `name` (String)
- `email` (String)
- `photoUrl` (String?)
- Getter: `hasPhoto` → `photoUrl != null && photoUrl!.isNotEmpty`

**Repository interface — `AuthRepository`:**
- `signInWithGoogle()` → `Future<Either<Failure, User>>`
- `signOut()` → `Future<Either<Failure, void>>`
- `getCurrentUser()` → `Future<Either<Failure, User?>>`

**Use cases:**
- `SignInWithGoogle` — calls `signInWithGoogle()`, takes `NoParams`
- `SignOut` — calls `signOut()`, takes `NoParams`
- `GetCurrentUser` — calls `getCurrentUser()`, takes `NoParams`

### 5.2 Data

**Model — `UserModel`** (freezed + json_serializable):
- Fields: `id`, `name`, `email`, `photoUrl`
- `toEntity()` → converts to `User`
- Factory `fromFirebaseUser(User firebaseUser)` → creates from Firebase user object

**Remote data source — `AuthRemoteDataSource`:**
- `signInWithGoogle()`: Triggers `GoogleSignIn` flow, obtains `GoogleSignInAuthentication`, creates `OAuthCredential`, signs in with `FirebaseAuth`, returns `UserModel`
- `signOut()`: Signs out of both `FirebaseAuth` and `GoogleSignIn`
- `getCurrentUser()`: Returns `UserModel` from `FirebaseAuth.currentUser` or `null`

**Repository — `AuthRepositoryImpl`:**
- `signInWithGoogle()`: Calls remote, then **validates the user's email** against `AuthConfig.authorizedEmails`. If the email is not in the list, calls `signOut()` and returns `Left(Failure.auth('Access denied. Your email is not authorized.'))`.
- `signOut()`: Delegates to remote
- `getCurrentUser()`: Delegates to remote, also validates email if user exists

### 5.3 Presentation

**BLoC — `AuthBloc`:**
- **Events** (freezed union): `signInWithGoogle`, `signOut`, `checkAuthStatus`
- **States** (freezed union): `initial`, `loading`, `authenticated(User user)`, `unauthenticated`, `error(String message)`
- On `checkAuthStatus`: Calls `GetCurrentUser`. If user returned → `authenticated`. If null → `unauthenticated`.
- On `signInWithGoogle`: Emits `loading`, calls `SignInWithGoogle`. Fold result to `authenticated` or `error`.
- On `signOut`: Calls `SignOut`, emits `unauthenticated`.

**Pages:**
- **`AuthWrapper`**: A `BlocBuilder<AuthBloc, AuthState>` that routes:
  - `authenticated` → `LoggedPage` (which contains the videos feature)
  - `unauthenticated` or `error` → `LoginPage`
  - `loading` → centered `CircularProgressIndicator`
  - `initial` → centered `CircularProgressIndicator`

- **`LoginPage`**: Displays "Login with Google" title, a "Sign in with Google" button, and an error message text widget below the button when auth fails.

- **`LoggedPage`**: After successful auth, this page displays the user's profile info (name, email, avatar) with a logout button, and provides navigation to the videos feature. It provides the `VideosBloc` via `BlocProvider` and dispatches `LoadVideos` on creation.

---

## 6. Feature: Videos

**Location:** `lib/features/videos/`

### 6.1 Domain

**Entity — `Video`** (freezed):
- `id` (String)
- `title` (String)
- `channelName` (String)
- `thumbnailUrl` (String)
- `publishedAt` (DateTime)
- `tags` (List\<String\>)
- `city` (String?)
- `country` (String?)
- `latitude` (double?)
- `longitude` (double?)
- `recordingDate` (DateTime?)
- Getters: `hasLocation`, `hasCoordinates`, `hasRecordingDate`, `locationText`

**Repository interface — `VideosRepository`:**
- `getVideosFromChannels(List<String> channelIds, {bool forceRefresh = false})` → `Future<Either<Failure, List<Video>>>`
- `getVideosByChannel(String channelName)` → `Future<Either<Failure, List<Video>>>`
- `getVideosByCountry(String country)` → `Future<Either<Failure, List<Video>>>`
- `clearCache()` → `Future<Either<Failure, void>>`

**Use cases:**
- `GetVideos` — params: `GetVideosParams(channelIds, forceRefresh)`
- `GetVideosByChannel` — params: `GetVideosByChannelParams(channelName)`
- `GetVideosByCountry` — params: `GetVideosByCountryParams(country)`

### 6.2 Data

**Model — `VideoModel`** (freezed + json_serializable):
- Fields mirror the entity plus string-typed dates (`publishedAt` as String, `recordingDate` as String?)
- Field names use YouTube API naming: `channelTitle` (maps to entity's `channelName`)
- `toEntity()`: Parses date strings to DateTime, maps `channelTitle` → `channelName`

**Remote data source — `VideosRemoteDataSource`:**
- `getVideosFromChannels(List<String> channelIds)` → `Future<List<VideoModel>>`
- Implementation:
  1. For each channel ID, call YouTube Data API `search` endpoint (`type=video`, `order=date`, `maxResults=50`), paginating through all results using `nextPageToken`.
  2. Collect all video IDs from search results.
  3. Call YouTube Data API `videos` endpoint with `part=snippet,recordingDetails` to fetch detailed info (tags, location, recording date).
  4. Build `VideoModel` objects from the detailed data.
  5. For videos with GPS coordinates (`latitude`/`longitude`), perform **reverse geocoding** using the `geocoding` package to derive city and country names. Fall back to parsing `locationDescription` if geocoding fails.
  6. Sort all videos by `publishedAt` descending.
- YouTube API key is read from `Config.youtubeApiKey`.

**Local data source — `VideosLocalDataSource`** (SQLite via `sqflite`):
- Database: `videos.db` with a single `videos` table.
- Schema columns: `id` (TEXT PK), `title`, `channel_title`, `thumbnail_url`, `published_at`, `tags` (JSON-encoded string), `city`, `country`, `latitude` (REAL), `longitude` (REAL), `recording_date`, `cached_at`.
- Indexes on: `channel_title`, `country`, `published_at`, `cached_at`.
- Methods:
  - `getCachedVideos()` — returns all videos ordered by `published_at DESC`
  - `cacheVideos(List<VideoModel>)` — clears table, inserts all videos with current timestamp as `cached_at` (batch operation)
  - `isCacheValid({Duration maxAge = 24 hours})` — checks if most recent `cached_at` is within `maxAge`
  - `getVideosByChannel(String channelName)` — queries by `channel_title`
  - `getVideosByCountry(String country)` — queries by `country`
  - `clearCache()` — deletes all rows

**Repository — `VideosRepositoryImpl`:**
- `getVideosFromChannels()`:
  1. If `forceRefresh` is false and cache is valid (< 24 hours) and non-empty → return cached data.
  2. Otherwise fetch from remote, cache results, return entities.
  3. If remote call throws `ServerException` → attempt to return cached data as fallback. If cache also fails → return `Left(Failure.server(...))`.
- `getVideosByChannel()` and `getVideosByCountry()` read from local cache only.
- `clearCache()` delegates to local data source.

### 6.3 Presentation

**BLoC — `VideosBloc`:**

Hardcoded channel IDs:
```dart
static const List<String> _channelIds = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];
```

**Events** (freezed union):
- `LoadVideos` — initial load
- `RefreshVideos` — force refresh from API (preserves current filter/sort state)
- `FilterByChannel(String? channelName)` — null clears the filter
- `FilterByCountry(String? country)` — null clears the filter
- `SortVideos(SortBy sortBy, SortOrder sortOrder)`
- `ClearFilters` — resets to no filters, publishedDate descending

**States** (freezed union):
- `initial`
- `loading`
- `loaded(List<Video> videos, List<Video> filteredVideos, String? selectedChannel, String? selectedCountry, SortBy sortBy, SortOrder sortOrder, bool isRefreshing)`
- `error(String message)`

**Enums:**
- `SortBy`: `publishedDate`, `recordingDate`
- `SortOrder`: `ascending`, `descending`

**Key logic:**
- `_applyFiltersAndSort()` applies channel filter → country filter → sort in sequence, producing a new `VideosLoaded` state.
- `_sortVideos()` handles null `recordingDate` by treating it as `DateTime(1970)`.
- `RefreshVideos` maintains existing filter/sort state after receiving new data.
- Helper getters: `availableChannels` and `availableCountries` extract unique sorted values from the full (unfiltered) video list.

**Pages:**

#### VideosPage
- **Header/toolbar** with:
  - Channel filter dropdown (populated from `availableChannels`)
  - Country filter dropdown (populated from `availableCountries`)
  - Sort dropdown with 4 options: Published Date (Newest/Oldest), Recording Date (Newest/Oldest)
  - Clear filters button (only visible when a filter or non-default sort is active)
  - Refresh button with loading indicator during refresh
  - Logout button (user avatar in a dropdown menu that dispatches `AuthEvent.signOut()`)
- **Video count** display showing filtered count vs total (e.g., "Showing 12 of 45 videos")
- **Video list** (`ListView`) where each card displays:
  - Thumbnail image (using `cached_network_image` with loading placeholder and error fallback)
  - Video title
  - Channel name
  - Publication date (formatted `YYYY-MM-DD` using `intl` package)
  - Recording date (if available, formatted `YYYY-MM-DD`)
  - Location: city and country (if available), GPS coordinates (if available)
  - Tags: up to 3 shown inline, with "+N more" indicator for overflow
  - A play button (red circular FAB) that launches the video
- **Pull-to-refresh** support (dispatches `RefreshVideos`, preserves filter/sort)
- **Video launch logic**: Tries YouTube deep link (`youtube://watch?v=ID`) first, falls back to browser URL (`https://www.youtube.com/watch?v=ID`)
- **Error state**: Shows error message with a retry button that dispatches `LoadVideos`
- **Map navigation**: A button to navigate to the MapScreen

#### MapScreen
- Uses `flutter_map` package with **OpenStreetMap** tile layer.
- Displays only videos that have valid coordinates (`hasCoordinates` check).
- **Markers**: Red circular markers with a play icon at each video's GPS location.
- **Auto-fit bounds**: After loading, the map automatically pans and zooms to fit all markers with padding (~50px). Calculates appropriate zoom level based on geographic spread of markers.
- **Marker interaction**: Tapping a marker shows a **bottom sheet** containing:
  - Video thumbnail
  - Title, channel name
  - Publication date and recording date
  - Location info (city, country, GPS coordinates)
  - Tags
  - "Watch Video" button that launches the YouTube video
- Bottom sheet is dismissible (close button), takes up no more than ~25% of screen height.
- Handles edge cases: no videos with location data (shows informational message).

---

## 7. Dependencies

### Runtime
| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Firebase Authentication |
| `firebase_performance` | Firebase Performance Monitoring |
| `google_sign_in` | Google OAuth Sign-In |
| `flutter_bloc` | BLoC state management |
| `bloc_concurrency` | BLoC event transformers |
| `get_it` | Service locator for DI |
| `injectable` | DI code generation annotations |
| `dartz` | Functional programming (Either type) |
| `freezed_annotation` | Immutable class annotations |
| `json_annotation` | JSON serialization annotations |
| `equatable` | Value equality |
| `http` | HTTP client for API calls |
| `url_launcher` | Launch URLs in browser/app |
| `cached_network_image` | Image caching and loading |
| `intl` | Date formatting |
| `sqflite` | SQLite local database |
| `path` | File path utilities |
| `geocoding` | Reverse geocoding (coordinates → address) |
| `flutter_map` | OpenStreetMap map widget |
| `latlong2` | GPS coordinate types |

### Dev
| Package | Purpose |
|---|---|
| `flutter_lints` | Lint rules |
| `injectable_generator` | DI code generation |
| `build_runner` | Code generation runner |
| `freezed` | Immutable class code generation |
| `json_serializable` | JSON serialization code generation |
| `bloc_test` | BLoC testing utilities |
| `mocktail` | Mocking for tests |

---

## 8. Build & Run Commands

```bash
flutter pub get                          # Install dependencies
cp lib/config/auth_config.template.dart lib/config/auth_config.dart  # Create auth config
cp lib/config/config.template.dart lib/config/config.dart            # Create API config
# Edit both config files with real values
dart run build_runner build              # Generate freezed/injectable/json code
flutter analyze                          # Static analysis
flutter test                             # Run tests
flutter run                              # Run on connected device/emulator
dart scripts/ensure_config.dart          # Generate CI placeholder configs
```

---

## 9. YouTube Data API Usage

The app uses two YouTube Data API v3 endpoints:

1. **Search** (`GET https://www.googleapis.com/youtube/v3/search`):
   - Params: `part=snippet`, `channelId=<id>`, `type=video`, `order=date`, `maxResults=50`, `key=<apiKey>`, `pageToken=<token>`
   - Used to discover videos per channel, paginating through all results.

2. **Videos** (`GET https://www.googleapis.com/youtube/v3/videos`):
   - Params: `part=snippet,recordingDetails`, `id=<comma-separated IDs>`, `key=<apiKey>`
   - Used to fetch detailed metadata: tags, recording location (GPS + description), recording date.
   - Video IDs are batched from search results.

Reverse geocoding is applied to videos with GPS coordinates to derive human-readable city/country names.
