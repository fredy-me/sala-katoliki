# Sala Katoliki / Catholic Prayer

An open-source, offline-first Catholic prayer app for mobile. Built with Flutter for Catholic faithful worldwide who want free, ad-free, privacy-respecting prayer resources.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Flutter](https://img.shields.io/badge/Flutter-%5E3.10.4-blue.svg)](https://flutter.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Issues Welcome](https://img.shields.io/badge/Issues-welcome-orange.svg)](../../issues)
[![Google Play](https://img.shields.io/badge/Google%20Play-Get%20App-green.svg)](https://play.google.com/store/apps/details?id=com.busaradigital.salakatoliki)

## What It Does

- Daily prayers, Rosary, and novenas in English and Kiswahili
- Works completely offline - no internet required
- Favorites, search, and daily reminders
- No accounts, no ads, no tracking, no data collection

## Why It Exists

- Free and open-source under GPL-3.0
- Privacy-first: all data stays on your device
- Community-driven: contributions welcome from developers and content creators

## Project Status

**Live on Google Play Store** - [Download App](https://play.google.com/store/apps/details?id=com.busaradigital.salakatoliki)

- 6 releases shipped
- Android production ready
- iOS support planned
- See [Implementation Plan](IMPLEMENTATION_PLAN.md) for detailed status

## Source of Truth

The SRS PDF is the product source of truth:

[docs/srs/Sala_Katoliki_MVP_SRS_Busara_Digital.md](docs/srs/Sala_Katoliki_MVP_SRS_Busara_Digital.md)

When project code, UI, or docs conflict with that SRS, the SRS wins unless Busara Digital approves a new written requirement.

## Features

### Core Features

- First-launch language selection for English and Kiswahili.
- Today screen with quick access to prayer actions.
- Common Catholic prayer library loaded from bundled JSON.
- Interactive Rosary with mystery selection by day and step-by-step progress.
- Novenas with 9-day progress tracking.
- Favorites, offline search, and local reminder notifications.
- Settings for language, reminders, font size, theme, About, and content sources.
- Local bundled content architecture that allows adding prayers without creating new screens.
- Android release, with iOS planned.

### Not Included (By Design)

- Authentication, registration, profiles, cloud sync, or social sign-in.
- Backend CMS, admin dashboard, real-time content management, or remote database dependency.
- Payments, donations, subscriptions, ads, or monetization.
- Audio, video, podcasts, guided meditation library, full Bible, full Catechism, Mass booking, parish management, or sacrament scheduling.
- Community posting, chat, comments, AI spiritual advisor, or pastoral automation.
- Copyrighted Bible translations, Mass readings, or devotional material without written permission or valid licensing.

## Tech Stack

- **Framework:** Flutter and Dart
- **State Management:** Riverpod
- **Navigation:** Go Router
- **Local Storage:** SharedPreferences
- **Localization:** Riverpod-based (English/Kiswahili)
- **Content:** Bundled JSON under `assets/`

## Architecture

```text
Flutter Mobile App
  -> State Manager
  -> Content Repository
  -> Bundled JSON Assets
  -> Dynamic UI Rendering
  -> Local Device Storage
```

### Layer Separation

- `presentation`: screens, widgets, view state, navigation.
- `domain`: app entities, repository contracts, use cases, business rules.
- `data/content`: JSON models, content loading, repositories.
- `local storage`: preferences, favorites, Rosary progress, novena progress, reminders.

Future remote content support may be added behind repository interfaces, but the app must work fully without internet.

## Content Structure

Prayer, category, Rosary, and novena content must be data-driven. UI screens must not hard-code one screen per prayer.

```text
assets/
  content/
    categories/
      categories.json
    prayers/
      en/
        common_prayers.json
        confession_prayers.json
        divine_mercy.json
        litanies.json
        marian_prayers.json
        mass_prayers.json
      sw/
        common_prayers.json
        confession_prayers.json
        divine_mercy.json
        litanies.json
        marian_prayers.json
        mass_prayers.json
    novenas/
      en/
        all_saints_day_novena.json
        divine_mercy_novena.json
        holy_family_novena.json
        holy_spirit_novena.json
        litany_of_trust_novena.json
        sacred_heart_of_jesus_novena.json
        st_aloysius_gonzaga_novena.json
        st_jude_novena.json
        st_rita_novena.json
      sw/
        all_saints_day_novena.json
        divine_mercy_novena.json
        holy_family_novena.json
        holy_spirit_novena.json
        litany_of_trust_novena.json
        sacred_heart_of_jesus_novena.json
        st_aloysius_gonzaga_novena.json
        st_jude_novena.json
        st_rita_novena.json
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

### Required Prayer Fields

- `id`
- `type`
- `category`
- `language`
- `title`
- `body`

### Recommended Metadata

- `description`
- `tags`
- `source`
- `version`
- `last_updated`
- `is_offline_available`

## Development

### Prerequisites

- Flutter SDK ^3.10.4
- Dart SDK ^3.10.4
- Android Studio or VS Code with Flutter extension
- Physical Android device or emulator (API level 24+)

### Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/salakatoliki.git
cd salakatoliki

# Install dependencies
flutter pub get

# Copy environment template (optional, for development)
cp .env.example .env
```

### Development Commands

| Command | Description | When to Run |
|---------|-------------|-------------|
| `flutter pub get` | Install dependencies | After cloning or changing pubspec.yaml |
| `flutter analyze` | Check code for issues | Before every commit |
| `flutter test` | Run unit and widget tests | Before every commit |
| `flutter run` | Run app on connected device | During development |
| `dart run tools/validate_content.dart` | Validate bundled JSON content | After changing content files |
| `flutter test integration_test/` | Run integration tests | Before submitting PR |

### Content Validation

After modifying any JSON content files, always run the validator:

```bash
dart run tools/validate_content.dart
```

This checks:
- All required fields are present
- Language codes are valid (en/sw)
- No duplicate IDs exist
- Category references are valid
- Novena day counts are correct
- Rosary step references are valid

### Integration Tests

Run integration tests on a connected device or emulator:

```bash
flutter test integration_test/
```

### Environment Configuration

The app supports environment configuration via `.env` files. See `.env.example` for available options:

```bash
cp .env.example .env
# Edit .env with your local values
```

Run with environment:

```bash
flutter run --dart-define-from-file=.env
```

## Contributing

We welcome contributions from developers and content creators. Please read our contributing guidelines before submitting any changes.

- [Contributing Guide](CONTRIBUTING.md) - How to contribute code, content, or documentation
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community standards and expectations
- [License](LICENSE) - GPL-3.0 license terms

### Quick Start for Contributors

1. Read the [Contributing Guide](CONTRIBUTING.md)
2. Open an issue describing your change
3. Wait for maintainer approval
4. Create a branch and make your changes
5. Submit a pull request

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/ARCHITECTURE.md) | Clean, offline-first architecture documentation |
| [Folder Structure](docs/architecture/folder_structure.md) | Target structure for the Flutter app |
| [Content Architecture](docs/architecture/content_architecture.md) | How bundled content is organized |
| [Data Models](docs/architecture/data_models.md) | MVP JSON models |
| [Content Guide](docs/CONTENT_GUIDE.md) | Bundled JSON content model and rules |
| [Adding New Prayers](docs/content_guidelines/adding_new_prayers.md) | No-hard-coded-prayer workflow |
| [Translation Guidelines](docs/content_guidelines/translation_guidelines.md) | English/Kiswahili content rules |
| [Content Rights](docs/content_guidelines/content_rights.md) | Source and licensing requirements |
| [UI Reference](docs/ui_reference.md) | Mobile screenshots and visual rules |
| [Implementation Plan](IMPLEMENTATION_PLAN.md) | Roadmap and release-readiness record |
| [Android Release](docs/release/android_release_preparation.md) | Package identity, signing, permissions |
| [Google Play Metadata](docs/release/google_play_internal_testing.md) | Internal testing listing draft |
| [Requirements Traceability](docs/REQUIREMENTS_TRACEABILITY.md) | Requirement-status and acceptance record |
| [Screenshots](docs/screenshots/) | App screenshots for documentation |

## Quality Standards

The app meets these standards:

- First-time user selects English or Kiswahili and reaches Today.
- Offline user can open prayers, search, use Rosary, use novenas, and view favorites.
- Common prayers are loaded from JSON, not hard-coded in screen files.
- A new valid prayer JSON entry appears without creating a new screen.
- Favorites and settings persist after restart.
- Rosary can start, navigate next/previous, exit, continue, and restart.
- Novena can start, mark days complete, and continue from Today.
- Daily reminder can be scheduled, changed, and disabled.
- App does not request camera, microphone, contacts, location, NFC, Bluetooth, or biometric permissions.
- Store listing includes support link, privacy policy link, content attribution, and minimal permission declaration.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Developed By

**Busara Digital**
