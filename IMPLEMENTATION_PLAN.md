# Sala Katoliki Implementation Plan

This document is the local development reference for building Sala Katoliki from the README specification. Keep it updated as decisions change.

## Current State

- Phase 1 foundation has started.
- `lib/main.dart` now boots `SalaKatolikiApp` inside Riverpod `ProviderScope`.
- `pubspec.yaml` includes Riverpod, Go Router, `intl`, and `shared_preferences`.
- The README defines the intended product, architecture, tech stack, and roadmap.
- App routing, dark theme, onboarding, home dashboard, bottom navigation, and placeholder feature screens are implemented.
- No real app content, localization files, local database, real auth, or backend integration are implemented yet.

## Product Goal

Build a calm, offline-first Catholic prayer app for African Catholics with:

- Prayer library in English and Swahili
- Interactive rosary
- Daily Mass readings
- Saints and feast days
- Favorites and bookmarks
- Guest-first usage
- Optional account sync
- Settings for language, theme, notifications, and reading preferences

## Development Principles

- Start useful offline before adding cloud sync.
- Do not force login before users can access spiritual content.
- Keep feature folders independent.
- Keep business logic outside widgets.
- Prefer simple local content flows before integrating Supabase and Firebase.
- Match the shared Screen UI folder once available.

## Target Architecture

Use feature-first clean architecture:

```text
lib/
  app.dart
  main.dart
  config/
    routes/
    theme/
    constants/
  core/
    errors/
    extensions/
    services/
    utils/
  features/
    home/
      data/
      domain/
      presentation/
    prayer_library/
      data/
      domain/
      presentation/
    rosary/
      data/
      domain/
      presentation/
    daily_readings/
      data/
      domain/
      presentation/
    saints/
      data/
      domain/
      presentation/
    favorites/
      data/
      domain/
      presentation/
    settings/
      data/
      domain/
      presentation/
    auth/
      data/
      domain/
      presentation/
assets/
  data/
  translations/
  images/
```

## Phase 0: UI And Content Inputs

Reference UI location:

- `/home/meck/Desktop/Sala-picturesUI`

Current reference screens:

- Onboarding slide: daily Catholic prayer
- Onboarding slide: offline usage
- Onboarding slide: English and Swahili with guest/account actions
- Home dashboard with quick access cards and bottom navigation

Auth decision:

- Authentication will be mocked until the end of the project.
- Early phases must support guest-first usage and placeholder auth actions only.

Still collect:

- Logo/app icon if available
- Prayer content sources
- Swahili translations
- Daily readings source decision
- Saints and feast day content source

Notes when Screen UI folder is shared:

- Review every screen before coding layout.
- Extract shared design rules: colors, spacing, typography, navigation patterns, button styles, cards, empty states, loading states.
- Update this plan with exact screen list and implementation order.

## Phase 1: App Foundation

Status: Implemented as the first app shell. Keep refining as more UI references arrive.

Tasks:

- Replace the default counter app.
- Add core dependencies:
  - `flutter_riverpod`
  - `go_router`
  - `intl`
  - `shared_preferences`
  - localization package
- Create `lib/app.dart`.
- Create app theme using README colors.
- Create initial route structure.
- Create shell navigation for Home, Prayers, Rosary, and Menu.
- Create placeholder screens matching the final app sections.

Acceptance checks:

- App launches without the default Flutter demo UI.
- Navigation works between main sections.
- Theme is consistent and calm.
- `flutter analyze` passes.
- `flutter test` passes.

## Phase 2: Local Offline Content MVP

Tasks:

- Create bundled JSON files:
  - `assets/data/prayers.json`
  - `assets/data/saints.json`
  - `assets/data/readings.json`
- Register assets in `pubspec.yaml`.
- Implement prayer entity/model.
- Implement local JSON data source for prayers.
- Implement prayer repository.
- Implement Riverpod providers for prayer list, categories, and prayer detail.
- Build Prayer Library screen.
- Build Prayer Detail screen.
- Add search and category filtering.

Acceptance checks:

- User can open app and browse prayers offline.
- User can search prayers.
- User can open a prayer detail page.
- Missing/empty content has a graceful UI.

## Phase 3: Favorites And Settings

Tasks:

- Add local persistence for favorites.
- Add favorite/unfavorite action on prayer details.
- Build Favorites screen.
- Add settings persistence:
  - language
  - theme mode
  - notification preference placeholder
  - text size or reading comfort options
- Add light, dark, and optional sepia modes.

Acceptance checks:

- Favorites survive app restart.
- Settings survive app restart.
- Guest mode can use favorites locally.

## Phase 4: Rosary

Tasks:

- Define rosary mysteries and daily mystery rules.
- Define rosary progress state.
- Build interactive rosary screen:
  - current mystery
  - current prayer
  - bead progress
  - next/back/reset controls
- Persist in-progress rosary locally.

Acceptance checks:

- User can complete a rosary without internet.
- Progress is visually clear.
- App can restore unfinished progress.

## Phase 5: Daily Readings And Saints

Tasks:

- Implement readings entity/model.
- Implement local readings repository.
- Build Daily Readings screen.
- Add date selection/archive.
- Implement saints entity/model.
- Build Saints screen.
- Build Saint Detail screen.
- Add saint of the day logic.

Acceptance checks:

- Today readings load from local content.
- Saints can be browsed by date/month.
- Saint detail page displays biography, feast day, and prayer/quote if available.

## Phase 6: Localization

Tasks:

- Add English and Swahili translation files.
- Localize all UI strings.
- Confirm content model supports English and Swahili fields.
- Add language setting.

Acceptance checks:

- User can switch English/Swahili.
- Prayer content changes language where translation exists.
- Missing translations have a clear fallback.

## Phase 7: Auth And Cloud Sync

Tasks:

- Add Supabase configuration.
- Add environment config handling.
- Implement auth:
  - guest mode
  - email/password
  - optional Google/Apple later
- Sync favorites and settings for authenticated users.
- Keep local-first behavior when offline.

Acceptance checks:

- App works without account.
- User can sign up/login when online.
- Local favorites can sync after login.
- Offline behavior remains usable.

## Phase 8: Notifications

Tasks:

- Add Firebase setup.
- Add notification permission flow.
- Add daily prayer/readings reminder settings.
- Add local notification scheduling if appropriate.

Acceptance checks:

- User can enable/disable reminders.
- Notifications are respectful and not aggressive.
- App handles notification taps correctly.

## Phase 9: Quality, Release, And Store Prep

Tasks:

- Replace app package id from `com.example.salakatoliki`.
- Add app icon and splash screen.
- Add privacy policy.
- Add Play Store metadata.
- Add CI for analyze/test/build.
- Add release signing configuration.
- Add integration tests for critical flows.

Acceptance checks:

- Android release build succeeds.
- Analyzer and tests pass in CI.
- App has production identity and assets.

## First Coding Milestone

The first useful coding target should be:

1. App foundation with real theme and navigation.
2. Home screen placeholder based on Screen UI reference.
3. Prayer Library using bundled local JSON.
4. Prayer Detail screen.
5. Local favorites.

This gives users immediate value without waiting for Supabase, Firebase, or full content completion.

## Open Decisions

- Exact Screen UI folder path.
- Exact app package id.
- Preferred localization package.
- Whether to use Isar immediately or start with bundled JSON plus `shared_preferences`.
- Source and licensing for prayers, readings, and saints.
- Whether daily readings are bundled yearly, fetched from an API, or managed in Supabase.
- Whether notifications use Firebase only, local notifications, or both.

## Developer Checklist Before Each Phase

- Read README section related to the phase.
- Review Screen UI reference for affected screens.
- Keep changes scoped to the current phase.
- Add or update tests where behavior is introduced.
- Run `flutter analyze`.
- Run `flutter test`.
- Update this plan when implementation reality changes.
