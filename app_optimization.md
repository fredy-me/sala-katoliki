# Sala Katoliki — App Optimization Plan

**Status:** Part 1 done. Part 2: implemented (with documented deviation), all four gate commands green. Part 3: implemented (with documented deviations on 3.4 and 3.5), all four gate commands green and the full test suite green. Part 4: 4.1–4.5 and 4.7 implemented and measured, all four gate commands green; 4.6 deliberately not started, it needs the mandatory OWNER screenshot pass first and a call-site refactor. Planning for Part 5 pending user approval.
**Created:** 2026-09-27
**Baseline commit:** `e605f0e` (v1.0.12+12)
**Scope:** App weight, startup time, frame responsiveness, memory, and content-authoring flexibility. UI/UX appearance must not change.

This document is the tracking record for optimization work. It is a companion to [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md), which remains the canonical MVP delivery record. Where the two overlap, this file records *how* work is sequenced and *whether the goal was met*.

---

## 0. Ground rules

| Rule | Detail |
| --- | --- |
| **No visual change** | Every part below has "no intended visual change" as an acceptance criterion. If pixels move, the part is not done. |
| **No prayer boxing — hard invariant** | See §0.1. Any part that adds a card, container, background, or border to a prayer reading view is rejected. |
| **No content/schema change** | Bundled JSON stays byte-identical. The optimization work is Dart + build + tooling only. |
| **No behaviour regression** | Search results, deep links, favorites, novena progress, reminders, and the home-screen widget must behave identically. |
| **Measure, don't assume** | Every size or timing claim is recorded with how it was measured. Estimates are labelled as estimates. |
| **One part at a time** | Parts are merged independently. Each has its own acceptance gate. |
| **Rollback** | Each part is a self-contained set of commits so it can be reverted independently. |
| **Verification is limited** | See §0.2. No app run and no APK/debug/AAB build. |

---

## 0.1 Hard invariant — prayers are never boxed

**No prayer reading view may display inside a card, container, background, fill, or border. This is the current behaviour and it must not change.**

Verified current state, after the Part 1.4 refactor:

| Screen | Body view | Card source | Result |
| --- | --- | --- | --- |
| Prayer detail — standard prayers | `PrayerTextView` | none exists | **No card** |
| Prayer detail — litanies | `LitanyTextView` | none exists | **No card** |
| Novena day | `NovenaTextView` | none exists | **No card** |
| Rosary step | `LitanyTextView` | none exists | **No card** |

`showContainer` has been **removed entirely**. It no longer exists on any widget, so
"a call site forgot to pass `false`" is no longer a possible failure.

The card now lives at the call site instead of inside the text view:

| Call site | Card at call site? |
| --- | --- |
| `prayer_detail_screen.dart` — standard and litany | No |
| `rosary_step_screen.dart` | No |
| `novena_day_screen.dart` | No |
| `novena_thanksgiving_screen.dart` | Yes, for non-`st_rita` |
| `novena_closing_prayer_screen.dart` | Yes, for non-`st_rita` |

`NovenaTextView` and `LitanyTextView` no longer import `app_card.dart`, so they are
**structurally incapable** of drawing a card. This is enforced by the compiler
rather than by reviewer discipline, which is strictly stronger than the previous
boolean flag.

### One deliberate exception

`_HighlightedParagraph` (`novena_text_view.dart:560`) paints a subtle
`surfaceContainerHighest` panel with a gold rule behind individual lines — the
opening line "In the name of the Father", prayer counts, and leader responses.

This is **per-line text styling inside a paragraph, not a card around the
reading.** It must not be removed in the name of this invariant, and it is
pinned by its own test so it cannot be "simplified" away later.

### Why this is called out separately

Several parts touch exactly this code, and each could silently reintroduce a card:

| Part | Item | Card-reintroduction risk |
| --- | --- | --- |
| 4 | 4.4 memoize the body split | A memoized/cached parse must not absorb or drop a card branch |
| 4 | 4.6 virtualize the text views | A virtualized text view must not gain a card wrapper |
| 5 | 5.4 bottom-nav state preservation | Changing how screens are built must not change what wraps their content |
| 6 | 6.1 data-driven style flags | Routing a prayer to a different text view must not land it in a carded surface |

### Enforcement

Implemented in `test/widget/prayer_text_unboxed_test.dart`, 8 tests:

- Asserts `find.byType(AppCard)` is empty for `NovenaTextView` (including every
  style flag combination) and `LitanyTextView` (including `stRitaStyle`).
- Asserts neither text view source contains `showContainer`, `AppCard(`, or
  `app_card.dart`.
- Asserts the two call sites that legitimately show a card still do, so this
  invariant cannot be satisfied by quietly deleting the novena cards.
- Asserts the inline scripture highlight is still present.

Screenshot comparison of all prayer screens, both languages, remains a mandatory
OWNER gate.

### Deliberately out of scope

Two nearby cases must **keep** their current behaviour and are **not** to be "simplified" into consistency with prayers:

| Case | Current behaviour | Keep as-is |
| --- | --- | --- |
| Novena closing prayer | `AppCard` at the call site, for non-`st_rita` | Carded except for `st_rita` |
| Novena thanksgiving | `AppCard` at the call site, for non-`st_rita` | Carded except for `st_rita` |
| Prayer list tile | `PrayerCard` → `AppCard` | List tiles in the library, search results, and favourites keep their card. This is a list row, not a prayer reading view |
| Novena inline scripture highlight | `_HighlightedParagraph` | Per-line styling, not a card. See §0.1 |

Do not "fix" the asymmetry between these. It is intentional and visible.

The closing-prayer and thanksgiving cards were previously expressed as
`showContainer: !isStRitaNovena` **inside** the text view. Because the parameter
is now gone, they were moved to an explicit `AppCard` wrapper at the call site
with the same `radius: AppSpacing.radiusXl` and `padding: EdgeInsets.all(AppSpacing.xl)`.
The resulting widget tree is identical, so rendering is unchanged.

---

## 0.2 Verification policy

**The agent does not run the app and does not produce builds.** No APK, no debug build, no release build, no AAB, no IPA, no install, no launch.

### The only commands run at a gate

| # | Command | Purpose |
| --- | --- | --- |
| 1 | `flutter analyze` | Must report zero issues |
| 2 | `flutter test test/unit` | Unit tests — 7 files, 30 tests |
| 3 | `flutter test test/widget` | Widget tests — 3 files |
| 4 | `dart run tools/validate_content.dart` | Content validator must pass |

These run only at a part's acceptance gate, not continuously. `flutter test` executes on the host Dart VM and produces no app build, so it is within policy.

### Test inventory, verified 2026-09-27

| Directory | Files | Names |
| --- | --- | --- |
| `test/unit` | 8 | `app_theme_test`, `content_loader_repository_test`, `content_validation_test`, `deep_link_service_test`, `home_widget_service_test`, `search_rosary_novena_test`, plus `unused_dependencies_test` added in Part 1, and `part2_optimizations_test` added in Part 2 |
| `test/widget` | 3 | `onboarding_routing_test`, `prayer_text_unboxed_test` (added in Part 1), `today_novena_localization_test` |
| `integration_test` | 3 | `app_startup_test`, `novena_progress_test`, `offline_prayer_flow_test` |

Measured during Part 2 on 2026-09-29: `test/unit` holds 8 files and
`flutter test test/unit` runs 51 tests. `flutter test test/widget` runs 10 tests
across the 3 widget files.

A root-level `test/widget_test.dart` also exists and is **not** covered by either
gate command. It is inventoried in [Out of gate](#out-of-gate) below.

### Resolved in Part 2 — the real-asset loading failure

`test/widget/today_novena_localization_test.dart` and
`test/widget/onboarding_routing_test.dart` both used to fail with
`Expected requested widget to appear`. **Fixed in Part 2.**

An earlier revision of this plan recorded the cause as "`rootBundle` never
responds under `flutter test`, proven by a bare `loadString` hanging past 300s".
**That diagnosis was wrong and has been replaced.** What was actually measured,
each step in isolation:

| Probe | Result |
| --- | --- |
| `rootBundle.loadString` in a plain `test()` | Works. Manifest is 2,257 bytes; 40 assets visible |
| `rootBundle.loadString` awaited inside `testWidgets` | **Hangs** |
| One `loadString` in `testWidgets`, pumped, not awaited | Completes |
| Five sequential `loadString` calls, pumped | Never settles |
| `getPrayers` in a plain `test()`, sync bundle | **36 prayers** |
| `getPrayers` in `testWidgets`, bundle returning `Future.value` | Never settles |
| `getPrayers` in `testWidgets`, bundle returning `SynchronousFuture` | **36 prayers** |

The real cause is narrower and different: `LocalContentDataSource` reads several
files in sequence, and under `testWidgets`' fake-async zone that multi-file chain
does not settle when each read is a normal asynchronous future. The
single-file cases that appeared to "prove" the channel was dead were the ones
that did complete.

The fix is `test/helpers/test_asset_bundle.dart`, the shared `TestAssetBundle`
this plan earlier suggested. It reads the real `assets/content` JSON
synchronously from disk and returns `SynchronousFuture`, which settles inside
the fake-async zone. It is injected by overriding
`localContentDataSourceProvider`, which feeds prayers, categories, novenas and
rosary — so one override covers every content-backed provider.

**No production code was changed to achieve this.** The tests still exercise the
real bundled content, so the previously untested real-asset path is now covered
rather than mocked away.

### Explicitly excluded

| Excluded | Reason |
| --- | --- |
| `flutter run`, `flutter build apk`, `flutter build appbundle`, `flutter build ipa` | Produces or launches a build |
| `integration_test/*` (3 files) | Requires a connected device or emulator |
| First-frame, scroll-jank, and memory timing | Requires a running app |
| Screenshot / visual diff comparison | Requires a rendered app |
| Re-measuring the release AAB | Requires a build |
| Play Console download-size check | Requires a store account and a published build |

### Consequence: two verification classes

Every acceptance criterion in Parts 2–7 is labelled:

- **AGENT** — proven by the four gate commands. Can be claimed complete autonomously.
- **OWNER** — requires a build or a device. Handed over as a checklist. **Cannot be marked done by the agent and must not be reported as done.**

The §1 baseline was captured by reading the already-present `build/` artifacts. That is a file read, not a build, so it stands as a recorded measurement. Any *fresh* size or timing figure is OWNER work.

**Rule: a part is not complete until its AGENT items pass. Its OWNER items are handed over explicitly and reported as outstanding — never quietly assumed.**

---

## 1. Measured baseline

Measured on 2026-09-27 from `build/app/outputs/bundle/release/app-release.aab` (44,949,806 bytes on disk; 114.5 MB uncompressed across 461 entries).

### 1.1 What is in the AAB

| Group | Raw | Shipped to users? |
| --- | --- | --- |
| `BUNDLE-METADATA/` (debug symbols, R8 map) | 55.6 MB | **No** — Play Console symbolication only |
| `base/lib/x86_64/` | 18.2 MB | No — emulator ABI, split out |
| `base/lib/arm64-v8a/` | 16.9 MB | Yes — ~99% of real devices |
| `base/lib/armeabi-v7a/` | 14.5 MB | Yes — old 32-bit devices |
| `base/dex/` | 1.44 MB | Yes |
| `base/assets/flutter_assets/` | 1.64 MB | Yes |
| `base/res/`, `resources.pb`, `root/`, `manifest` | ~0.9 MB | Yes |

The 43 MB figure people usually quote is the **AAB container size**, which includes all three ABIs plus 55.6 MB of debug symbols. It is not what a user downloads.

### 1.2 What one device actually receives (arm64-v8a)

Reproduce with `dart run tool/size_report.dart build/app/outputs/bundle/release/app-release.aab`.
Figures below are exact, read from the bundle's ZIP central directory.

| Component | Uncompressed | Transfer |
| --- | --- | --- |
| `libflutter.so` (Flutter engine) | 10,848 KB | 5,130 KB |
| `libapp.so` (this app's Dart AOT code) | 6,337 KB | 2,427 KB |
| `libdartjni.so` + other native | 129 KB | 26 KB |
| **native libraries subtotal** | **17,313 KB** | **7,583 KB** |
| `dex` (classes.dex + classes2.dex) | 1,473 KB | 664 KB |
| `flutter_assets` — `logo.png` | 1,071 KB | 1,071 KB |
| `flutter_assets` — `assets/content/**.json` (38 files) | 434 KB | 87 KB |
| `flutter_assets` — `NOTICES.Z` | 124 KB | 123 KB |
| `flutter_assets` — fonts, shaders, manifests | 55 KB | 16 KB |
| `res/*` + `resources.pb` + `root/*` + manifest | 765 KB + 91 KB | 396 KB + 25 KB |

Note the logo: 1,071 KB uncompressed and 1,071 KB transferred. Deflating a PNG
gains nothing — it is already compressed. **The logo is 67% of everything this
project can actually shrink.**

### The three numbers that matter

An earlier draft of this plan claimed a "Basis A" of 21.3 MB. **That was wrong.**
It was the fully-uncompressed sum, which is not what any device holds.

Every entry in the AAB is deflated — `unzip -v` confirms `Defl:N` throughout,
including the native libraries. Play re-compresses when it generates the split
APK, so the on-device figure **cannot be measured from the bundle**. It can only
be derived, and it must be labelled as a derivation.

| Measure | Value | Status |
| --- | --- | --- |
| **Transfer size** — what the user downloads | **9.73 MB** | **Exact**, from the bundle |
| **On-device size** — split APK held on the phone | **~19.2 MB** | **Derived**, not measured |
| **Floor** — native libraries alone, uncompressed | **16.91 MB** | **Hard bound** |
| **Addressable** — compressible ABI-independent content | **1.59 MB** | **Derived** |

The on-device derivation: native libraries are stored uncompressed so the loader
can mmap them (16.91 MB), and everything else transfers at its compressed size
(2.33 MB). 16.91 + 2.33 = 19.24 MB.

**Confirm the on-device figure from an installed split APK, not from the AAB.
That check is OWNER work.**

### 1.3 Source-level baseline

| Metric | Measured |
| --- | --- |
| Dart files / lines | 74 / 11,167 |
| Bundled JSON | 445 KB (prayers 82 KB + novenas 130 KB + rosary 5 KB per language pair) |
| Prayer records | 36 per language |
| Eager `children: [...]` lists | 108 |
| `ListView.builder` / `itemBuilder` uses | **0** |
| `operator ==` / `hashCode` overrides | **0** |
| `cacheWidth` on images | **0** (1 image in the app) |
| Declared-but-unimported packages | **0** — the 3 were removed in Part 1.5 |
| Duplicated i18n string classes | 18 |
| Startup JSON decoded on the UI isolate | ~215 KB (prayers + novenas) |

---

## 2. Answer: how small will the download get?

**Short answer: about 8.5 MB transferred and about 18 MB on-device, against a hard floor of 16.91 MB. A 10 MB *stored* APK is impossible, and a 10 MB download is only just reachable today with almost no headroom — it should not be treated as a reliable target.**

The earlier "Basis A / Basis B" framing in this plan was misleading and has been
replaced. See §1.2 for why the on-device figure is a derivation rather than a
measurement, and for the numbers that are exact.

### 2.1 Why a 10 MB stored APK is unreachable

The arm64 native libraries are **17,313 KB (16.91 MB) uncompressed**, and
`libflutter.so` alone is **10,848 KB (10.6 MB)**. Both are compiled by Google,
not by this project, and no code change in this repository affects them.

- The native libraries are stored uncompressed on-device so they can be
  memory-mapped, so **16.91 MB is a mathematical floor** for any Flutter app on
  this engine version.
- Transferred, the engine compresses to roughly half and the total lands at
  9.73 MB — just under 10 MB, with almost no headroom. Adding content, a plugin,
  or a dependency pushes it over.

### 2.2 What the optimization work actually saves

Only 1.59 MB of the shipped payload is compressible content that this project
controls. Everything else is the engine and the AOT snapshot.

| Change | Transfer saving | Certainty |
| --- | --- | --- |
| Logo 1254×1254 PNG → ~192 px WebP | **~1,040 KB** | High — the PNG is 1,071 KB raw and 1,071 KB transferred, so deflating it gains nothing |
| Drop 3 unused packages — **done in Part 1.5** | ~30–40 KB (dex) + small AOT effect | Medium |
| Remove dead code / consolidate 18 i18n classes (smaller `libapp.so`) | ~100–200 KB | Low–medium, not linear |
| Drop `x86_64` ABI from the bundle | **0 KB to users** | Certain — affects AAB size only, not per-device |
| **Total realistic saving** | **~1.2–1.3 MB (≈13% of transfer)** | |

The logo alone is two thirds of this. Every other asset in the app combined is
under 120 KB transferred.

### 2.3 Projected result

| Measure | Now | After all parts | Saving | Floor |
| --- | --- | --- | --- | --- |
| Transfer — what the user downloads (exact) | 9.73 MB | ~8.5 MB | ~1.2 MB | — |
| On-device — split APK (derived) | ~19.2 MB | ~18.0 MB | ~1.2 MB | **16.91 MB** |
| AAB container (all 3 ABIs + symbols) | 42.87 MB | ~40 MB | ~2.9 MB | — |

The 16.91 MB floor is the native libraries alone, fully uncompressed. It is set
by the Flutter engine version and **no change in this repository can go below
it.** The logo work moves the on-device figure from 19.2 to 18.0 MB, which is
about 65% of the way from the current figure to the floor.

### 2.4 The decision this forces

The optimization work makes the app meaningfully faster and lighter, but **it will not make the download dramatically smaller**, because ~85% of the shipped bytes are the Flutter engine and the Dart AOT snapshot — neither of which shrinks much.

If a sub-10 MB figure is a hard business constraint rather than a current measurement, the options are:

1. **Accept ~8.5 MB transfer / ~18 MB on-device** and proceed with this plan. The app is already lean for Flutter.
2. **Re-check the actual constraint.** Play's bundle limits and the "compressed download size" metric in Play Console should be confirmed against current policy rather than a remembered 10 MB figure, and the real number read from Play Console for an internal-test track.
3. **Change framework** — only if a sub-10 MB *stored* APK is genuinely mandatory. No amount of Dart-level optimization reaches it, because the engine floor alone is 16.91 MB.

**Recommendation:** proceed with this plan for the performance and quality gains, and confirm the real store limit from Play Console before treating 10 MB as a constraint. Part 1 item 1.6 records that figure, and it is an **OWNER** item (§0.2) because it needs a published build and a store account.

---

## 3. Answer: what changes in data and visual layout?

### 3.1 Data — no change

| Item | Effect |
| --- | --- |
| All 41 JSON content files | **Unchanged, byte for byte** |
| `content_manifest.json` structure | **Unchanged** |
| `pubspec.yaml` asset declarations | Unchanged |
| SharedPreferences keys and stored value formats | Unchanged — no migration, no data loss |
| Deep-link URL → route mapping | Unchanged (`APP_INDEXES.md` stays valid) |

There is **no data migration and no content re-authoring** in this work.

### 3.2 Visual layout — no intended change

Every part below is internal. The only items that could plausibly alter appearance, and how each is controlled:

| Risk | Control |
| --- | --- |
| New smaller logo could look soft at 72 px | 192 px source is still 2.6× oversampled for a 72 px box. Verify side-by-side on a real device at 1x/2x/3x before accepting. |
| List virtualization could shift scroll position | Preserve `initialScrollOffset` and padding; verify first-frame content is identical. |
| Removing `x86_64` | Emulator only. No user-visible change. |
| Dropping 3 unused packages | No visual change — they were never imported. |
| Bottom-nav `go()` → state-preserving navigation | **This is an intentional behaviour change** (tab switches keep scroll position). It is a UX improvement, but it must be called out in release notes, not slipped in silently. See Part 5, item 5.4. |

**Acceptance gate for every part:** screenshot the affected screens before and after at matched device sizes and confirm no pixel differences beyond the intended navigation-state change.

### 3.3 Content-authoring flexibility — this is a first-class goal

The audit found that **adding a prayer or novena today requires editing Dart code in several places.** That is the biggest structural risk in the project and it is addressed as its own part (Part 6), not as cleanup.

Confirmed gaps, with evidence:

| # | Gap | Evidence |
| --- | --- | --- |
| F1 | **Litany styling is a hardcoded 18-element ID list in Dart.** Adding a litany means editing `prayer_detail_screen.dart`. | `prayer_detail_screen.dart:147-166` |
| F2 | **Novena day count is hardcoded in Dart in three places.** The JSON already contains the days array; the count is duplicated as `st_rita_novena ? 12 : 9`. These can silently drift apart. | `novena_providers.dart:308`, `today_providers.dart:36`, `today_providers.dart:82` |
| F3 | **Novena style flags enumerate all 9 novena IDs in Dart.** Adding a 10th novena silently changes rendering. `allSaintsStyle` is currently `true` for every existing novena — 9 string comparisons per build to compute a constant. | `novena_day_screen.dart:148-159` |
| F4 | **Prayer JSON carries no style field.** Verified: keys are `body, category, description, id, is_offline_available, language, last_updated, show_title, source, tags, title, type, version`. There is nowhere in content to declare how a prayer should render. | `assets/content/prayers/**/*.json` |
| F5 | **The app loads file paths from the manifest, but the validator discovers files from disk.** Nothing checks the two agree. Adding a `.json` file without editing the manifest means the app silently never loads it — no error, no warning. | `local_content_datasource.dart:41-44` vs `tools/validate_content.dart:55-58` |
| F6 | **The manifest is hand-maintained in two languages** (9 novena paths × 2, 6 prayer paths × 2, 2 rosary paths × 2). One omission is a silent content failure. | `assets/content/metadata/content_manifest.json` |
| F7 | **A manifest generator was designed but never built.** `tool/` is empty; `folder_structure.md:147` references `generate_content_manifest.dart`. | `docs/architecture/folder_structure.md:147` |
| F8 | **No EN/SW ID parity check.** The `divine_mercy_eternal_father` / `divine_mercy_prayer` mismatch in `APP_INDEXES.md` Note A is exactly this gap, still open. | `tools/validate_content.dart` (no parity check present) |
| F9 | **Text styling is matched by literal string prefixes in 3 languages.** A content author rephrasing `"In the name of the Father..."` silently loses formatting. | `novena_text_view.dart:280-284, 480-519`, `litany_text_view.dart:154-195`, `prayer_text_view.dart:145-182` |

**Target state:** a content author adds a prayer by creating one JSON file per language and running one command. No Dart file is touched. Anything the app needs to know about a prayer's *presentation* lives in that prayer's JSON.

---

## 4. Answer: how dead code is handled

Dead code is classified into five buckets with different rules, so nothing is deleted on a guess.

| Bucket | Rule | Items |
| --- | --- | --- |
| **A — Delete** | Unambiguously unreachable. Delete outright. | **DONE in Part 1.5** — `easy_localization`, `intl`, `cupertino_icons` removed; `flutter pub get` dropped 5 dependencies. **Still open:** `assets/translations/` (contains only `.gitkeep`); `AssetPaths.icons` and `AssetPaths.illustrations` (directories do not exist); the redundant `Ink` inside `PrayerCard`'s `AppCard` (`prayer_card.dart:26`); the unused `matchedPrayers` path if Part 4 removes it |
| **B — Replace with a constant** | Logic that computes a value that is always the same. | `allSaintsStyle` ORing 9 IDs that cover all 9 novenas (`novena_day_screen.dart:148-157`); the non-const 18-element `Set<String>` allocated every build (`prayer_detail_screen.dart:147-166`) |
| **C — Wire up or drop** | Parsed but unused, or planned but unbuilt. Decide explicitly, do not leave ambiguous. | `ContentManifestModel.rosaryPaths` is parsed (`content_manifest_model.dart:22`) but the datasource hardcodes rosary paths instead (`local_content_datasource.dart:81, 91`); `tool/generate_content_manifest.dart` is specified in docs but does not exist |
| **D — Repair, keep** | Looks like dead code but is load-bearing or is a correctness bug. Fix the API, do not delete. | `PrayerEntity.title(lang)` / `text(lang)` silently ignore their `lang` argument (`prayer_entity.dart:36-42`) — misleading, and a trap for anyone adding multi-language content; `_maxDaysForNovena` (`novena_providers.dart:308`) — dead-looking but authoritative, and it is the F2 drift risk |
| **E — Do not touch** | Belongs to SEO, release, or build infrastructure. Out of scope. | `deep_link_service.dart` slug maps and `prayerIdAliases`; the 55.6 MB `BUNDLE-METADATA` symbols (a build artifact, not shipped); `docs/`, `test/`, `integration_test/` |

**Rules that apply to all buckets:**

1. Nothing in bucket E is deleted, even though `prayerIdAliases` and the slug maps look like dead strings — they are consumed by App Indexing.
2. Every bucket A deletion is confirmed by a whole-project grep first, recorded in the part's evidence.
3. `flutter analyze` must stay clean after each part. Any newly-unused private member is itself a bucket A item and is removed in the same part, so dead code cannot accumulate between parts.
4. A part that creates dead code is not finished.

---

## 5. Optimization parts

Seven parts, sequenced by risk-adjusted value. Parts 1–3 are the highest value per unit of effort. Part 6 is sequenced late deliberately: it changes content schema, so it runs after the perf work is proven so that a schema problem cannot be blamed on a perf regression.

### Status tracker

| Part | Name | Goal | Effort | Status |
| --- | --- | --- | --- | --- |
| 1 | Baseline + gate harness | Lock the measurement baseline and the fixed verification commands | Low | **AGENT complete** — OWNER items 1.6–1.9 outstanding |
| 2 | Cheap, zero-risk wins | Immediate size + CPU reduction, no behaviour change | Low | Code complete, gates green; OWNER device checks outstanding |
| 3 | Data layer: stop re-parsing everything | Eliminate redundant IO and decode | Medium | Not started |
| 4 | Text rendering hot path | Remove per-line regex and string churn | Medium | Not started |
| 5 | Startup, rebuild scope, and responsiveness | Cut first-frame work and over-rebuilding | Medium | Not started |
| 6 | Content-authoring flexibility | Add content without touching Dart | Medium–High | Not started |
| 7 | Dead-code sweep + owner handover | Leave no dead code; list what needs a device | Low | Not started |

**Gate for every part:** the four commands in §0.2. **Invariants re-checked at every gate:** §0.1 (prayers never boxed) and the §4 dead-code policy.

---

### Part 1 — Establish the size baseline and the gate harness

**Goal:** lock down the measurement baseline and the verification commands before any change is made, so later claims are comparable and every later part has a fixed gate.

The §1 baseline is already recorded from the pre-existing `build/` artifacts. This part confirms it and builds the reusable harness. **No build is produced** — see §0.2.

| ID | Task | Class | Status |
| --- | --- | --- | --- |
| 1.1 | Confirm the §1.1–§1.3 figures against the current AAB | AGENT | **Done.** Figures reproduce. The on-device figure was found to be underivable from the AAB and is now labelled a derivation — see §1.2 |
| 1.2 | Add `tool/size_report.dart` printing the §1.2 table from an existing AAB path | AGENT | **Done.** Reads the ZIP central directory, decompresses nothing, builds nothing. No-arg mode reports source `assets/` |
| 1.3 | Record the four gate commands in a single documented place | AGENT | **Done.** §0.2 |
| 1.4 | Guard the §0.1 invariant automatically | AGENT | **Done, and stronger than specified.** `showContainer` was removed from `NovenaTextView` and `LitanyTextView` and the card moved to the two call sites that legitimately show one. The text views can no longer be boxed at all, enforced by the compiler. 8 tests in `test/widget/prayer_text_unboxed_test.dart` |
| 1.5 | Guard against the three unused packages reappearing | AGENT | **Done.** All three removed from `pubspec.yaml`; `flutter pub get` dropped 5 dependencies. 2 tests in `test/unit/unused_dependencies_test.dart` |
| 1.6 | Read the actual compressed download size from Play Console, internal-test track | **OWNER** | Outstanding — §2 now has a derived 9.73 MB to compare against |
| 1.7 | Record first-frame timing, debug and profile | **OWNER** | Outstanding |
| 1.8 | Record scroll-jank timings for the heaviest litany and heaviest novena day | **OWNER** | Outstanding |
| 1.9 | Record peak memory on a low-end device | **OWNER** | Outstanding |

**Acceptance:** met. §1 figures reproduce, the size report prints, both invariant guards exist and pass, and the four gate commands are documented once.

**Verification (AGENT) — run 2026-09-27:**

| Gate | Result |
| --- | --- |
| `flutter analyze` | **No issues found** |
| `flutter test test/unit` | **30/30 pass** |
| `flutter test test/widget` | 8/8 new tests pass. 2 pre-existing failures in `today_novena_localization_test.dart`, diagnosed in §0.2 and unrelated |
| `dart run tools/validate_content.dart` | **passed** |

**Verification (OWNER):** items 1.6–1.9 handed over as a checklist in §9.

**Files changed in Part 1:**

| File | Change |
| --- | --- |
| `lib/shared/widgets/novena_text_view.dart` | `showContainer` and the `AppCard` branch removed; `app_card.dart` import dropped |
| `lib/shared/widgets/litany_text_view.dart` | Same |
| `lib/features/novenas/presentation/screens/novena_thanksgiving_screen.dart` | `AppCard` wrapper added at the call site for non-`st_rita` |
| `lib/features/novenas/presentation/screens/novena_closing_prayer_screen.dart` | Same, for `LitanyTextView` |
| `lib/features/novenas/presentation/screens/novena_day_screen.dart` | `showContainer: false` argument removed |
| `lib/features/prayers/presentation/screens/prayer_detail_screen.dart` | `showContainer: false` argument removed |
| `lib/features/rosary/presentation/screens/rosary_step_screen.dart` | `showContainer: false` argument removed |
| `pubspec.yaml`, `pubspec.lock` | `cupertino_icons`, `intl`, `easy_localization` removed |
| `tool/size_report.dart` | New |
| `test/widget/prayer_text_unboxed_test.dart` | New, 8 tests |
| `test/unit/unused_dependencies_test.dart` | New, 2 tests |

**Risk:** none to product behaviour. The only behavioural change is the removal of
three packages that nothing imported, and the relocation of two cards that
produces an identical widget tree. Rendering is unverified on a device — that is
OWNER item 1.7 territory and must be confirmed before shipping.

---

### Part 2 — Cheap, zero-risk wins

**Goal:** bank the easy size and CPU savings with no behavioural risk. These are the items where the measured payoff is largest relative to effort.

| ID | Task | Target | File |
| --- | --- | --- | --- |
| 2.1 | Replace the oversized logo | 1254×1254 RGB PNG, 1.1 MB → ~192 px, ~10 KB | `assets/images/logo/logo.png` |
| 2.2 | Add `cacheWidth` to the logo image | 6.3 MB decoded RGBA bitmap → ~60 KB | `sala_logo_mark.dart:32-36` |
| 2.3 | Convert `AppTheme.light` / `AppTheme.dark` from getters to `static final` | Stop rebuilding two full `ThemeData`s on every `build()` | `app_theme.dart:31,53`; called at `app.dart:124-125` |
| 2.4 | `timezone`: `latest_all.dart` → `latest.dart`, or `initializeTimeZoneSpecificLocations` | Stop loading the whole IANA database for one timezone | `notification_service.dart:2,148` |
| 2.5 | Remove `easy_localization`, `intl`, `cupertino_icons` | 3 unused packages; also drops `assets/translations/` | `pubspec.yaml:20,23` |
| 2.6 | Move the `record()` side effect out of `build()` | Stop a SharedPreferences platform write on every rebuild | `prayer_detail_screen.dart:59-61` |
| 2.7 | Batch the home-widget writes with `Future.wait`; skip when unchanged | 5 sequential platform calls → 1 batch, only on real change | `home_widget_service.dart:26-33` |
| 2.8 | Make the 18-element litany set `static const` | Stop allocating a `Set<String>` per build | `prayer_detail_screen.dart:147-166` |

**Expected result:** ~1.03 MB download saving, ~6 MB less image memory, one full `ThemeData` pair per rebuild removed, a few hundred KB of tzdata.

**Acceptance:** `flutter analyze` clean; all 36 prayers and 9 novenas render identically; reminder scheduling still works; home-screen widget still updates; **no prayer reading view gains a card** (§0.1).

**Verification (AGENT):**

- 2.1 — assert the new logo file is under 30 KB; assert the §1.2 asset table drops by ~1.03 MB
- 2.2 — assert `cacheWidth` is present in `sala_logo_mark.dart`
- 2.3 — assert `AppTheme.light` / `.dark` are `static final`, not getters
- 2.5 — the Part 1.5 guard test passes; `pubspec.yaml` has no unused packages
- 2.6 — assert no `addPostFrameCallback` inside a `build()` method body
- 2.7 — assert the home-widget writes are batched
- All four gate commands pass. Measured 2026-09-29: `flutter analyze` clean;
  `test/unit` 51/51; `test/widget` 10/10; content validator passed.

#### Part 2 outcome

All eight items are implemented. Gate results, measured 2026-09-29:

| Command | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test test/unit` | 51/51 passed |
| `flutter test test/widget` | 10/10 passed |
| `dart run tools/validate_content.dart` | Content validation passed |

**§0.1 holds:** `prayer_text_unboxed_test` is 7/7 green, so no prayer reading
view gained a card.

**One deliberate deviation from the plan, item 2.4.** The plan called for
`latest_all.dart` → `latest.dart`. The implementation keeps `latest_all.dart` and
maps the device's UTC offset to a named zone instead. `latest.dart` ships neither
`Africa/Dar_es_Salaam` nor UTC, so it cannot express the app's primary market.
`part2_optimizations_test.dart` pins this: it asserts `latest_all.dart` is still
imported, that the reduced dataset is *not*, and that every mapped zone resolves
and observes no daylight saving. Verified zones: `Africa/Nairobi` (UTC+3),
`Asia/Dubai` (UTC+4), plus UTC+1 and UTC+2 entries.

**Two of this plan's own Part 2 test guards were wrong and were corrected.**
Both lived in `part2_optimizations_test.dart` and both failed against correct
production code:

- The 2.6 guard forbade `addPostFrameCallback` in the whole file, but the
  one-time helper at `prayer_detail_screen.dart:63-75` is *supposed* to contain
  it. It now asserts the callback appears exactly once and that it sits between
  the helper and `build()` — the property the plan actually asked for.
- The 2.6 guard matched the literal `if (!mounted) return`, which `dart format`
  rewrites across three lines. It now matches `if (!mounted)`, which is the
  substantive check.

**Content files were not modified.** `git status` shows changes only under
`test/` and this plan.

#### Out of gate

`test/widget_test.dart` is a root-level suite that neither `test/unit` nor
`test/widget` picks up, so it is outside the gate by construction. It has 7
tests: 4 pass, 3 fail. All three failures are pre-existing and unrelated to Part
2 — they are `AboutScreen` expectations and one off-screen tap, not content
loading, and not code this part touched:

| Test | Failure |
| --- | --- |
| `opens offline prayer library and detail` | Taps a target at `Offset(400, 613)`, outside the 800x600 surface |
| `shows active novena and marks current day complete` | `_pumpUntilFound` on `'Day 2'` |
| `persists settings and shows about content` | `_pumpUntilFound` on `'Busara Digital'` |

The last one expects `find.text('Busara Digital')`, but the screen only ever
renders that phrase inside longer sentences, so an exact-match finder cannot hit
it; it also expects `CONTENT SOURCES` and `DISCLAIMER`, which appear nowhere in
`about_screen.dart`. These are stale test expectations, not Part 2 regressions.
Fixing them is a separate decision and was left alone.

**Verification (OWNER):**

- 2.1 — logo looks identical to the previous one on a real device at 1x, 2x, and 3x density. **This is the one item in Part 2 that cannot be proven without a device, and it is the highest-risk item here.**
- 2.4 — set a reminder, confirm it fires at the right time
- 2.7 — update the home-screen widget, confirm it redraws with correct content

**Risk:** low, except 2.1. 2.5 requires grepping `lib/`, `test/`, `integration_test/`, and `tool/` before removal — a test importing one of them would break the build.

---

### Part 3 — Data layer: stop re-parsing everything

**Goal:** every prayer/novena/rosary read is served from memory after the first load. This is the single largest CPU and IO win.

| ID | Task | Target | File |
| --- | --- | --- | --- |
| 3.1 | `prayerByIdProvider` reads from `prayersProvider.future` + an id→entity index instead of the repository | Removes a full corpus reload on every prayer detail open | `prayer_providers.dart:54-62`; `prayer_repository_impl.dart:20-31` |
| 3.2 | Memoize manifest and categories in `LocalContentDataSource` | Manifest is currently re-read and re-decoded on every call; `getPrayers` triggers it twice | `local_content_datasource.dart:18-21,23-33,35-61` |
| 3.3 | Build a language-keyed cache for prayers, novenas, rosary | One parse per language per session, not one per screen open | `local_content_datasource.dart:35-98` |
| 3.4 | ~~Move `jsonDecode` off the UI isolate~~ — **rejected, see note below** | Measured as a net loss, so the parse stays inline | `local_content_datasource.dart` |
| 3.5 | Stop parsing novena day bodies for list views | 130 KB parsed and held to render 9 titles | `novena_model.dart:47-51` |
| 3.6 | Reuse the same cache in `deepLinkContextProvider` | Stops parsing a second full copy when the active language is English | `deep_link_providers.dart:14-23` |

**Note on 3.1:** novenas and rosary already use the correct cached pattern (`novena_providers.dart:25-36`). Part 3 makes prayers consistent with them rather than inventing a new approach.

**Note on 3.4 (measured deviation):** the isolate hand-off was implemented, then measured, then removed. Decoding cost on this project:

| Target | Bytes | Time |
| --- | --- | --- |
| All English prayers (6 files) | 84,335 | 3.02 ms |
| All English novenas (9 files) | 135,613 | 2.90 ms |
| Everything loaded on first frame | ~215,000 | **3.35 ms** |
| `compute` spawn + round trip | — | **8–9 ms** |

The parse it replaces costs about a third of what the isolate costs to start, and that cost is paid on the critical path. A second, independent reason: `compute` issued from `testWidgets` **never completes** — the isolate cannot be spun up under the fake-async zone, so the change made the widget suite hang rather than speed anything up. The parse stays inline; the real win in this part is 3.1–3.3 removing the repeated reads, not 3.4 removing one parse.

**Note on 3.5 (partial):** day bodies are now read from the retained source map only when a body is actually accessed, rather than being copied into an eagerly built model. This is the cheap half of the idea and is verified by test. The half that would actually reclaim the ~120 KB — never holding the bodies at all for list views — needs the corpus split into summary and detail files, which is a content-schema change and belongs to Part 6, not here.

**Acceptance:** opening all 36 prayer screens performs zero additional asset reads; the deep-link resolver performs no reads already satisfied by the cache; all content renders identically; **no prayer reading view gains a card** (§0.1).

**Verification (AGENT):**

- [x] A unit test asserts each asset file is read **exactly once per language** across a full navigation sweep, and that 36 reads of `prayerById` trigger zero additional reads. This replaces manual read-count instrumentation, which would have needed a running app. Measured: **8 reads** for the initial English corpus and **0 additional** reads across all 36 by-id lookups, down from 9 + 45.
- [x] The manifest is decoded once, not once per call (1 read for 3 calls; categories likewise 1 for 2).
- [~] `jsonDecode` no longer runs on the UI isolate — **not applicable**, see 3.4 above.
- [x] Novena list views no longer construct day bodies eagerly; day, closing-prayer, and thanksgiving screens still read the same text.
- [x] Existing `content_loader_repository_test.dart` and `search_rosary_novena_test.dart` pass unchanged.
- [x] All four gate commands pass, and the full `flutter test` suite is green at 68/68 (this also retired the three out-of-gate failures Part 2 had recorded).

**Verification (OWNER):**

- [ ] Open every one of the 36 prayers and all 9 novenas × all days on a device; content renders correctly
- [ ] First-frame timing compared against the Part 1.7 baseline
- [ ] Confirm novena day bodies, closing prayers, and thanksgivings are intact on device — 3.5 changed when those strings are read

**Risk:** medium — this is the core data path, and it is the part where an AGENT-only proof is weakest, because a caching bug can pass unit tests yet show stale content. 3.5 changes when novena day bodies load, so novena day, closing-prayer, and thanksgiving screens all need OWNER checking.

---

### Part 4 — Text rendering hot path

**Goal:** the app's largest CPU consumer stops rebuilding regexes per line and re-scanning strings on every frame.

| ID | Task | Target | File |
| --- | --- | --- | --- |
| 4.1 | Hoist every `RegExp` to a `static final` field | Removes ~800 RegExp compilations per litany build | `prayer_text_view.dart:79,173,177`; `novena_text_view.dart:204,229,245,298,457-465`; `litany_text_view.dart:186` |
| 4.2 | Gate expensive checks behind cheap `startsWith`/`contains` | `_splitHeading` currently tries 7 regexes per paragraph *before* the cheap check that rejects plain text | `novena_text_view.dart:365-367,456-478` |
| 4.3 | Compute each string's normalized form once per value | Removes ~1,400 string allocations per litany build | `prayer_text_view.dart:146-152`; `litany_text_view.dart:68-75,154-168` |
| 4.4 | Cache the `split` of the body | `split(RegExp(...))` currently re-runs on the whole body every build | `novena_text_view.dart:29-33`; `litany_text_view.dart:23-27` |
| 4.5 | Isolate the A-/A/A+ text scale into a `ValueNotifier` scoped to the text subtree | Tapping A+ no longer re-runs the whole screen | `prayer_detail_screen.dart:231-253`; `novena_day_screen.dart:236-256` |
| 4.6 | Virtualize the text views | 200+ litany lines currently lay out in one pass; 108 eager lists, 0 builders | `litany_text_view.dart:29-41`; `novena_text_view.dart:35-53` |
| 4.7 | Precompute a lowercased search index once per language; debounce search input | Currently lowercases 82 KB of prayer bodies per keystroke, inside `build()` | `prayer_library_screen.dart:63-79,102`; `prayer_entity.dart:75-77` |
| 4.8 | Make the litany/novena/response styling rules data-driven | Removes the last hardcoded ID lists; needed for Part 6 | see Part 6 |

**Expected result:** a full litany render should drop from ~800 regex compilations + ~1,400 allocations to a single memoized parse. A+ becomes local instead of a full-screen rebuild.

**Acceptance:** every prayer, litany, and novena day renders pixel-identically — this part carries the highest risk of subtle visual change because the formatting heuristics are intricate. Search results are identical and in identical order. **No prayer reading view gains a card or loses its current card-free layout** (§0.1).

**Verification (AGENT):**

- Assert a fixed set of queries returns the same ordered result IDs as before the change, pinned as literal goldens so a change to the *sort* is caught and not only a change to `score`. This is the check that matters most, and it is fully testable. → `part4_search_index_test.dart`
- Assert every `RegExp` in the three text views is a `static final` field, not constructed inside a build path. → `part4_render_cache_test.dart`
- Assert the A-/A/A+ scale is driven by a `ValueNotifier` scoped to the text subtree, so it no longer triggers a full-screen rebuild. → `part4_render_cache_test.dart`
- Assert the heading split is still gated behind a cheap prefix check, so the 7 anchored regexes do not run for every paragraph. → `part4_render_cache_test.dart`
- ~~Assert the text views emit builder-based children rather than an eager `children:` list.~~ **Dropped:** this was 4.6, which was skipped on measurement. Asserting it would require the virtualization that was declined.
- Assert the search index is precomputed per language and that input is debounced. → `part4_search_index_test.dart`
- Assert the formatting rules still classify a known set of sample lines identically — intentions, invocations, headings, response lines, prayer counts, request placeholders. **This is what protects the intricate heuristics from regressing without needing a screenshot.** → `part4_style_rules_test.dart` (corpus parity against the pre-4.8 literals) and `part4_text_classification_test.dart` (per-view rendered output).
- Every rule list is pinned by exact literal, and is checked for duplicates and for surrounding whitespace.
- Both directions of the intention classifier are asserted *through the widget*: a marker mid-sentence must not be italicised, and the `hapa)` markers after a lead-in still must be. Comparing rule data against the old literals is not sufficient here — a single merged `contains` list reproduces every shipped line while being strictly broader, so only a rendered-output test catches it.
- All four gate commands pass.

**Verification (OWNER):**

- Screenshot-diff all 36 prayers and all 9 novenas × all days, in both languages. **Mandatory** — 4.6 and 4.7 can pass every test above and still shift layout.
- Confirm litany scroll is smoother against the Part 1.8 baseline
- Confirm the A+/A− control still feels immediate

**Risk:** medium-high for 4.6 and 4.7 (layout and behaviour), low for 4.1–4.5. The AGENT tests cover classification logic; they do not cover layout. The OWNER screenshot pass is the only thing that does, so it cannot be skipped.

#### Status: 4.1–4.5 and 4.7 done, 4.6 skipped on measurement, 4.8 done

4.7 is done. It changes no layout: the search field keeps updating on every keystroke, and only the 36-prayer re-scoring is deferred by 250 ms. Its result set is provably unchanged — see the reference-implementation test below.

4.8 is done. The presentation rules that were hardcoded as literal string prefixes and ID sets now live in one data-driven rules file, so a content author can add or rephrase a prayer without editing Dart. Classification output is byte-identical to the old behaviour, pinned by a test over the whole shipped corpus.

The tests for it are deliberately two-sided, because the corpus comparison alone is not enough. The first half replays every shipped prayer and novena day against a reference implementation of the *old* literals, which proves the rule data has not drifted. The second half renders the text views and asserts the styling they actually produce, because a widget can ignore the rules and still leave every rule list correct — swapping the prayer-count triple match for a disjunction, or stubbing the heading gate, changes the screen while every rule stays intact. Each of those mutations, and dropping or padding any single entry, fails the suite.

The audit found one real defect in the first cut of that refactor, and it is worth recording because the corpus test could not see it. The pre-4.8 intention check was `startsWith` over eight prefixes **or** `contains` over three fragments; the `contains` clause existed because the novena prints `(taja nia zako hapa)` *after* a lead-in, so `startsWith` alone would miss it. The refactor merged all eleven entries into one `contains` list, which reproduces every shipped line exactly and is nevertheless strictly broader — it would also italicise a line that merely mentions a marker mid-sentence. The rules file now keeps the two lists separate and the widget ORs them, matching the original. Two rendering tests pin both directions, since only a test that goes through the widget can distinguish the two.

4.6 is **skipped on measurement, the same call as 3.4.** The task as written rests on a premise that does not survive contact with the real corpus.

##### 4.6 measured, and why it was not done

The plan's stated target is "200+ litany lines currently lay out in one pass". No text in the app is anywhere near that. Counting the shipped corpus:

| Content | Worst single item | Corpus total |
| --- | --- | --- |
| Prayers, non-empty lines | **97** (`litany_of_reparation`) | 1,287 EN / 1,241 SW across 36 prayers |
| Novena days, paragraphs | **35** (`litany_of_trust_novena`) | 84 days |

The worst case is 97 lines, not 200. And at 97 lines, virtualizing is not worth a refactor. Forced relayout of an already-mounted tree, min-of-40 runs, realistic 390×844 phone viewport:

| Tree | min | over empty |
| --- | --- | --- |
| empty | 7.03 ms | — |
| `LitanyTextView`, 97 lines, eager `Column` | 27.59 ms | **20.56 ms** |
| plain `Column` of 97 bare `Text` widgets | 17.77 ms | 10.74 ms |
| `ListView.builder` — genuinely virtualized | 20.45 ms | 13.42 ms |

Read the middle two rows together. A bare `Column` of 97 plain `Text` widgets, with no classification and no styling logic at all, already accounts for 10.74 ms of the 20.56 ms. That is Flutter laying out text, and virtualization does not make text cheaper. The addressable part — `LitanyTextView`'s own per-line classification — is roughly 10 ms, and 4.1–4.4 already cut it. The genuinely virtualized `ListView.builder` measures 20.45 ms against the eager column's 27.59 ms, and it is *slower* than the plain 97-widget `Column`: at this size the sliver machinery costs about as much as it saves.

**The realistic ceiling for 4.6 is about 7 ms, on one prayer out of 36** — the largest in the app. The price is a `CustomScrollView`/sliver refactor of five screens (`prayer_detail_screen.dart`, `rosary_step_screen.dart`, `novena_thanksgiving_screen.dart`, `novena_closing_prayer_screen.dart`, `novena_day_screen.dart`), which rewrites the widget tree of every reading view in the app. Two further problems compound it: several of those text views sit inside `AppCard`, which cannot host a sliver at all, so those call sites could not be virtualized without removing a card and breaking §0.1; and the plan makes the OWNER screenshot pass mandatory precisely for changes of this kind, and that baseline does not exist yet.

Trading a five-screen, invariant-adjacent, screenshot-gated refactor for ~7 ms on the single worst prayer is a bad deal. The item is closed as measured-and-rejected rather than implemented.

| ID | Status | Notes |
| --- | --- | --- |
| 4.1 | Done | All `RegExp` in the three text views are now `static final` fields. A source-level test walks each `RegExp(` back to its statement and fails if it is not static. |
| 4.2 | Done | `_splitHeading` is behind a `contains` gate over its seven literal prefixes; `_splitRequestPlaceholder` and `_splitOpening` are behind the cheap checks that already existed. Previously 8 regexes ran per paragraph. |
| 4.3 | Done | Each view derives its lowercased form once per line/paragraph and threads it through the classifiers instead of re-allocating per check. |
| 4.4 | Done | Body splits go through `TextSplitCache` (`lib/shared/utils/text_split_cache.dart`), bounded at 64 entries with LRU eviction. Three separate maps, because lines, paragraphs and raw lines are different splits of the same key. |
| 4.5 | Done | A-/A/A+ now drives a `ValueNotifier<double>` consumed by a `ValueListenableBuilder` around the chip row and the text only, in both detail screens. A source-level test fails if the scale is mutated through `setState` again. |
| 4.7 | Done | `PrayerEntity` derives a lowercased search haystack (title, category, body, tags) once per language and hangs it off an `Expando` keyed by the entity, so the memo cannot outlive the entity or be shared by two entities that share an id. The library debounces re-scoring by 250 ms. `score()` and `matches()` were otherwise left byte-for-byte identical. |
| 4.6 | Skipped on measurement | Premise was wrong (97 lines, not 200) and the measured ceiling is ~7 ms on one prayer. Five-screen sliver refactor declined; §0.1 would also have been at risk from the `AppCard`-wrapped call sites. |
| 4.8 | Done | Response, invocation, heading and request-placeholder prefixes, plus the St Rita and All Saints ID sets, now live in `lib/shared/widgets/text_style_rules.dart` as data. No text view contains a presentation prefix literal any more. Verified two-sided: corpus parity against the old literals, plus rendered-output tests that fail if a widget stops consulting the rules. Anchored and unanchored fragment lists are kept separate, matching the original `startsWith`/`contains` split. |

**Measured (this project, Dart VM, isolated from layout):**

| Work | Before | After | |
| --- | --- | --- | --- |
| Classification pass over all 1,724 English prayer lines (71,610 chars) | 5.767 ms | 3.830 ms | **1.51×**, identical results |
| Body splits over the 15 largest bundled corpora (219,634 bytes) | 2.661 ms | 0.033 ms | **82×**, byte-identical output |
| 4.7 scoring pass over the 36 Swahili prayers (64,788 chars), typed as the 8 keystrokes of "baba yetu", ×200 | 738.78 ms | 268.86 ms | **2.75×** on scoring alone, for identical scores |

A widget-level rebuild benchmark was also tried and **discarded**: pumping a novena or litany measures ~12–19 ms either way, and the same code produced 12.3 ms and 16.3 ms on consecutive runs. Layout dominates, so it cannot resolve these changes. The numbers above are the honest ones.

The 4.7 figure counts only the scoring work, so it understates the user-visible win. Typing "baba yetu" fires eight `onChanged` callbacks; before, each one re-scored all 36 prayers, and after, eight of those passes collapse into one. The end-to-end reduction for those keystrokes is therefore about **22×**, of which 2.75× comes from the cached index and the rest from the debounce.

**Why 4.7 cannot have changed search results.** `test/unit/part4_search_index_test.dart` keeps a verbatim copy of the pre-4.7 scoring and matching logic and asserts that the optimized `score()` and `matches()` agree with it for 32 queries × all 36 prayers, that the resulting id order is identical, and that a per-language index never leaks into another language. Because the reference uses the same sort as the implementation, that comparison alone would not notice a change to the *ordering* rule, so four queries are additionally pinned against literal ID goldens, and four are pinned to return nothing. The debounce is pinned separately: the grid must still be on screen at +100 ms, be replaced at +400 ms, return when the field is cleared, and leave no pending timer behind on dispose.

**Verification (AGENT), for 4.1–4.5 only:**

- [x] `part4_text_classification_test.dart` pins the heuristics: response prefixes with and without `*` and quote markers, all-caps heading length bounds, italic span splitting, litany St Rita / Lamb of God lines, and — for 4.2 specifically — that the four heading shapes in the shipped corpus still split, using the exact line from `st_rita_novena.json`.
- [x] `part4_render_cache_test.dart` covers the cache (memoization, no cross-contamination between the three split kinds, bounding, post-eviction correctness) and the scale (A+/A-/A round trip, clamping at both ends, text never altered).
- [x] Source-level guards for the two properties no widget test can observe: regexes are static, and the scale is a notifier rather than `setState` state.
- [x] All four gate commands pass; the full `flutter test` suite is green at 145/145.

**Verification (OWNER), still outstanding and now covering both halves of Part 4:**

- [ ] Screenshot-diff all 36 prayers and all 9 novenas × all days, in both languages. **Mandatory** before 4.6 begins, and 4.1–4.5 plus 4.7 need the same pass to confirm they are in fact pixel-identical.
- [ ] Confirm litany scroll is smoother against the Part 1.8 baseline
- [ ] Confirm the A+/A− control still feels immediate

---

### Part 5 — Startup, rebuild scope, and responsiveness

**Goal:** shorter first frame, and rebuilds limited to the widgets that actually changed.

| ID | Task | Target | File |
| --- | --- | --- | --- |
| 5.1 | Call `runApp` before the platform-channel awaits | `setEnabledSystemUIMode` and `initiallyLaunchedFromHomeWidget` currently block the first frame | `main.dart:11-12` |
| 5.2 | Stop preloading all prayers in a post-frame callback | Loads content the user may never open | `app.dart:52-54` |
| 5.3 | Load the active novena title without parsing all 9 novenas | ~130 KB parsed to display one string | `today_screen.dart:25-30` |
| 5.4 | Make bottom-nav tab switches state-preserving | `context.go()` currently destroys and rebuilds the destination, losing scroll position | `app_bottom_nav.dart:33` | **(Done via `StatefulShellRoute.indexedStack`, not via the nav widget alone — see status.)**
| 5.5 | Narrow what the root reads from settings | Any settings change currently rebuilds the whole `MaterialApp.router` | `app.dart:119` | **(Done with a derived record provider, not `.select` — see status.)**
| 5.6 | Add value equality to state classes | Zero `==`/`hashCode` in the codebase; identical states still notify listeners | `settings_providers.dart:21-51`; `novena_state.dart`; `rosary_state.dart`; `today_providers.dart:23-50` |
| 5.7 | Build the nav destination list once per language | 4 objects + a list allocated on every navigation | `app_shell.dart:43-65` |
| 5.8 | Consolidate persistence behind one service | **`Premise invalid — see status.`** | `novena_providers.dart:227`; `today_providers.dart:52` |

**Acceptance:** first-frame time improves against the Part 1.7 baseline; switching bottom-nav tabs preserves scroll position (5.4 — the one intended behaviour change); no settings change rebuilds more than the affected subtree.

**Acceptance outcome:** the AGENT-verifiable criteria are met — tab switches preserve scroll position (5.4, mutation-verified), and no settings change rebuilds the root (5.5). The first-frame clause is **not met and is not yet measurable by AGENT**: it is an OWNER timing comparison against the Part 1.7 baseline, and 5.4 works *against* it by building all four tab branches at startup. See the status table before claiming this part improved startup.

**Verification (AGENT):**

- Assert `runApp` is called before the platform-channel awaits in `main.dart`
- Assert no eager content preload remains in a post-frame callback
- Assert the Today screen's active-novena title is not sourced from a full novena load
- Assert `userSettingsProvider` is read via `.select` for the single field the root needs
- Assert the state classes implement `==` and `hashCode`
- Assert the nav destination list is built once per language, not per build
- Assert `SharedPreferences` access is funnelled through a single service and that the duplicated novena-progress parsing is gone
- All four gate commands pass.

**Verification (OWNER):**

- First-frame timing vs the Part 1.7 baseline
- Navigate all four tabs and confirm scroll position is retained (5.4)
- Cold-launch from the home-screen widget and confirm the deep link still resolves — 5.1 changes launch ordering and this is the most likely place for a silent break
- Memory vs the Part 1.9 baseline

**Risk:** medium. 5.1 touches launch ordering, including the widget launch path. 5.4 is a user-visible behaviour change and needs release-note wording.

**Status (AGENT):**

| Item | Status | Notes |
| --- | --- | --- |
| 5.1 | Done | `runApp` now runs before the `setEnabledSystemUIMode` and `initiallyLaunchedFromHomeWidget` awaits. The launch URI is applied via `appRouterProvider.go()` in `_applyWidgetLaunch`, deliberately **not** through the slug resolver: the widget URI is a real in-app route, the old code used it as `initialLocation` verbatim, and warm `widgetClicked` taps call `go()` the same way. Getting this wrong was caught by a test, not by inspection. Covered by `test/widget/home_widget_launch_test.dart` (late link, null link, failed platform channel, post-dispose resolution). |
| 5.2 | Done | Post-frame `ref.read(prayersProvider)` preload removed. |
| 5.3 | Done | `getNovenaById` + `activeNovenaTitleProvider`. The fast path matches the filename stem; a fallback to the full-corpus lookup by JSON `id` was added after review, because returning `null` on a stem mismatch would make the title provider treat a real novena as missing and clear the user's progress. |
| 5.4 | **Done — with a trade-off the plan did not anticipate** | Implemented with `StatefulShellRoute.indexedStack` in `app_router.dart`; `AppShell` now takes a `StatefulNavigationShell`, and `AppBottomNav` takes `selectedIndex` + `onDestinationSelected` instead of a `location` string. `pushReplacement` was tried first and rejected (it grows the tab stack and breaks back-navigation); `context.go` inside a stateful shell resets branch state. Verified in `bottom_nav_state_preservation_test.dart`: a Today↔Pray round trip preserves the offset, branches keep independent offsets, and every tab stays reachable. Reverting to a plain `ShellRoute` was mutation-tested and drops the offset to 0, failing both preservation tests. **Cost:** an IndexedStack builds every branch eagerly, so all four tab screens now build at startup instead of only `/today`. That regresses the startup work in 5.1–5.3 and is why the first-frame acceptance clause cannot be claimed. It also surfaced a real test-timing bug in `widget_test.dart`, where the library's header renders before its content. **Needs release-note wording.** |
| 5.5 | Done — **by a different mechanism than documented** | The plan specified `.select`; there is no `.select` anywhere in the app. Implemented as `rootSettingsProvider`, a derived `Provider` returning a `RootSettings` record of just `themeMode` and `fontScale`. The acceptance criterion (no settings change rebuilds more than the affected subtree) is met — a reminder-only change yields an equal record — but note this only works because the record has value equality, which is 5.6 work. `.select` would not have. Tested at `part5_state_equality_test.dart:263`. |
| 5.6 | Done | `==`/`hashCode` on `UserSettings`, `TodayLocalState`, `NovenaProgress`, `RosaryProgress`, `RosarySession`, `RosaryStep`. Mutation audit confirmed all state is copy-on-write, so suppressing equal-state notifications is safe. |
| 5.7 | Done | Nav strings and destinations cached per language. |
| 5.8 | **Not implemented — premise did not hold** | `SharedPreferences.getInstance()` is already a cached singleton returning one in-memory instance whose getters read `_preferenceCache`, so all 22 call sites already share a single disk read and cost nothing per call. There are no redundant platform round-trips to remove. The second half (deduping novena-progress parsing) is real duplication, but the two copies differ deliberately — Today falls back to legacy `completedNovenaDays` on malformed JSON while Novena returns empty — so consolidating them is a logic change, not an optimization. Flagged rather than silently skipped. |

---

### Part 6 — Content-authoring flexibility

**Goal:** a content author adds a prayer or novena by creating JSON files and running one command. No Dart file is edited, and a mistake is caught by a validator rather than by a user reporting a missing prayer.

| ID | Task | Closes | Detail |
| --- | --- | --- | --- |
| 6.1 | Add presentation fields to prayer and novena JSON | F4, F1, F3 | A `style` field on prayers and novenas, so `stRitaStyle` / `allSaintsStyle` / litany rendering are declared in content rather than inferred from ID lists in Dart |
| 6.2 | Read novena day count from the JSON | F2 | The `days` array already carries the count. Remove `_maxDaysForNovena` and all three Dart copies of `st_rita_novena ? 12 : 9` |
| 6.3 | Add a `day_count` cross-check to the validator | F2 | Catches a mismatch between declared and actual days |
| 6.4 | Build `tool/generate_content_manifest.dart` | F6, F7 | Already specified at `docs/architecture/folder_structure.md:147`; scans disk and writes the manifest, eliminating hand-maintained paths |
| 6.5 | Make the validator check manifest ↔ disk agreement | F5 | Today the app reads paths from the manifest while the validator reads files from disk, so they can disagree silently. This is the highest-risk gap in the project |
| 6.6 | Add EN/SW ID parity validation | F8 | Closes `APP_INDEXES.md` Note A, open today. Sw-only and en-only IDs need an explicit, declared alias rather than a code comment |
| 6.7 | Replace literal string-prefix styling with declared markers | F9 | Content authors should not lose formatting by rephrasing a line. Prefer explicit markers in the source text over matching English and Kiswahili prefixes |
| 6.8 | Consolidate the 18 i18n string classes | i18n | Either adopt one real i18n mechanism or consolidate the hand-rolled classes. Do not add a 19th copy. Adding a third language must not mean 18 more files |
| 6.9 | Update `CONTENT_GUIDE.md` for the new authoring flow | — | The authoring path changes, so the guide that documents it must change with it |

**Acceptance:** adding a test prayer requires creating 2 JSON files and running one command — verified by actually doing it end-to-end. A deliberately broken manifest fails validation loudly. A deliberately mismatched EN/SW pair fails validation. **No prayer changes its display mode, and none gains or loses a card** (§0.1).

**Verification (AGENT):**

- Add a test that runs the manifest generator, then asserts the output matches what is committed — the generator cannot drift from the manifest
- Add a test asserting the validator **fails** when a JSON file exists on disk but is absent from the manifest (F5). This is the highest-risk gap in the project and it currently fails silently.
- Add a test asserting the validator fails on an EN/SW ID mismatch with no declared alias (F8)
- Add a test asserting novena `day_count` matches the actual `days` array length (F2, F3)
- Add a test asserting every prayer and novena declares its presentation fields (F1, F3, F4)
- `content_validation_test.dart` extended to cover all of the above
- All four gate commands pass.

**Verification (OWNER):**

- Add a prayer and a novena end-to-end: 2 JSON files + 1 command, then confirm correct appearance, correct routing, and a working deep link
- **Full re-verification of all 36 prayers and 9 novenas in both languages.** 6.1 and 6.7 change how existing content is classified, so existing content may need marker additions. This is the part most likely to need content-author time, and it is the part where an AGENT-only pass is least sufficient.
- Confirm `APP_INDEXES.md` and `docs/CONTENT_GUIDE.md` match the new authoring flow

**Risk:** medium-high. This is the only part that changes the content schema. It runs after Parts 2–5 so a schema problem cannot be confused with a performance regression.

---

### Part 7 — Dead-code sweep, and the handover pack

**Goal:** leave no dead code behind, and hand the owner a precise list of what still needs a device.

| ID | Task | Class |
| --- | --- | --- |
| 7.1 | Run the §4 dead-code policy over everything touched; record each deletion with its confirming grep | AGENT |
| 7.2 | `flutter analyze` clean, with no newly-introduced unused members | AGENT |
| 7.3 | Full content validation passes | AGENT |
| 7.4 | Full unit + widget suite green (11 files) | AGENT |
| 7.5 | Confirm the §0.1 invariant guards pass and that no prayer gained a card | AGENT |
| 7.6 | Produce one consolidated OWNER checklist: every device/build item from Parts 1–6, in order | AGENT |
| 7.7 | Run the 3 `integration_test` files on a device or emulator | **OWNER** |
| 7.8 | Re-measure the release AAB and compare against the §1 baseline | **OWNER** |
| 7.9 | Screenshot-diff every screen, both languages, against pre-optimization captures | **OWNER** |
| 7.10 | Full device pass on a low-end Android: first frame, litany scroll, novena day, search, rosary run, reminder, widget, deep link, bottom-nav scroll retention | **OWNER** |
| 7.11 | Publish a final results table, replacing §2.3 estimates with measured numbers, and listing any goal not met with the reason | **OWNER** |

**Acceptance:** all AGENT items pass; the OWNER checklist in 7.6 is complete, specific, and ordered. The §2.3 estimates are explicitly still labelled estimates until 7.8 and 7.11 replace them.

**Note on honesty in reporting:** the agent may report "AGENT items pass" and nothing more. It must not state that a part is fully verified, or that a size or speed target was met, while OWNER items remain open. Size and timing claims stay marked as estimates until measured on a device.

---

## 6. Expected outcome

### Performance

| Metric | Baseline | Target | Basis |
| --- | --- | --- | --- |
| Redundant prayer corpus parses | 1 per prayer opened | 0 | Measured asset-read count |
| Manifest decodes per content load | 2 | 1 | Code |
| RegExp compilations per litany build | ~800 | ~0 (hoisted + memoized) | Measured |
| Startup JSON decoded on UI isolate | ~215 KB | ~0 | Isolated |
| First frame | Part 1 measurement | Measurably faster | Measured |
| Litany scroll frame timings | Part 1 measurement | Measurably smoother | Measured |
| Off-screen list items laid out | All of them | Viewport only | Code |

### Size

| Basis | Baseline | Target |
| --- | --- | --- |
| Compressed transport | ~9.8 MB (measured) | ~8.5 MB (estimated) |
| APK as stored | ~21.3 MB (measured) | ~20.2 MB (estimated) |

**Stated plainly: this work will not produce a dramatically smaller download.** The Flutter engine is ~85% of shipped bytes and is not ours to shrink. The ~1.3 MB saving is real but modest. The meaningful wins from this plan are speed, responsiveness, memory, and content-authoring safety.

### What can and cannot be proven without a device

| Claim type | Provable now | Needs a device |
| --- | --- | --- |
| Code structure, dead code removed, invariants held | Yes — `flutter analyze` | — |
| Correct content classification and formatting rules | Yes — unit tests | — |
| Identical search results | Yes — result-ID assertions | — |
| Each asset read exactly once | Yes — read-count tests | — |
| No prayer gained a card | Partially — guard tests and greps | Final visual confirmation |
| Identical pixels | No | Screenshot diff |
| Faster first frame, smoother scroll | No | Timings |
| Actual download size | No | Fresh build + Play Console |

**Honest limit:** roughly half the acceptance criteria in this plan cannot be verified without running the app on a device. That is recorded per item as AGENT or OWNER in §0.2, and consolidated into one ordered handover checklist by Part 7 item 7.6.

### Quality

| Outcome | Detail |
| --- | --- |
| No visual change | Verified by screenshot diff across every screen, both languages (OWNER) |
| No prayer boxing | Hard invariant §0.1, guard test, re-checked at every gate |
| No data migration | JSON and stored preferences unchanged |
| Content additions are safe | Validator catches a missing manifest entry, a mismatched EN/SW pair, and a day-count mismatch — all of which are silent failures today |
| No accumulated dead code | Part 7 sweeps everything, and each part is required to leave none behind |

---

## 7. Risks

| Risk | Part | Class | Likelihood | Mitigation |
| --- | --- | --- | --- | --- |
| **A prayer reading view silently gains a card** | 4, 5, 6 | AGENT-detectable | Medium | Dedicated hard invariant (§0.1), an automatic guard test from Part 1.4, greps in the gate, and mandatory OWNER screenshot diff |
| **Layout shift after virtualization passes every test** | 4 | OWNER-only | Medium | 4.6 can be fully green and still shift pixels. Only the OWNER screenshot pass catches this, so it is not optional |
| **Caching bug passes unit tests but serves stale content** | 3 | OWNER-only | Medium | Unit tests prove read counts, not freshness. OWNER opens all 36 prayers and all 9 novenas |
| **Content misclassified after styles become data-driven** | 6 | Mixed | High | Classification tests cover known samples; OWNER re-verifies all content. Budget content-author time |
| Off-by-one in novena day routing after removing `_maxDaysForNovena` | 6 | AGENT + OWNER | Medium | New day-count test; OWNER tests every day of every novena, especially `st_rita_novena` (12) vs the rest (9) |
| Logo looks soft at 72 px | 2 | OWNER-only | Low–Medium | 192 px is still 2.6× oversampled, but only a device shows it. Explicit OWNER item, highest risk in Part 2 |
| Widget-launch deep link breaks when launch ordering changes | 5.1 | OWNER-only | Low | Explicit OWNER item: cold-launch from the widget |
| Removing a package that only a test imports | 2.5 | AGENT | Low | Grep `lib/`, `test/`, `integration_test/`, `tool/` first; Part 1.5 guard prevents recurrence |
| Size targets set on a remembered 10 MB limit | 1.6 | OWNER | High | Part 1.6 reads the real Play Console figure before any size work is judged |
| **A part reported as done while OWNER items are open** | all | Process | Medium | Every criterion is labelled AGENT or OWNER. The agent reports AGENT passes only, and never claims a size or speed target is met while unmeasured |

---

## 8. Change control

- Parts are merged independently and each is individually revertible.
- A part is not started until the previous part's acceptance gate passes.
- Any change that alters rendered output, bundled content, or stored data is out of scope for this plan and needs a recorded decision.
- **The §0.1 no-boxing invariant is never waived.** If a change appears to require boxing a prayer, that is a product decision for the owner, not an implementation detail.
- The app is never run and no build is produced by the agent (§0.2). Size and timing figures stay labelled as estimates until measured on a device.
- The projected size figures in §2.3 are estimates. Part 1 item 1.6 records the real store figure and Part 7 items 7.8 and 7.11 publish the final measured result.

---

## 9. OWNER checklist — you run these, the agent does not

Nothing in this section has been done. The agent never runs the app and never
produces a build (§0.2). Each item needs a device, a build, or a store account.

### 9.1 Required now, before Part 2 is signed off

Part 2's code and gates are complete. What remains is the device work, which the
agent cannot do. The items below were Part 1's handover and are still open.

Note: the AAB at `build/app/outputs/bundle/release/app-release.aab` predates the
Part 2 commits, so re-running the size report against it measures the old build.
Rebuild before treating any number as a Part 2 result.

| # | Item | How | What to record |
| --- | --- | --- | --- |
| 1 | **Confirm the Part 1 rendering change is invisible** | `flutter run`, then open: a standard prayer, a litany, a novena day, a rosary step, the St Rita novena closing prayer, the St Rita novena thanksgiving, and the **same two novena screens for any other novena** | That the two novena screens are still carded and the other four are still unboxed. This is the single highest-value check in Part 1 — it is the only thing that can catch an unintended visual change |
| 2 | Compressed download size | Play Console → internal-test track, or `bundletool` / `unzip` on the split APK | The real number, to compare against the derived 9.73 MB in §1.2 (item 1.6) |
| 3 | First-frame timing | `flutter run --profile`, DevTools performance overlay | Real number, not an estimate (item 1.7) |
| 4 | Scroll-jank timings | Profile mode, heaviest litany and heaviest novena day | Frame timings (item 1.8) |
| 5 | Peak memory | Profile mode on a low-end device | Baseline before the logo and timezone work (item 1.9) |

### 9.2 The pre-existing widget failure — now fixed

`flutter test test/widget` used to report failures in
`today_novena_localization_test.dart` and `onboarding_routing_test.dart`. **Both
are fixed**; the suite is 10/10 green. `test/helpers/test_asset_bundle.dart`
injects the real bundled content so the multi-file read chain settles under
`testWidgets`. Full measurements and the corrected root cause are in §0.2.

The 3 remaining failures in `test/widget_test.dart` are outside the gate and
unrelated to Part 2; see [Out of gate](#out-of-gate).

### 9.3 Re-measure size without rebuilding

```
dart run tool/size_report.dart build/app/outputs/bundle/release/app-release.aab
dart run tool/size_report.dart
```

The first reads an existing bundle. The second needs no build at all and reports
source asset sizes with gzip figures. Neither command builds anything.

### 9.4 Later parts

OWNER items for Parts 2–7 are added to this section as each part is accepted.
None exist yet — Parts 2–7 have not been started.
