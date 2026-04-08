# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Expo + React Native app with Google Sign-In authentication that displays YouTube videos from specified channels. Features include video feed with filtering/sorting, SQLite caching, and a map view showing video recording locations. Built with Clean Architecture.

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
npx expo prebuild --platform android  # Generate native project
npx ts-node scripts/ensure-config.ts  # Generate CI placeholder configs
```

## Configuration

Sensitive config files are gitignored. For local development:
- `src/config/auth-config.ts` — Authorized email whitelist (from `auth-config.template.ts`)
- `src/config/api-config.ts` — YouTube API key (from `api-config.template.ts`)
- `google-services.json` — Android Firebase/Google Sign-In config

Additional configuration:
- Path alias: `@/` maps to project root (configured in `tsconfig.json`)
- TypeScript strict mode enabled, extends `expo/tsconfig.base`
- ESLint uses Expo's flat config (ESLint 9+)
- New Architecture and React Compiler are enabled

## Architecture

**Expo 54 + React Native 0.81** app using **Clean Architecture** organized by feature under `src/features/`.

**Layers per feature:**
- **Domain**: Entities, repository interfaces, use cases (`UseCase<T, P>` base). All repo methods return `Result<T>`.
- **Data**: Repository implementations, remote/local data sources, Zod schemas for validation.
- **Presentation**: Zustand stores for state management, React screen components.

**Routing**: Expo Router (file-based) in `app/`. Stack navigation: `login → main → map`.

**Key screens**:
- `app/login.tsx` — Google Sign-In via `@react-native-google-signin/google-signin`, validates against email whitelist
- `app/main.tsx` — FlatList of videos with filter/sort modals, pull-to-refresh, cache-first loading
- `app/map.tsx` — `react-native-maps` with OpenStreetMap tiles, animated bottom panel for video details

**DI Container**: `src/core/di/container.ts` — Manual dependency injection, initialized at app startup.

### Key Patterns

- **State management**: Zustand stores (`auth-store.ts`, `videos-store.ts`)
- **Caching**: SQLite via `expo-sqlite` with 24-hour TTL
- **Error handling**: `Result<T>` type, `Failure` discriminated union, exception classes
- **Validation**: Zod schemas for API response validation
- **Networking**: Direct fetch to YouTube Data API v3. Reverse geocoding via OpenStreetMap Nominatim (rate-limited 1 req/sec)
- **Firebase**: `@react-native-firebase/app` + `@react-native-firebase/perf` for performance monitoring

## Testing

Jest with `babel-jest` and `@testing-library/react-native`. Test environment is jsdom. Tests in `src/utils/__tests__/`. Coverage collects from `app/` and `src/`.

`jest-setup.js` mocks react-native, expo, and native modules for the test environment.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`): checkout → npm ci → ensure-config → test → lint → SonarCloud scan.

## Key Dependencies

- expo + react-native for cross-platform UI
- expo-router for file-based navigation
- expo-sqlite for SQLite caching
- @react-native-google-signin/google-signin for Google Sign-In
- @react-native-firebase/app + perf for Firebase Performance
- zustand for state management
- zod for runtime validation
- react-native-maps for native map view
- @gorhom/bottom-sheet + react-native-gesture-handler + react-native-reanimated
