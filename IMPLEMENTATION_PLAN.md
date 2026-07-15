# Sala Katoliki MVP Implementation Plan

## Purpose and authority

This is the single implementation plan and status record for Sala Katoliki. It is the place to check what is in scope, what is implemented, what still needs verification, and what blocks release.

The product authority remains [the MVP SRS](docs/srs/Sala_Katoliki_MVP_SRS_Kilimanjaro_Technology.pdf). If this plan conflicts with the SRS, the SRS wins until an approved requirement change is recorded here.

Reference specifications support this plan but do not maintain a second implementation roadmap:

- [UI reference](docs/ui_reference.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Content architecture](docs/architecture/content_architecture.md)
- [Content guide](docs/CONTENT_GUIDE.md)
- [Android release preparation](docs/release/android_release_preparation.md)

## MVP boundary

The MVP is an Android-first, offline-first Flutter prayer app. It provides English and Kiswahili bundled prayer content, Today, prayer browsing, favorites, search, Rosary, novenas, local reminders, settings, and About/content information.

The MVP must not depend on authentication, a backend or CMS, cloud sync, payments, ads, audio/video, community features, AI guidance, or unapproved copyrighted content.

## Current delivery status

**Overall: core MVP is implemented; public/store release is not yet ready.**

| Status | Meaning |
| --- | --- |
| Implemented | Present in the app code and covered by at least source-level verification. |
| Partial / reconcile | Present, but does not fully match the SRS or a reference document. |
| Pending | Required work has not been completed or verified. |
| External release input | Needs a real credential, legal decision, live service, device test, or store action. |

### Implementation summary

| Area | Status | Current implementation / evidence |
| --- | --- | --- |
| Documentation baseline | Implemented | SRS, UI, architecture, content, release, and contribution documentation exist. This plan is the canonical status record. |
| App structure and design system | Implemented | Flutter/Riverpod/Go Router structure, shared theme, navigation, reusable cards, states, search, and prayer widgets. |
| Bundled content | Implemented | JSON categories, prayers, Rosary, novenas, metadata, content repositories, and `tools/validate_content.dart`. |
| Onboarding and language | Implemented | English/Kiswahili selection, local persistence, language-aware content and Settings changes. |
| Today | Implemented | Daily prayer, novena continuation, Rosary shortcut, quick actions, recently opened prayer, reminder state. |
| Prayer library, detail, search | Implemented | Dynamic categories, local full-text search, source metadata, share, readable error/empty states. |
| Favorites and recent prayers | Implemented | SharedPreferences persistence, Favorites screen, recent-prayer tracking. |
| Rosary | Implemented | Mystery-by-day suggestion, selection, guided steps, save/resume, previous/next, restart and corrupt-progress reset. |
| Novenas | Partial / reconcile | Local progress, day reading, continuation, closing/thanksgiving sections are implemented; see known gaps for the 12-day St. Rita exception and completion behavior. |
| Reminders and settings | Implemented | Local notification scheduling/cancellation, language, theme, font scale, reminder time, About, legal/support UI. |
| Offline hardening | Partial / reconcile | Core content and persistence are local; manual device airplane-mode/lifecycle sign-off remains pending. |
| Automated checks | Implemented | Unit, widget, and integration test suites exist; bundled content validation passes. |
| Android preparation | Partial / reconcile | Package ID, target SDK, icons, signing configuration, manifest, and internal-testing metadata exist; signed AAB/device/store verification remains pending. |
| iOS readiness | Pending | Flutter iOS project exists; iOS deployment, notification behavior, signing, and build verification remain pending. |
| Store compliance / production | Pending | Legal review, live policy/support confirmation, performance QA, exploratory QA, and store submission remain pending. |

## Functional scope and acceptance

| ID | Requirement | Status | Acceptance evidence required before release |
| --- | --- | --- | --- |
| FR-001 | First-launch language selection and later change | Implemented | English and Kiswahili persist after restart and load matching content. |
| FR-002 | Today prayer hub | Implemented | Prayer or Rosary reachable within two taps; active novena/reminder states render correctly. |
| FR-003–006 | Categories, prayer list/detail, common bundled content | Implemented | Category JSON loads; prayer body is dynamic and readable offline in both languages. |
| FR-007 | Favorites | Implemented | Add/remove/display/persist and invalid IDs handled safely. |
| FR-008 | Offline search | Implemented | Searches title, body, tags, and category; empty/no-match state is clear. |
| FR-009 | Interactive Rosary | Implemented | Start, continue, previous/next, restart, and corrupt-progress recovery work offline. |
| FR-010 | 9-day novenas | Partial / reconcile | Must resolve the 12-day St. Rita exception and confirm final-day completion behavior. |
| FR-011 | Daily local reminder | Implemented | Enable, change time, disable, and permission-denial flow work on real Android/iOS devices. |
| FR-012 | Offline mode | Partial / reconcile | Manual airplane-mode regression must be signed off using [the checklist](docs/offline_regression_checklist.md). |
| FR-013 | Settings | Implemented | Language, font size, theme, and reminder preferences persist. |
| FR-014 | Attribution and legal notes | Partial / reconcile | UI exists; every source/right must be approved before publication. |
| FR-015 | Add prayer without new UI code | Implemented | Valid JSON content appears through existing loaders; validation passes. |

## Delivery phases

### 1. Foundation, structure, and visual system — implemented

- SRS-aligned app structure, routes, theme tokens, shared components, and four primary navigation destinations exist.
- The implemented fourth tab is **Settings**, while the SRS/UI reference says **Library**. This is a reconciliation item, not an accepted silent deviation.

### 2. Content, localization, and prayer flows — implemented

- Content is bundled in `assets/content/` and loaded through local data sources and repositories.
- English and Kiswahili content paths, category data, source fields, and validation are in place.
- Prayer category/list/detail/search/favorite/recent flows are implemented without prayer-specific UI screens.

### 3. Devotional journeys — implemented with a novena compliance item

- Rosary state, guided sequence, restart, resume, and safe progress reset are implemented.
- Novena list/detail/day/progress/Today continuation are implemented.
- St. Rita is deliberately supported as a 12-day devotion by the current validator and progress model. The SRS and content documentation currently describe only 9-day novenas; either the SRS must be amended or the exception must be removed.
- After the final day, active-novena completion state must be reviewed and made explicit before release.

### 4. Preferences, reminders, and legal surfaces — implemented with release verification pending

- Theme, font scale, language, reminders, About, content sources, contact actions, and legal links are implemented.
- Reminder scheduling uses local notifications. Verify Android and iOS permission and notification-tap behavior on physical devices.
- The application metadata still has blank website/privacy fields while the UI contains hard-coded links. Choose one authoritative metadata source before release.

### 5. Quality and release readiness — in progress

- Content validation passes.
- Unit, widget, and integration coverage exists for onboarding, prayer flows, search, favorites, Rosary, novenas, settings, startup, and offline flows.
- Complete and record manual airplane-mode, lifecycle, accessibility, 320 dp, and two-hour exploratory QA before release.
- Measure startup, prayer-detail, and search performance on representative Android devices.

### 6. Android internal testing — in progress

- Current app identity: `com.busaradigital.salakatoliki`.
- Current app version: `1.0.5+5` / `1.0.5`.
- Current target SDK: 35; minimum SDK is inherited from the Flutter toolchain and must be verified against the intended device policy at build time.
- Release signing configuration is supported through `android/key.properties`; never commit the keystore or credentials.
- Produce and test a release-signed AAB before internal upload.

### 7. iOS readiness — pending

- Confirm iOS deployment target and supported devices.
- Review notification permission wording, local reminder behavior, icons, launch assets, links, signing, and a physical-device/TestFlight build.

### 8. Public production readiness — pending

- Approve all content rights, sources, and attribution.
- Confirm working support contact, website, privacy policy, terms, and disclaimer links.
- Recheck current Google Play and Apple requirements at submission time.
- Complete store listing, data-safety declarations, signed builds, release notes, and final QA sign-off.

## Known reconciliation items

These items are intentionally visible here so completed code is not confused with verified product compliance.

1. **Navigation:** SRS/UI documents say `Today / Pray / Novenas / Library`; implementation uses `Today / Pray / Novenas / Settings`, and `/library` redirects to Settings.
2. **Novena duration:** SRS and content documentation say exactly nine days; the product currently includes a 12-day St. Rita novena.
3. **Novena completion:** confirm and implement the expected completed state after the final day instead of retaining an active, fully-completed devotion.
4. **Android permission record:** the release document must reflect `POST_NOTIFICATIONS`, exact-alarm, boot-completed, and vibrate declarations in the release manifest, including their justification.
5. **External links and metadata:** docs/metadata currently conflict with the working hard-coded legal/support links. Establish one maintained source and test all links online and offline.
6. **Target structure:** `docs/architecture/folder_structure.md` is a target/reference tree, not an exact inventory of every current file.
7. **Stale historical wording:** do not rely on the old “Current State” description that mentioned placeholder screens or `assets/data/prayers.json`; the live content system is under `assets/content/`.

## Verification checklist

Run these before a release candidate, then record the result, date, device, and build version in the release evidence section below.

1. `dart run tools/validate_content.dart`
2. `flutter analyze`
3. `flutter test`
4. Run integration tests on an Android emulator/device.
5. Follow [the offline regression checklist](docs/offline_regression_checklist.md) in airplane mode.
6. Verify first launch, language switching, prayer search, favorites, Rosary resume, novena completion, reminder enable/change/disable, theme/font scaling, and external-link failure handling.
7. Test at 320 dp width and representative Android devices.
8. Build and install a release-signed AAB for Android internal testing.
9. If iOS is in scope, complete the iOS readiness phase before TestFlight or store submission.

## Release evidence register

Add an entry only after performing the check; do not mark an item complete from implementation alone.

| Date | Version/build | Check | Device/environment | Result | Evidence / issue link |
| --- | --- | --- | --- | --- | --- |
| 2026-07-14 | 1.0.4+4 | Bundled content validator | Local development checkout | Passed | `dart run tools/validate_content.dart` |

## Change-control rule

Before implementing a new feature, update this plan when it changes MVP scope, acceptance criteria, status, release requirements, or known reconciliation items. Add backend/CMS, cloud sync, accounts, audio, Bible/readings, community, AI, or monetization work only through an approved post-MVP requirement change.
