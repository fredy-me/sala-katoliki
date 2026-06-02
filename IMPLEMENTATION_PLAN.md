# Sala Katoliki MVP Implementation Plan

This plan follows the Sala Katoliki MVP SRS prepared for Kilimanjaro Technology on 2 June 2026. The SRS PDF is the source of truth:

`/home/meck/Downloads/Sala_Katoliki_MVP_SRS_Kilimanjaro_Technology.pdf`

The UI reference source is:

`/home/meck/Desktop/Sala-picturesUI`

The production roadmap is documented in [docs/implementation_phases.md](docs/implementation_phases.md).

Do not add out-of-scope features to the MVP implementation path without a written requirement change.

## Product Goal

Build an offline-first Catholic prayer mobile app in Flutter that helps users access essential prayers, Rosary guidance, novenas, favorites, search, reminders, and settings in English and Kiswahili.

The MVP must not require authentication, a backend, payment, ads, media content, community features, or copyrighted content without approval.

## Current State

- Flutter app shell exists.
- Riverpod, Go Router, `intl`, `shared_preferences`, and `easy_localization` are present.
- Routing, theme, onboarding, home, settings, Rosary placeholder, and prayer library screens exist.
- Prayer library currently uses `assets/data/prayers.json`, but the schema does not yet match the SRS recommended content structure.
- Some folders from earlier planning reference non-MVP areas such as auth, saints, notifications, and readings. These must not drive MVP work unless they are converted into SRS-compliant modules or removed during restructuring.

## Development Principles

- Build offline-first before any remote capability.
- Load prayer, category, Rosary, and novena content from JSON assets.
- Keep UI, domain logic, content loading, and local storage separated.
- Use repository interfaces so future remote content can be added behind the same contract.
- Persist only low-sensitivity local data: language, theme, font size, favorites, reminders, Rosary progress, and novena progress.
- Request only notification permission when needed.
- Validate content fields, language codes, IDs, and duplicate IDs through tests or scripts.
- Treat content source and licensing metadata as release-blocking.

## Target Structure

The detailed canonical structure is documented in [docs/architecture/folder_structure.md](docs/architecture/folder_structure.md). Summary:

```text
lib/
  app.dart
  main.dart
  bootstrap.dart
  config/
    app_config.dart
    environment.dart
  routes/
    app_router.dart
    route_names.dart
  core/
    constants/
    theme/
    localization/
    errors/
    utils/
  shared/
    widgets/
    models/
    services/
  data/
    models/
    repositories/
    datasources/
  features/
    onboarding/
      presentation/
    today/
      presentation/
    prayers/
      presentation/
      domain/
    rosary/
      presentation/
      domain/
    novenas/
      presentation/
      domain/
    library/
      presentation/
      domain/
    settings/
      presentation/
      domain/
assets/
  content/
    categories/
    prayers/
    novenas/
    rosary/
    metadata/
  images/
  translations/
docs/
  architecture/
  content_guidelines/
tools/
```

## Phase 1: Documentation Baseline

Status: Completed.

Tasks:

- Replace README claims that conflict with the SRS.
- Add architecture documentation.
- Add content contribution and schema documentation.
- Add requirements traceability documentation.
- Keep implementation plan aligned to the SRS.

Acceptance checks:

- README states the PDF as source of truth.
- MVP scope and out-of-scope features match the SRS.
- Architecture docs describe offline-first bundled JSON and local storage.
- Content docs describe required fields and validation rules.

## UI Reference Baseline

Status: Completed.

Reference folder:

`/home/meck/Desktop/Sala-picturesUI`

Documented in [docs/ui_reference.md](docs/ui_reference.md).

The screenshots define these MVP UI targets:

- Language selection in English and Kiswahili.
- Today dashboard.
- Pray category grid.
- Holy Rosary home and Rosary step flow.
- Novenas list, novena progress, and novena day reading.
- Library, Favorites, About, Settings entry points.
- Cream background, dark navy primary surfaces, gold accent actions, serif headings, rounded white cards, and four-tab bottom navigation.

## Phase 2: Design System From UI Reference

Status: Completed.

Implemented:

- Light-first cream/navy/gold theme tokens.
- Dark theme support through the same token structure.
- Shared spacing and text-style constants.
- Reusable bottom navigation, cards, empty/error/loading states, search bar, prayer text view, and section header widgets.
- Existing shell and prayer flow now use the shared design-system widgets where practical.

## Phase 2: SRS-Aligned App Skeleton

Status: Completed as the Phase 1 architecture restructure baseline.

Tasks:

- Rename or align navigation tabs to Today, Pray, Novenas, Library.
- Keep first-launch language selection as the entry flow.
- Remove or quarantine non-MVP navigation for auth, saints, daily readings, backend sync, and media.
- Ensure Settings includes language, reminder, font size, theme, About, and content sources.

Acceptance checks:

- First-time user can choose English or Kiswahili and reach Today.
- Main tabs match the SRS.
- No MVP screen requires account login or internet.

## Phase 3: Bundled Content System

Status: Completed.

Tasks:

- Move content to the SRS structure under `assets/content/`.
- Implement category JSON loading.
- Implement prayer JSON loading by language and category.
- Implement Rosary JSON loading by language.
- Implement novena JSON loading by language.
- Add content validation tests or scripts for required fields, duplicate IDs, valid language codes, and valid category references.

Acceptance checks:

- Common prayers load from JSON, not screen files.
- Adding a valid prayer JSON entry shows it in category and search without a new screen.
- Invalid content fails validation during development.
- Missing translations show fallback or safe unavailable state.

## Phase 4: Prayer Library, Favorites, And Search

Tasks:

- Implement category list from JSON.
- Implement prayer list filtered by language and category.
- Implement prayer detail with title, body, source, category, and favorite state.
- Implement local favorites persistence.
- Implement offline search across title, body, tags, and category.

Acceptance checks:

- User can browse prayers offline.
- User can open prayer detail offline.
- Favorites can be added, removed, displayed, and persist after restart.
- Search works offline and handles empty/no-match states.

## Phase 5: Rosary

Tasks:

- Define mysteries and step sequence in content/data files.
- Suggest mystery from local day.
- Implement next, previous, restart, exit, and continue.
- Persist mystery ID and current step locally.
- Reset corrupt saved progress with a friendly message.

Acceptance checks:

- User can start and complete a Rosary offline.
- Progress survives leaving the screen or app backgrounding where possible.
- User can restart and clear progress.

## Phase 6: Novenas

Tasks:

- Define novena model with 9 day objects.
- Implement novena list, detail, start, mark day complete, and continue.
- Persist active novena ID and completed days locally.
- Show active novena continuation on Today.

Acceptance checks:

- User can start a novena offline.
- User can mark Day 1-Day 9 complete.
- Active progress is visible from Today.
- Invalid day values are rejected or safely reset.

## Phase 7: Reminders And Settings

Tasks:

- Add local notification scheduling for daily reminders.
- Add reminder enable, change, and disable.
- Add language, font size, theme, About, content source, support, and privacy policy entries.
- Handle notification permission denial gracefully.

Acceptance checks:

- Reminder can be scheduled, changed, and disabled.
- Settings persist after app restart.
- Tapping reminder opens the app, preferably Today or active novena when feasible.
- App requests no permission except notification permission where required.

## Phase 8: QA And Release Readiness

Tasks:

- Run airplane-mode regression testing.
- Run 2-hour exploratory core-flow QA.
- Verify Android minimum and target SDK requirements at release time.
- Verify iOS minimum support if iOS release is included.
- Verify content source/permission status.
- Verify support link, privacy policy link, content attribution, and external links.
- Prepare Android internal testing build and optional iOS TestFlight build.

Acceptance checks:

- Core prayer features work offline.
- No crash in normal core flows during exploratory QA.
- App size remains text-first and lightweight.
- Store checklist is complete.

## Future Backlog

Only after MVP validation:

- Backend or CMS.
- Remote content updates.
- User accounts and cloud sync.
- Audio prayers.
- Full Bible.
- Daily Mass readings with licensed source.
- Community features.
- AI spiritual assistant.
- Donations or subscriptions.
