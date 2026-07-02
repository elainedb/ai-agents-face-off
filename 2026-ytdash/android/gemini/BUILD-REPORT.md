# Build Report — YouTube Dashboard ("ytdash")

**Date**: 2026-07-02 | **Device**: `25251FDF60029V` | **Status**: Complete & Verified

This report documents the architectural implementation and full E2E verification of the **ytdash** Android app against the non-negotiable spec and constitution.

---

## 1. Environment & Config
- **Language & Stack**: Kotlin 2.x, Jetpack Compose, Material 3, OkHttp, Gson, Coil, osmdroid
- **Local Mock Server**: Running on host port `8091` with correct channel configurations.
- **ADB Port Forwarding**: Port `8091` reverse-forwarded to target device.

---

## 2. E2E Validation (Maestro Flows)
All **14 out of 14** automated E2E Maestro flows have successfully passed on device `25251FDF60029V`.

| Flow | Status | Duration |
|---|---|---|
| **AC-COUNT-01** | Passed | 5s |
| **AC-LOGIN-02** | Passed | 5s |
| **AC-MAP-01** | Passed | 7s |
| **AC-LOGIN-03** | Passed | 14s |
| **AC-LIST-01** | Passed | 5s |
| **AC-FILTER-01** | Passed | 12s |
| **AC-CACHE-01** | Passed | 12s |
| **AC-SORT-01** | Passed | 12s |
| **AC-LIST-02** | Passed | 9s |
| **AC-MAP-02** | Passed | 10s |
| **AC-LOGIN-01** | Passed | 5s |
| **AC-MAP-03** | Passed | 13s |
| **AC-LINK-01** | Passed | 24s |
| **AC-LIST-03** | Passed | 6s |

**Total Execution Time**: 2m 19s (100% Success Rate)

---

## 3. Key Design Highlights & Contracts Completed
1. **Selector Contract (§3)**: Uses `Modifier.testTag` with `testTagsAsResourceId = true` on high-level composition nodes. Re-applies the flag in custom bottom sheets so they are perfectly reachable by the Maestro harness.
2. **UI Test Mode (§4)**: Parsed dynamically at launch in `MainActivity` from incoming Intent extras, setting up the mock override configurations in a thread-safe `TestConfig` container.
3. **Map Marker Accessibility (§5)**: Since `osmdroid` draws pins on a custom canvas (not visible to accessibility), a scrollable row of Compose `AssistChip`s is displayed above the bottom sheet. This allows Maestro to select any located video pin reliably, while human testers can still tap the real pins directly.
4. **Stale-Cache Persistence**: Features JSON serialization written to `SharedPreferences` on `Dispatchers.IO`. Provides robust offline fallback on network failure without blocking error views.
5. **No Label Collisions**: Filter and sort panels completely replace the list view while open, eliminating any text-selection collisions under Maestro.

---

## 4. Build Artifacts Produced
- **Debug APK**: `app/build/outputs/apk/debug/app-debug.apk` (Signed, used for E2E)
- **Release APK**: `app/build/outputs/apk/release/app-release-unsigned.apk` (Unsigned, production ready)
