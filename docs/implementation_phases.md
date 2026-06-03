# Implementation Phases

This roadmap takes Sala Katoliki from the current project through architecture restructuring, SRS-compliant MVP implementation, QA, and production readiness.

Inputs:

- SRS: `docs/srs/Sala_Katoliki_MVP_SRS_Kilimanjaro_Technology.pdf`
- UI reference: `/home/meck/Desktop/Sala-picturesUI`
- Folder structure: `docs/architecture/folder_structure.md`

## Phase 0: Baseline And Guardrails

Goal: Lock the working source of truth before restructuring code.

Tasks:

- Keep SRS as the product source of truth.
- Keep UI reference screenshots as the visual source of truth.
- Confirm MVP exclusions: no auth, backend dependency, payments, ads, audio/video, community, AI, or unlicensed copyrighted content.
- Keep docs updated before major structural moves.

Done when:

- README, architecture docs, content docs, UI docs, and implementation phases are linked.
- Team can identify where requirements, UI reference, content rules, and production checklist live.

## Phase 1: Architecture Restructure

Status: Completed.

Goal: Move the app toward the documented folder structure without breaking behavior.

Tasks:

- Create target folders under `lib/core`, `lib/shared`, `lib/data`, `lib/features`, `assets/content`, `tools`, and `test`.
- Move theme from `lib/config/theme` to `lib/core/theme` or update docs if the existing location is intentionally retained.
- Move routes into `lib/routes`.
- Rename/align feature folders to MVP names: `onboarding`, `today`, `prayers`, `rosary`, `novenas`, `library`, `settings`.
- Quarantine or remove non-MVP feature paths such as auth, saints, readings, and backend-facing placeholders.
- Add `asset_paths.dart` and `storage_keys.dart`.
- Keep app compiling after each move.

Done when:

- `flutter analyze` passes.
- `flutter test` passes.
- App still launches.
- Main navigation maps to Today, Pray, Novenas, Library.

## Phase 2: Design System From UI Reference

Status: Completed.

Goal: Implement the shared visual system before rebuilding screens.

Tasks:

- Define color tokens: cream background, navy primary, gold accent, muted text, border, card surface.
- Define typography for serif headings and readable prayer body text.
- Define spacing, radii, shadows, card borders, button sizes, and progress styling.
- Build shared widgets:
  - `app_bottom_nav.dart`
  - `app_card.dart`
  - `app_empty_state.dart`
  - `app_error_state.dart`
  - `app_loading.dart`
  - `app_search_bar.dart`
  - `prayer_text_view.dart`
  - `section_header.dart`
- Implement responsive constraints for 320 dp minimum width.

Done when:

- Shared widgets match screenshot patterns.
- Text does not overflow in mobile widths.
- Light theme matches reference screens.
- Dark theme support remains possible through theme tokens.

## Phase 3: Content Architecture

Status: Completed.

Goal: Replace older content shape with SRS-compliant bundled JSON.

Tasks:

- Create `assets/content/categories/categories.json`.
- Create prayer files under `assets/content/prayers/en/` and `assets/content/prayers/sw/`.
- Create Rosary files under `assets/content/rosary/en/` and `assets/content/rosary/sw/`.
- Create novena files under `assets/content/novenas/en/` and `assets/content/novenas/sw/`.
- Create metadata files under `assets/content/metadata/`.
- Update `pubspec.yaml` asset registration after directories exist.
- Implement `local_content_datasource.dart`.
- Implement JSON models and repositories for categories, prayers, Rosary, novenas, and settings.
- Add `tools/validate_content.dart`.

Done when:

- Content loads from `assets/content/`.
- Content validation catches missing fields, duplicate IDs, invalid language codes, unknown category references, and invalid novena day counts.
- Adding a valid prayer JSON entry requires no new screen code.

## Phase 4: Onboarding And Localization

Status: Completed.

Goal: Build first-launch language selection from the reference UI.

Tasks:

- Implement splash if needed.
- Implement English/Kiswahili language selection.
- Persist selected language locally.
- Add supported-language metadata.
- Localize UI strings.
- Reload content when language changes.

Done when:

- First-time user selects English or Kiswahili and reaches Today.
- Language can be changed in Settings.
- Language selection persists after restart.
- Missing translations show safe fallback or unavailable state.

## Phase 5: Today Screen

Status: Completed.

Goal: Build the daily entry point from the UI reference.

Tasks:

- Implement Today dashboard.
- Add today's prayer hero.
- Add continue-novena card.
- Add Rosary today card.
- Add quick actions grid.
- Add reminder status row.
- Connect cards to real routes and local state.

Done when:

- User can reach a prayer or Rosary within two taps.
- Active novena state appears when available.
- Reminder row reflects local reminder preference.

## Phase 6: Prayer Library And Search

Status: Completed.

Goal: Implement Pray and Library flows from bundled content.

Tasks:

- Build Pray category grid from category JSON.
- Build prayer list by category.
- Build prayer detail with title, body, source, and favorite action.
- Build offline search across title, body, tags, and category.
- Build Library screen with search, favorites carousel, recently opened, all prayers, offline content, settings, and about entries.
- Persist recently opened if retained from UI reference.

Done when:

- User can browse categories offline.
- User can open prayer detail offline.
- Search works offline.
- Empty and error states are readable and non-technical.

## Phase 7: Favorites

Status: Completed.

Goal: Persist favorite prayers locally.

Tasks:

- Implement favorites local storage.
- Add favorite/unfavorite action on prayer detail and list items where appropriate.
- Build Favorites screen from UI reference.
- Ensure favorites update Library carousel.

Done when:

- Favorites can be added, removed, displayed, and persist after restart.
- Invalid prayer IDs are ignored safely.

## Phase 8: Rosary

Status: Completed.

Goal: Build the Rosary home and guided step flow.

Tasks:

- Load Rosary prayers and mysteries from JSON.
- Suggest mystery based on local day.
- Build Rosary home screen.
- Build mystery selection screen.
- Build Rosary step screen with bead progress and controls.
- Persist `mystery_id` and `step_index`.
- Support next, previous, pause/save, restart, and continue.

Done when:

- User can start, continue, navigate, complete, and restart Rosary offline.
- Corrupt progress resets with a friendly message.
- Progress survives leaving the screen or app backgrounding where practical.

## Phase 9: Novenas

Status: Completed.

Goal: Build novena browsing, progress, and day reading.

Tasks:

- Load novena JSON by language.
- Build Novenas list with active novena hero.
- Build Novena detail with nine day rows.
- Build Novena day reading screen.
- Persist active novena and completed days.
- Connect active novena to Today.

Done when:

- User can start a novena, mark days complete, and continue from Today.
- Completed, current, locked/not-started, and open states match reference screens.
- Invalid day values are rejected or safely reset.

## Phase 10: Reminders And Settings

Status: Completed.

Goal: Implement local reminders and user preferences.

Tasks:

- Add local notification plugin and isolate platform details.
- Implement reminder enable, change, and disable.
- Handle notification permission denial gracefully.
- Implement settings for language, font size, theme, reminder, About, and content sources.
- Implement About screen from UI reference.

Done when:

- Daily reminder can be scheduled, changed, and disabled.
- Settings persist after app restart.
- App requests only notification permission where required.
- About includes app version, developer, open-source note, content sources, disclaimer, and contact/website.

## Phase 11: Offline And Lifecycle Hardening

Goal: Prove the offline-first MVP behavior.

Tasks:

- Run airplane-mode regression for onboarding, Today, prayers, search, favorites, Rosary, novenas, and settings.
- Save Rosary and novena progress on navigation/background lifecycle where practical.
- Handle corrupt local storage values.
- Ensure external links fail gracefully when offline.

Done when:

- Core MVP works without internet.
- Bad local progress does not crash the app.
- Manual offline checklist passes.

## Phase 12: Testing

Goal: Cover core behavior with focused tests.

Tasks:

- Unit tests:
  - content loader,
  - validation,
  - repositories,
  - search,
  - Rosary service,
  - novena progress.
- Widget tests:
  - language selection,
  - prayer detail,
  - prayer list,
  - novena day,
  - Rosary step.
- Integration tests:
  - app startup,
  - offline prayer flow,
  - novena progress.

Done when:

- `flutter analyze` passes.
- `flutter test` passes.
- Critical user flows have regression coverage.

## Phase 13: Android Release Preparation

Goal: Prepare Android-first MVP release.

Tasks:

- Replace example package ID.
- Confirm Android minimum SDK and target SDK requirements at release time.
- Add app icon and launch assets.
- Configure signing for release builds.
- Review Android permissions.
- Build release AAB.
- Prepare Google Play internal testing metadata.

Done when:

- Release app bundle builds successfully.
- Permission review passes.
- Internal testing build is ready.

## Phase 14: iOS Readiness

Goal: Keep iOS supported by the same Flutter codebase.

Tasks:

- Confirm iOS minimum version.
- Review notification permission copy.
- Add iOS app icon and launch assets.
- Review external links and privacy policy.
- Build for iOS when Apple release is in scope.

Done when:

- iOS build path is documented and not blocked by Android-only assumptions.

## Phase 15: Store Compliance And Production Readiness

Goal: Complete release checklist.

Tasks:

- Verify support link.
- Verify privacy policy link.
- Verify content sources and rights.
- Verify no unapproved copyrighted content.
- Verify no unnecessary permissions.
- Run 2-hour exploratory core-flow QA.
- Check startup, prayer detail, and search performance.
- Version app semantically.
- Prepare release notes and known limitations.

Done when:

- Store readiness checklist passes.
- Core MVP acceptance criteria pass.
- Production candidate is ready for internal QA or store submission.
