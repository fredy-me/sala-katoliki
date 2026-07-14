# Sala Katoliki / Catholic Prayer

Flutter mobile application for Catholic prayers, built from the MVP SRS prepared for Kilimanjaro Technology on 2 June 2026.

The SRS PDF is the product source of truth:

`/home/meck/Downloads/Sala_Katoliki_MVP_SRS_Kilimanjaro_Technology.pdf`

When project code, UI, or docs conflict with that SRS, the SRS wins unless Kilimanjaro Technology approves a new written requirement.

## MVP Scope

Sala Katoliki is an offline-first mobile app. It must provide essential Catholic prayer resources without account registration, backend dependency, paid features, or media-heavy content.

Required MVP features:

- First-launch language selection for English and Kiswahili.
- Today screen with quick access to prayer actions.
- Common Catholic prayer library loaded from bundled JSON.
- Interactive Rosary with mystery selection by day and step-by-step progress.
- Novenas with 9-day progress tracking.
- Favorites, offline search, and local reminder notifications.
- Settings for language, reminders, font size, theme, About, and content sources.
- Local bundled content architecture that allows adding prayers without creating new screens.
- Android-first release, with iOS supported by the Flutter codebase.

Explicitly out of scope for the MVP:

- Authentication, registration, profiles, cloud sync, or social sign-in.
- Backend CMS, admin dashboard, real-time content management, or remote database dependency.
- Payments, donations, subscriptions, ads, or monetization.
- Audio, video, podcasts, guided meditation library, full Bible, full Catechism, Mass booking, parish management, or sacrament scheduling.
- Community posting, chat, comments, AI spiritual advisor, or pastoral automation.
- Copyrighted Bible translations, Mass readings, or devotional material without written permission or valid licensing.

## Documentation

- [SRS Alignment](docs/SRS_ALIGNMENT.md) defines how this repository follows the PDF.
- [Architecture](docs/ARCHITECTURE.md) documents the required clean, offline-first architecture.
- [Folder Structure](docs/architecture/folder_structure.md) is the canonical target structure for the Flutter app, assets, tests, tools, and docs.
- [Content Architecture](docs/architecture/content_architecture.md) explains how bundled prayer, Rosary, novena, and metadata content is organized.
- [Data Models](docs/architecture/data_models.md) documents the MVP JSON models.
- [Content Guide](docs/CONTENT_GUIDE.md) documents the bundled JSON content model and contribution rules.
- [Adding New Prayers](docs/content_guidelines/adding_new_prayers.md) documents the no-hard-coded-prayer workflow.
- [Translation Guidelines](docs/content_guidelines/translation_guidelines.md) documents English/Kiswahili content rules.
- [Content Rights](docs/content_guidelines/content_rights.md) documents source and licensing requirements.
- [UI Reference](docs/ui_reference.md) documents the provided mobile screenshots and visual rules.
- [Implementation Plan](IMPLEMENTATION_PLAN.md) is the single roadmap, implementation-status, acceptance, and release-readiness record.
- [Android Release Preparation](docs/release/android_release_preparation.md) documents Android package identity, signing, permissions, and AAB preparation.
- [Google Play Internal Testing Metadata](docs/release/google_play_internal_testing.md) contains the first internal testing listing draft.
- [Requirements Traceability](docs/REQUIREMENTS_TRACEABILITY.md) links to the canonical requirement-status and acceptance record.

## Architecture Summary

The MVP architecture is intentionally simple:

```text
Flutter Mobile App
  -> State Manager
  -> Content Repository
  -> Bundled JSON Assets
  -> Dynamic UI Rendering
  -> Local Device Storage
```

Required separation:

- `presentation`: screens, widgets, view state, navigation.
- `domain`: app entities, repository contracts, use cases, business rules.
- `data/content`: JSON models, content loading, repositories.
- `local storage`: preferences, favorites, Rosary progress, novena progress, reminders.

Future remote content support may be added behind repository interfaces, but the MVP must work fully without internet.

## Current Project Shape

The app is a Flutter project using:

- Flutter and Dart.
- Riverpod for explicit, testable state.
- Go Router for navigation.
- Shared preferences for local persistence.
- Easy localization for UI language support.
- Bundled assets under `assets/`.

Some folders and placeholders may still reflect earlier planning. During restructuring, keep only SRS-approved MVP modules in the main implementation path.

## Content Rules

Prayer, category, Rosary, and novena content must be data-driven. UI screens must not hard-code one screen per prayer.

Recommended content structure from the SRS:

```text
assets/
  content/
    categories/
      categories.json
    prayers/
      en/
        common_prayers.json
        marian_prayers.json
        confession_prayers.json
        mass_prayers.json
        divine_mercy.json
      sw/
        common_prayers.json
        marian_prayers.json
        confession_prayers.json
        mass_prayers.json
        divine_mercy.json
    novenas/
      en/
        divine_mercy_novena.json
      sw/
        divine_mercy_novena.json
    rosary/
      en/
        rosary_prayers.json
        mysteries.json
      sw/
        rosary_prayers.json
        mysteries.json
    metadata/
      languages.json
      content_manifest.json
      app_info.json
```

Required prayer fields:

- `id`
- `type`
- `category`
- `language`
- `title`
- `body`

Recommended metadata:

- `description`
- `tags`
- `source`
- `version`
- `last_updated`
- `is_offline_available`

## Development

Install dependencies:

```bash
flutter pub get
```

Analyze:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run app:

```bash
flutter run
```

## Acceptance Baseline

Before MVP release, the app must satisfy these SRS acceptance areas:

- First-time user selects English or Kiswahili and reaches Today.
- Airplane-mode user can open prayers, search, use Rosary, use novenas, and view favorites.
- Common prayers are loaded from JSON, not hard-coded in screen files.
- A new valid prayer JSON entry appears without creating a new screen.
- Favorites and settings persist after restart.
- Rosary can start, navigate next/previous, exit, continue, and restart.
- Novena can start, mark days complete, and continue from Today.
- Daily reminder can be scheduled, changed, and disabled.
- App does not request camera, microphone, contacts, location, NFC, Bluetooth, or biometric permissions.
- Store readiness includes support link, privacy policy link, content attribution, and minimal permission declaration.
