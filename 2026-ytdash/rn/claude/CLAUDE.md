# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Expo + React Native app with Google Sign-In authentication (via `@react-native-google-signin/google-signin`) that displays YouTube videos from specified channels. Features include video feed with filtering/sorting, SQLite caching (expo-sqlite), and a map view showing video recording locations using Leaflet.js in a WebView.

## Build & Run Commands

```bash
npm start              # Start Expo dev server
npm run android        # Build & run on Android
npm run ios            # Build & run on iOS
npm run web            # Run web version
npm run lint           # ESLint
npm test               # Jest tests
npm run test:coverage  # Tests with coverage report
npm run test:ci        # CI: coverage, no watch
npx jest path/to/file.test.ts  # Run single test file
```

## Configuration

Sensitive config files are gitignored. For local development:
- `src/config/auth-config.ts` — Authorized email list (from `auth-config.template.ts`)
- `src/config/api-config.ts` — YouTube API key (from `api-config.template.ts`)
- `google-services.json` — Android Firebase/Google Sign-In config

Additional configuration:
- Path alias: `@/` maps to project root (configured in `tsconfig.json`)
- TypeScript strict mode enabled, extends `expo/tsconfig.base`
- ESLint uses Expo's flat config (ESLint 9+)
- New Architecture and React Compiler are enabled

## Architecture

**Expo 54 + React Native 0.81** app following **Clean Architecture** organized by feature.

**Routing**: Expo Router (file-based) in `app/`. Stack navigation: `login → main → map`.

### Project Structure

```
src/
  core/
    error/         — exceptions.ts, failures.ts, result.ts
    usecases/      — usecase.ts (base interface)
    di/            — container.ts (manual DI)
  config/          — auth-config.ts, api-config.ts (gitignored)
  features/
    authentication/
      domain/      — User entity, AuthRepository interface, use cases
      data/        — UserModel, AuthRemoteDataSource (Google Sign-In), AuthRepositoryImpl
      presentation/ — Zustand auth store
    videos/
      domain/      — Video entity, VideosRepository interface, use cases
      data/        — VideoModel, remote/local datasources, geocoding service, repository impl
      presentation/ — Zustand videos store, VideoItem, FilterModal, SortModal
  utils/           — string-helpers.ts
app/
  _layout.tsx      — Root Stack with ThemeProvider, initialRouteName: 'login'
  index.tsx        — Redirect to /login or /main based on auth
  login.tsx        — Google Sign-In screen
  main.tsx         — Video list with filter/sort/map controls
  map.tsx          — Leaflet.js map in WebView with video markers
```

### Key Patterns

- **Clean Architecture**: Domain (entities, repository interfaces, use cases) → Data (models, datasources, repository impls) → Presentation (Zustand stores, screens)
- **DI Container**: Manual singleton container in `src/core/di/container.ts`, initialized in `_layout.tsx`
- **Error Handling**: `Result<T>` type (`{ok: true, data: T} | {ok: false, error: Failure}`) throughout data/domain layers
- **State management**: Zustand stores (`auth-store.ts`, `videos-store.ts`)
- **Caching**: SQLite via `expo-sqlite` v14 with 24-hour TTL
- **API Validation**: Zod schemas for YouTube API responses
- **Map**: Leaflet.js in `react-native-webview` with OpenStreetMap tiles

## Testing

Jest with babel-jest and `@testing-library/react-native`. Test environment is jsdom. Coverage collects from `app/`, `components/`, `hooks/`, `src/`.

`jest-setup.js` mocks react-native, expo, and native modules for the test environment.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`): checkout → npm ci → test → lint → SonarCloud scan. `scripts/ensure-config.ts` generates placeholder configs for CI.

## Key Dependencies

- expo + react-native for cross-platform UI
- expo-router for file-based navigation
- expo-sqlite@14 for SQLite caching (pinned for Expo SDK 54)
- @react-native-google-signin/google-signin for Google auth
- @react-native-firebase/app + perf for Firebase
- zustand for state management
- zod for runtime validation
- react-native-webview for Leaflet.js map
- expo-image for optimized image loading
