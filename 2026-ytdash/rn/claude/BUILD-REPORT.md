# Build Report — ytdash (React Native / Expo)

## Stack

See `plan.md` for the full rationale. Summary:

- **Expo SDK 57, React Native 0.86, TypeScript (strict)**.
- **State**: `zustand` — `testConfigStore`, `authStore`, `videoStore`, `externalLinkStore`, `navStore`
  (a hand-rolled 3-screen stack; no nav library, no deep-linking requirement in scope).
- **Persistence**: `@react-native-async-storage/async-storage`, one JSON blob, replace-on-refresh +
  stale-cache-fallback-on-network-error.
- **Map**: `react-native-webview` running a Leaflet/OSM page (real pins, the human path) **plus** a
  native `Pressable` row (`map_marker`, one per located video) rendered outside the WebView — the
  Maestro-reachable affordance the constitution's §5 map-marker contract requires, since WebView DOM
  markers are not reachable by a black-box tool.
- **UI-test-mode**: a local Expo module (`modules/test-config`, Kotlin) reads the launch Activity's
  intent extras (`uiTestMode`, `mockAuthEmail`, `apiBaseUrl`, `apiKey`, `authorizedEmails`,
  `captureExternalLinks`) and surfaces them to JS — the same seam Maestro drives on Android/Flutter,
  now on RN.
- **Auth**: `mockAuthEmail` short-circuit in UI-test-mode; `expo-auth-session` Google OAuth for real
  mode (see Deviations below).
- **Tests**: Jest — 3 domain suites (`isAuthorized`, `sortVideos`, `filterVideosByCategory`, 12 cases)
  + 1 persistence suite (AsyncStorage round-trip, 4 cases). 16/16 passing. `expo lint` — 0
  errors/warnings.

## Functional result — 12/12/12... actually 14/14/14

`spec/acceptance-criteria.md` lists **14** `AC-*` rows (`flows/` has 14 `AC-*.yaml` files) and its own
"Scoring" section defines `passed_ACs / 14` — the run prompt's "12 acceptance criteria" appears to be
a stale reference; this report follows the frozen `spec/acceptance-criteria.md` (14) as the source of
truth, per playbook §5 (min/median/max over 3 runs, on device `25251FDF60029V`, mock at
`http://127.0.0.1:8090` via `adb reverse`):

| Run | Passed |
|---|---|
| 1 | 14/14 |
| 2 | 14/14 |
| 3 | 14/14 |

**min / median / max = 14/14 / 14/14 / 14/14** — no flakiness observed across 3 consecutive full
suite runs. `map_marker_fallback_used=false` (the native chip affordance is the primary path by
design, per constitution §5 — not a fallback from a failed attempt at tagging the WebView's DOM
pins, which are categorically unreachable).

One real bug was caught and fixed during self-validation: **AC-MAP-03** initially failed because
`external_open_url` was a `<Text>` nested inside a `<View testID="external_open_url">` — Android
merges the child's text up into the *parent's* `accessibilityText`, and Maestro's exact-string
equality fallback (used when a copied value contains characters like `?`/`=` that make it an invalid
self-matching regex — see `Filters.kt`'s `regex.pattern == value` check) requires the `text`/
`accessibilityText` attribute to be byte-identical to the copied value. Moving `testID` directly onto
the `<Text>` node (matching how `detail_video_url` was already structured) fixed it. Fixed in
`src/ui/components/ExternalLinkBanner.tsx`.

## Real-mode smoke check

Ran the same release APK with `apiBaseUrl=https://www.googleapis.com` and the real key from
`config/secrets.env`, `mockAuthEmail` still set (UI-test-mode stays on to skip the interactive Google
picker, but every other extra points at production): the list populated with real videos from the
configured channels (`config/channels.json`), `video_count` updated, a list-row external-link capture
showed a real `youtube.com/watch?v=…` URL, and the map showed real markers with real recording
locations (confirmed by screenshot — a real channel's dated video series with real GPS coordinates
across Western Europe). No mock/fixture values anywhere in this path — same parsing code as the mock,
different base URL + key, exactly per `spec/youtube-api.md`.

## Deviations

- **No `google-services.json` in this workspace.** The run prompt references one, but
  `config/` only contains `channels.json` and `secrets.env` (`YOUTUBE_API_KEY`,
  `AUTHORIZED_EMAILS`, both gitignored, both loaded into `app.config.js`'s `extra` at build time —
  never committed). Real-mode Google sign-in is wired via `expo-auth-session`'s generic OAuth flow
  (no native SDK / `google-services.json` dependency), but has no OAuth client id configured in this
  environment, so it throws a clear, caught error (surfaced as `login_error_message`) rather than
  crashing. The *authorization* half of real auth (`isAuthorized()` against the real whitelist) is
  fully exercised via UI-test-mode's `mockAuthEmail`, which shares the exact same code path as a real
  Google sign-in from the point the email is known onward — only the credential-acquisition step is
  unverified end-to-end here.
- **No `expo-router` / nav library.** 3 screens, no deep-linking requirement in the spec — a
  hand-rolled `navStore` keeps every screen in one view tree, which also sidesteps the
  Android-popup-window accessibility trap the constitution calls out (§5a) for Compose; RN's
  `testID` doesn't have that specific failure mode, but a single tree is simpler to audit regardless.
- **AsyncStorage over SQLite** for the cache — the spec only requires "persisted locally, source the
  list reads from, stale-fallback on error"; a JSON blob satisfies that and is directly unit
  testable without a native DB layer. `expo-sqlite` is the "reference" choice per
  `cross-framework-setup.md`, not a requirement.

## Artifacts

- `plan.md`, `tasks.md` — Spec-Kit planning artifacts.
- `results/mock-run{1,2,3,4}.xml` — JUnit output from the 4 validation runs (run1 is the initial
  13/14 run before the AC-MAP-03 fix; runs 2–4 are the 3 clean 14/14 runs used for the min/median/max
  above).
- `modules/test-config/` — the local Expo module for UI-test-mode launch extras.
