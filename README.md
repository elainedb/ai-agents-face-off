# AI agents face-off

The same mobile app spec, handed to different AI coding agents, on three stacks. Every cell in the tables below is an independent implementation built from scratch by one agent. This repo replaces the 18 separate repositories the experiments used to live in.

## Round 2 · 2026 · `2026-ytdash/`

A YouTube dashboard: Google Sign-In with an email allowlist, a video feed from four channels, local caching, filtering and sorting, a map of recording locations, and performance monitoring. Built in five incremental versions from one spec per stack:
[Android](2026-ytdash/SPEC-android.md) · [Flutter](2026-ytdash/SPEC-flutter.md) · [React Native](2026-ytdash/SPEC-rn.md)

Each agent also received a per-stack instruction file; see [`2026-ytdash/context-files/`](2026-ytdash/context-files).

| Stack | Claude Code | Gemini | Codex |
|---|---|---|---|
| Android (Kotlin, Compose) | [android/claude](2026-ytdash/android/claude) | [android/gemini](2026-ytdash/android/gemini) | [android/codex](2026-ytdash/android/codex) |
| Flutter | [flutter/claude](2026-ytdash/flutter/claude) | [flutter/gemini](2026-ytdash/flutter/gemini) | [flutter/codex](2026-ytdash/flutter/codex) |
| React Native (Expo) | [rn/claude](2026-ytdash/rn/claude) | [rn/gemini](2026-ytdash/rn/gemini) | [rn/codex](2026-ytdash/rn/codex) |

## Round 1 · 2025 · `2025-login-feed/`

A smaller spec: login with Google, an allowlist of authorized emails, and a YouTube video list.

| Stack | Claude Code | Gemini | Junie |
|---|---|---|---|
| Android (Kotlin) | [android/claude](2025-login-feed/android/claude) | [android/gemini](2025-login-feed/android/gemini) | [android/junie](2025-login-feed/android/junie) |
| Flutter | [flutter/claude](2025-login-feed/flutter/claude) | [flutter/gemini](2025-login-feed/flutter/gemini) | [flutter/junie](2025-login-feed/flutter/junie) |
| React Native (Expo) | [rn/claude](2025-login-feed/rn/claude) | [rn/gemini](2025-login-feed/rn/gemini) | [rn/junie](2025-login-feed/rn/junie) |

## Experiment runs are tags

Each project's `main` holds the final state. Intermediate runs, model variants, and version snapshots are tags, named `<round>/<stack>-<agent>/<run>`:

```
2026-ytdash/android-gemini/run2-pro     third-party model variant, second attempt
2026-ytdash/rn-claude/run1-opus
2026-ytdash/flutter-codex/v3            snapshot after spec version 3
2025-login-feed/android-claude/v4
```

List them with `git tag -l '2026-ytdash/flutter-*'`. Each tag's tree is exactly what the agent left behind, minus the binaries noted below.

## What changed on import

- Every original commit is preserved, rewritten into its subdirectory. Authors and dates are untouched.
- Committed build outputs were stripped from history: release APKs, an Expo `dist/` bundle, and a decompiled Maestro driver. Together they accounted for about 560 MB of the old repos. Nothing else was removed.
- The `SPEC.md` files were identical across the three agents of each stack, so they now live once per stack under `2026-ytdash/`. The React Native spec differs per agent only in bundle identifiers and URL scheme, which is noted inline.
- History was scrubbed of credentials the agents had committed on some run branches: two YouTube Data API keys, the sign-in allowlist emails, and a local SDK path. They read `YOUR_YOUTUBE_API_KEY` and `user1@example.com` style placeholders now. The Firebase client config in `firebase_options.dart` is intentionally left as is.
- Each project keeps its own `sonar-project.properties`; those still point at the old per-repo SonarCloud projects and need re-binding if SonarCloud analysis is wanted again.

## Running a project

```bash
cd 2026-ytdash/android/claude && ./gradlew testDebugUnitTest
cd 2026-ytdash/flutter/gemini && flutter pub get && flutter test
cd 2026-ytdash/rn/codex && npm ci --legacy-peer-deps && npm run test:ci
```

Every project gitignores its real credentials (Google Sign-In config, YouTube API key, email allowlist) and ships a placeholder next to each one. To build or test without credentials, run the same script CI uses; it copies each placeholder into place and never overwrites an existing file:

```bash
.github/scripts/prepare-project.sh 2025-login-feed/flutter/junie
```

Each project's own README or setup notes explain how to supply real values.

CI runs unit tests for every project on the stack whose files changed: [Android](.github/workflows/android.yml) · [Flutter](.github/workflows/flutter.yml) · [React Native](.github/workflows/react-native.yml).
