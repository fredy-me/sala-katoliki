# Sala Katoliki — App Optimization Plan

**Status:** Planning only. No code has been changed.
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

Verified current state:

| Screen | Body view | Container flag | Result |
| --- | --- | --- | --- |
| Prayer detail — standard prayers | `PrayerTextView` | none exists | **No card** |
| Prayer detail — litanies | `LitanyTextView` | `showContainer: false` | **No card** |
| Novena day | `NovenaTextView` | `showContainer: false` | **No card** |
| Rosary step | `LitanyTextView` | `showContainer: false` | **No card** |

`PrayerTextView` (`shared/widgets/prayer_text_view.dart`) has no container parameter at all — it can never be boxed. `LitanyTextView` and `NovenaTextView` default `showContainer` to `true`, so **every call site must keep passing `showContainer: false` explicitly.**

### Why this is called out separately

Four parts touch exactly this code, and each could silently reintroduce a card:

| Part | Item | Card-reintroduction risk |
| --- | --- | --- |
| 4 | 4.4 memoize the body split | A memoized/cached parse must not absorb or drop the `showContainer` branch |
| 4 | 4.6 virtualize the text views | The `AppCard` branch at `litany_text_view.dart:47` and `novena_text_view.dart:59` must stay unreachable for prayers |
| 5 | 5.4 bottom-nav state preservation | Changing how screens are built must not change what wraps their content |
| 6 | 6.1 data-driven style flags | Routing a prayer to a different text view must not land it in a view that defaults to a card |

### Enforcement

- `showContainer: false` is asserted for every prayer/novena-day/rosary-step call site.
- A grep for `showContainer: false` and a grep for `AppCard(` are both part of the gate checks in §0.2.
- Screenshot comparison of all 36 prayer screens, both languages, is a mandatory gate.

### Deliberately out of scope

Two nearby cases must **keep** their current behaviour and are **not** to be "simplified" into consistency with prayers:

| Case | Current behaviour | Keep as-is |
| --- | --- | --- |
| Novena closing prayer | `showContainer: !isStRitaNovena` | Conditional container — carded except for `st_rita` |
| Novena thanksgiving | `showContainer: !isStRitaNovena` | Conditional container — carded except for `st_rita` |
| Prayer list tile | `PrayerCard` → `AppCard` | List tiles in the library, search results, and favourites keep their card. This is a list row, not a prayer reading view |

Do not "fix" the asymmetry between these. It is intentional and visible.

---

## 0.2 Verification policy

**The agent does not run the app and does not produce builds.** No APK, no debug build, no release build, no AAB, no IPA, no install, no launch.

### The only commands run at a gate

| # | Command | Purpose |
| --- | --- | --- |
| 1 | `flutter analyze` | Must report zero issues |
| 2 | `flutter test test/unit` | Unit tests — 7 files |
| 3 | `flutter test test/widget` | Widget tests — 4 files |
| 4 | `dart run tools/validate_content.dart` | Content validator must pass |

These run only at a part's acceptance gate, not continuously. `flutter test` executes on the host Dart VM and produces no app build, so it is within policy.

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

| Component | Raw | gzip -9 (measured) |
| --- | --- | --- |
| `libflutter.so` (Flutter engine) | 10,850 KB | — |
| `libapp.so` (this app's Dart AOT code) | 6,337 KB | — |
| `libdartjni.so` | 122 KB | — |
| **native libs subtotal** | **17,313 KB** | **7,572 KB** |
| `dex` (classes.dex + classes2.dex) | 1,473 KB | 661 KB |
| `flutter_assets` — `logo.png` | 1,071 KB | ~1,040 KB (PNG is already compressed) |
| `flutter_assets` — `assets/content/**.json` | 434 KB | 79 KB |
| `flutter_assets` — `NOTICES.Z` | 124 KB | 124 KB (already gzipped) |
| `flutter_assets` — fonts, shaders, manifests | ~11 KB | ~11 KB |
| `resources.pb` + `res/*` + `root/*` + manifest | ~900 KB | ~230 KB |

There are two defensible ways to state "download size", and they differ by more than 2x:

- **Basis A — APK as stored on device.** Native `.so` files are stored uncompressed so they can be memory-mapped directly. Total: **~21.3 MB**.
- **Basis B — compressed for transport.** Total: **~9.8 MB**.

**Baseline on both bases: Basis A ≈ 21.3 MB, Basis B ≈ 9.8 MB.**

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
| Declared-but-unimported packages | 3 (`easy_localization`, `intl`, `cupertino_icons`) |
| Duplicated i18n string classes | 18 |
| Startup JSON decoded on the UI isolate | ~215 KB (prayers + novenas) |

---

## 2. Answer: how small will the download get?

**Short answer: about 8.5 MB on Basis B, about 20.2 MB on Basis A. A 10 MB download is not achievable on Basis A, and is only just achievable on Basis B — it should not be treated as a reliable target.**

### 2.1 Why 10 MB is not reachable

`libflutter.so` is **10,850 KB (10.6 MB) by itself** and is compiled by Google, not by this project. It ships with every Flutter app and no code change in this repository affects it.

- On **Basis A** the engine alone exceeds 10 MB, so 10 MB is mathematically impossible.
- On **Basis B** the engine compresses to roughly half, and the total lands just under 10 MB — but that leaves almost no headroom. Adding content, a plugin, or a dependency pushes it over.

### 2.2 What the optimization work actually saves

| Change | Basis B saving | Certainty |
| --- | --- | --- |
| Logo 1254×1254 PNG → ~192 px WebP | **~1,030 KB** | High — PNG does not recompress |
| Drop 3 unused packages (`easy_localization`, `intl`, `cupertino_icons`) | ~30–40 KB (dex) + small AOT effect | Medium |
| Remove dead code / consolidate 18 i18n classes (smaller `libapp.so`) | ~100–200 KB | Low–medium, not linear |
| Drop `x86_64` ABI from the bundle | 0 KB to users | Certain — affects AAB size only, not per-device |
| **Total realistic saving** | **~1.2–1.3 MB (≈13%)** | |

### 2.3 Projected result

| Basis | Now | After all parts | Saving |
| --- | --- | --- | --- |
| A — APK as stored | ~21.3 MB | ~20.2 MB | ~1.1 MB |
| B — compressed transport | ~9.8 MB | ~8.5 MB | ~1.3 MB |

### 2.4 The decision this forces

The optimization work makes the app meaningfully faster and lighter, but **it will not make the download dramatically smaller**, because ~85% of the shipped bytes are the Flutter engine and the Dart AOT snapshot — neither of which shrinks much.

If 10 MB is a hard business constraint rather than a current measurement, the options are:

1. **Accept ~8.5 MB (Basis B) / ~20 MB (Basis A)** and proceed with this plan. The app is already lean for Flutter.
2. **Re-check the actual constraint.** Play's bundle limits and the "compressed download size" metric in Play Console should be confirmed against the current policy rather than a remembered 10 MB figure, and the real number read from Play Console for an internal-test track.
3. **Change framework** — only if sub-10 MB stored APK is genuinely mandatory. No amount of Dart-level optimization reaches it.

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
| **A — Delete** | Unambiguously unreachable. Delete outright. | 3 unused packages; `assets/translations/` (contains only `.gitkeep`); `AssetPaths.icons` and `AssetPaths.illustrations` (directories do not exist); the redundant `Ink` inside `PrayerCard`'s `AppCard` (`prayer_card.dart:26`); the unused `matchedPrayers` path if Part 4 removes it |
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
| 1 | Baseline + gate harness | Lock the measurement baseline and the fixed verification commands | Low | Not started |
| 2 | Cheap, zero-risk wins | Immediate size + CPU reduction, no behaviour change | Low | Not started |
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

| ID | Task | Class | Target |
| --- | --- | --- | --- |
| 1.1 | Confirm the §1.1–§1.3 figures against the current `build/app/outputs/bundle/release/app-release.aab` | AGENT | Figures reproduce exactly |
| 1.2 | Add `tool/size_report.dart` that prints the §1.2 per-component table from an existing AAB path | AGENT | Prints the table from a file argument; builds nothing |
| 1.3 | Record the four gate commands in a single documented place so every part uses the same set | AGENT | One list, referenced by all parts |
| 1.4 | Add a unit test that fails if any prayer-reading call site loses `showContainer: false` | AGENT | Guards the §0.1 invariant automatically |
| 1.5 | Add a unit test that fails if any of the three unused packages reappears in `pubspec.yaml` | AGENT | Prevents silent dependency creep |
| 1.6 | Read the actual compressed download size from Play Console, internal-test track | **OWNER** | Replaces the remembered 10 MB figure |
| 1.7 | Record first-frame timing, debug and profile | **OWNER** | Real number, not an estimate |
| 1.8 | Record scroll-jank timings for the heaviest litany and heaviest novena day | **OWNER** | Real frame timings |
| 1.9 | Record peak memory on a low-end device | **OWNER** | Baseline for the logo and timezone wins |

**Acceptance:** §1 figures reproduce; the size report prints; the two invariant guards exist and pass; the four gate commands are documented once.

**Verification (AGENT):** `flutter analyze`, `flutter test test/unit`, `flutter test test/widget`, `dart run tools/validate_content.dart`, plus the two new guard tests.

**Verification (OWNER):** items 1.6–1.9, handed over as a checklist.

**Risk:** none — read-only plus two test files.

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
- All four gate commands pass, including the 7 unit and 4 widget test files.

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
| 3.4 | Move `jsonDecode` off the UI isolate | ~215 KB no longer decoded synchronously during first frame | `local_content_datasource.dart:100-106` |
| 3.5 | Stop parsing novena day bodies for list views | 130 KB parsed and held to render 9 titles | `novena_model.dart:47-51` |
| 3.6 | Reuse the same cache in `deepLinkContextProvider` | Stops parsing a second full copy when the active language is English | `deep_link_providers.dart:14-23` |

**Note on 3.1:** novenas and rosary already use the correct cached pattern (`novena_providers.dart:25-36`). Part 3 makes prayers consistent with them rather than inventing a new approach.

**Acceptance:** opening all 36 prayer screens performs zero additional asset reads; the deep-link resolver performs no reads already satisfied by the cache; all content renders identically; **no prayer reading view gains a card** (§0.1).

**Verification (AGENT):**

- A new unit test asserts each asset file is read **exactly once per language** across a full navigation sweep, and that N reads of `prayerById` trigger zero additional reads. This replaces manual read-count instrumentation, which would have needed a running app.
- Assert the manifest is decoded once, not once per call.
- Assert `jsonDecode` no longer runs on the UI isolate.
- Assert novena list views do not construct day bodies.
- Existing `content_loader_repository_test.dart` and `search_rosary_novena_test.dart` pass unchanged.
- All four gate commands pass.

**Verification (OWNER):**

- Open every one of the 36 prayers and all 9 novenas × all days on a device; content renders correctly
- First-frame timing compared against the Part 1.7 baseline

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

- Extend `search_rosary_novena_test.dart` to assert a fixed set of queries returns the same ordered result IDs as before the change. This is the check that matters most, and it is fully testable.
- Assert every `RegExp` in the three text views is a `static final` field, not constructed inside a build path.
- Assert the A-/A/A+ scale is driven by a `ValueNotifier` scoped to the text subtree, so it no longer triggers a full-screen rebuild.
- Assert the text views emit builder-based children rather than an eager `children:` list.
- Assert the search index is precomputed per language and that input is debounced.
- Extend `content_validation_test.dart` to assert the formatting rules still classify a known set of sample lines identically — intentions, invocations, headings, response lines, prayer counts, request placeholders. **This is what protects the intricate heuristics from regressing without needing a screenshot.**
- All four gate commands pass.

**Verification (OWNER):**

- Screenshot-diff all 36 prayers and all 9 novenas × all days, in both languages. **Mandatory** — 4.6 and 4.7 can pass every test above and still shift layout.
- Confirm litany scroll is smoother against the Part 1.8 baseline
- Confirm the A+/A− control still feels immediate

**Risk:** medium-high for 4.6 and 4.7 (layout and behaviour), low for 4.1–4.5. The AGENT tests cover classification logic; they do not cover layout. The OWNER screenshot pass is the only thing that does, so it cannot be skipped.

---

### Part 5 — Startup, rebuild scope, and responsiveness

**Goal:** shorter first frame, and rebuilds limited to the widgets that actually changed.

| ID | Task | Target | File |
| --- | --- | --- | --- |
| 5.1 | Call `runApp` before the platform-channel awaits | `setEnabledSystemUIMode` and `initiallyLaunchedFromHomeWidget` currently block the first frame | `main.dart:11-12` |
| 5.2 | Stop preloading all prayers in a post-frame callback | Loads content the user may never open | `app.dart:52-54` |
| 5.3 | Load the active novena title without parsing all 9 novenas | ~130 KB parsed to display one string | `today_screen.dart:25-30` |
| 5.4 | Make bottom-nav tab switches state-preserving | `context.go()` currently destroys and rebuilds the destination, losing scroll position | `app_bottom_nav.dart:33` |
| 5.5 | `.select` the single field the root needs from settings | Any settings change currently rebuilds the whole `MaterialApp.router` | `app.dart:119` |
| 5.6 | Add value equality to state classes | Zero `==`/`hashCode` in the codebase; identical states still notify listeners | `settings_providers.dart:21-51`; `novena_state.dart`; `rosary_state.dart`; `today_providers.dart:23-50` |
| 5.7 | Build the nav destination list once per language | 4 objects + a list allocated on every navigation | `app_shell.dart:43-65` |
| 5.8 | Consolidate persistence behind one service | `SharedPreferences.getInstance()` in ~10 places; novena-progress parsing duplicated in two files | `novena_providers.dart:227`; `today_providers.dart:52` |

**Acceptance:** first-frame time improves against the Part 1.7 baseline; switching bottom-nav tabs preserves scroll position (5.4 — the one intended behaviour change); no settings change rebuilds more than the affected subtree.

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
| **Layout shift after virtualization passes every test** | 4 | OWNER-only | Medium | 4.6 and 4.7 can be fully green and still shift pixels. Only the OWNER screenshot pass catches this, so it is not optional |
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
