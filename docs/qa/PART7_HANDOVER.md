# Part 7 verification and owner handover

Date: 2026-10-25. Baseline source: commit `e605f0e` (v1.0.12+12).

The owner requested analysis and tests only. No Part 7 device test, release build, installation, or Play Console measurement is claimed. An isolated QA build was attempted before this instruction and stopped when the device was disconnected; it produced no usable device test result or APK. The owner's installed app and data were not changed by this work.

## Completed repository work (7.1–7.6)

| Gate | Result | Evidence |
| --- | --- | --- |
| 7.1 Dead-code sweep | Complete | Whole-project reference audit described below. |
| 7.2 Static analysis | Clean | `flutter analyze --no-pub`: `No issues found!` (after app cleanup). |
| 7.3 Content | Pass | `dart run tools/validate_content.dart`; both `generate_content_manifest.dart --check` and `generate_localizations.dart --check` pass. |
| 7.4 Full suite | Pass | `nice -n 15 flutter test --no-pub --concurrency=1`: **216/216 tests passed**. |
| 7.5 Reading card invariant | Pass | `test/widget/prayer_text_unboxed_test.dart` ran in the full suite. `NovenaTextView` and `LitanyTextView` still have no `AppCard`, `showContainer`, or card import. The documented non-St-Rita closing and thanksgiving wrappers remain. |
| 7.6 Owner checklist | Complete | Ordered checks below. |

### Cleanup reference audit

Before deletion, `rg -n 'AssetPaths\.' lib test integration_test tool tools --glob '*.dart'` found only `defaultContentLanguage`, `appLogo`, and `contentManifest` in use. The other fourteen constants in `lib/core/constants/asset_paths.dart` were removed. The empty `assets/translations/.gitkeep` placeholder was removed after `rg` found no references or pubspec asset entry. `PrayerCard` lost a redundant `Ink` wrapper; its `AppCard` and favorite action remain. The ignored language argument on `PrayerEntity.title/text` was removed and all callers updated. Rosary loading now resolves declared manifest paths rather than hardcoded directory names; the new unit test proves custom paths and caching. No reading view was deleted or boxed.

The existing `integration_test` files are retained. Their stale Kiswahili Pray and English day-completion labels were updated for the current UI, but these files **have not run on a device** in Part 7.

## Ordered owner checks (Parts 1–7)

Record each result as pass/fail with device model, Android version, app version, language, theme, and a screenshot or short note for failures.

1. **Visual parity and reading layout (Parts 1, 2, 4, 6; 7.9).** In both English and Kiswahili, inspect Today, Prayer library, each category, every prayer, Favorites, Rosary and a guided step, Novena list/detail/every day, closing prayer, thanksgiving, Settings, About, and onboarding. Inspect light/dark themes and normal/large text. Confirm standard prayers, litanies, novena days, and rosary readings are unboxed; non-St-Rita closing and thanksgiving sections stay carded. Check the logo at 1x, 2x, and 3x densities, and A+/A− response. Pixel diffs against pre-optimization captures require the original captures: none are in the repository. A fresh baseline recreation is not historical sign-off.
2. **Content and saved state (Parts 3 and 6).** Open all 36 bundled prayers and all 9 novenas across both languages; check day bodies, closing and thanksgiving text, search, favorites, and language switching. Resume St Rita with saved days 10–11 and confirm day 12 is next after restart/language change. Finish a fresh St Rita on day 12 and a standard novena on day 9. Verify no stale English/Kiswahili content appears after switching.
3. **Navigation and offline behavior (Parts 3, 5, 6; 7.7/7.10).** With connectivity off, use prayer/category/detail, novena and rosary flows. Check a full rosary run, external English and Kiswahili prayer links including the Divine Mercy alias, and bottom-navigation scroll retention after visiting all four tabs. Run the three files in `integration_test/` on a connected device or emulator if desired; source selectors are updated but device results remain open.
4. **Reminders and home widget (Parts 2 and 5; 7.10).** Set and change a reminder; confirm it fires at the chosen time. Confirm widget content redraws, then cold-launch from the widget and confirm the destination opens. Test after a fresh launch as well as a warm app.
5. **Performance on the low-end device (Parts 1, 4, 5; 7.10).** Record debug and profile first-frame timings; profile frame timings while scrolling the heaviest litany and longest novena day; and peak/retained memory before and after visiting tabs. Compare against a measured build of baseline `e605f0e` on the same device and Flutter toolchain if a true before/after result is needed. The plan's old baseline was not a device measurement.
6. **Release size (Parts 1, 2; 7.8/7.11).** When the owner chooses to build, create a fresh release AAB and record its byte size. For real delivery size, inspect the Play Console internal-test download figure or device-specific split APKs. Compare with the preserved original AAB (44,949,806 bytes) and account for Flutter/toolchain changes. `tool/size_report.dart` reports compressed AAB-entry sums for comparison, **not** actual download or installed sizes.

## Measured results and open gates (7.7–7.11)

| Measure/check | Baseline | Current result | Status |
| --- | --- | --- | --- |
| Full host tests | Earlier Part 6: 215/215 | 216/216 | Pass |
| Analysis/content/generators | Earlier green | Green | Pass |
| Source logo bytes | 1,096,474 at `e605f0e` | 17,117 | Source measurement only; inspect on device |
| Current source assets | No comparable historical total recorded | 41 files, 0.54 MiB raw, 0.11 MiB gzip -9 | Source measurement only |
| Original release AAB bytes | 44,949,806 | Fresh current AAB not built by request | Open |
| Selected arm64 AAB entry compressed sum | 9.73 MiB in original bundle | Fresh current value not measured | Open; not download size |
| Three integration tests (7.7) | No baseline device results | No Part 7 device result | Owner check |
| Every-screen bilingual screenshot diff (7.9) | Original screenshots unavailable | No device capture/diff | Owner check |
| First frame, jank, memory, interactions (7.10) | No comparable device baseline | No Part 7 device result | Owner check |
| Actual Play delivery/installed size (7.11) | Not measured | Not measured | Owner check |

The estimates in §2.3 of `app_optimization.md` remain estimates. No startup, jank, memory, download-size, or full visual-parity target is claimed met from host tests alone.
