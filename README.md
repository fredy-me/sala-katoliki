# 🙏 Sala Katoliki - Catholic Prayer App

> **"This app understands my spiritual life."**

A modern, offline-first Catholic prayer application designed for African Catholics. Built with Flutter, optimized for peace, trust, and daily spiritual practice.

**Status:** Open Source (MIT License)  
**Target:** Google Play Store → App Store (iOS)  
**Platform:** Mobile-first (Flutter)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Navigation Architecture](#navigation-architecture)
6. [Data Flow](#data-flow)
7. [Setup & Installation](#setup--installation)
8. [Development Guidelines](#development-guidelines)
9. [Testing Strategy](#testing-strategy)
10. [CI/CD Pipeline](#cicd-pipeline)
11. [Deployment](#deployment)
12. [Design Philosophy](#design-philosophy)
13. [Contributing](#contributing)
14. [License](#license)

---

## Overview

**Sala Katoliki** is a comprehensive Catholic prayer platform that brings:

- ✅ **200+ prayers** in English & Swahili
- ✅ **Interactive rosary** with visual guidance
- ✅ **Daily Mass readings** (365 days)
- ✅ **Saints & feast days** calendar
- ✅ **Offline-first** (works without internet)
- ✅ **Zero friction** onboarding (guest mode)
- ✅ **Cloud sync** (optional account)
- ✅ **Beautiful, calm UX** (meditation app quality)

### Core Philosophy

This app is **not** a feature checklist. It's a **spiritual sanctuary** designed with these principles:

- **Peace first** — Every interaction feels calm, intentional, meditative
- **Usefulness immediately** — Users find value within 30 seconds
- **Trust through simplicity** — No dark patterns, no engagement hacking
- **Offline respect** — Works perfectly without internet (critical in Africa)
- **Emotional resonance** — The app remembers what users care about

---

## Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    SALA KATOLIKI APP (Flutter)              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Presentation Layer (UI/UX)                  │  │
│  │  ├─ Screens (Home, Prayer Library, Rosary, etc.)    │  │
│  │  ├─ Widgets (Prayer Cards, Rosary Beads, etc.)      │  │
│  │  └─ Theme (Light/Dark/Sepia modes)                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │     Domain Layer (Business Logic & Use Cases)        │  │
│  │  ├─ Entities (Prayer, User, Reading, Saint, etc.)   │  │
│  │  ├─ Repositories (Abstract interfaces)              │  │
│  │  └─ Use Cases (GetPrayers, SaveFavorite, etc.)      │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │      Data Layer (Repositories & Data Sources)        │  │
│  │  ├─ Remote: Supabase API (REST/Real-time)           │  │
│  │  ├─ Local: Isar Database (offline caching)          │  │
│  │  └─ Auth: Supabase Authentication                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │      External Services & State Management            │  │
│  │  ├─ Riverpod (state management & DI)                │  │
│  │  ├─ Firebase Cloud Messaging (notifications)        │  │
│  │  ├─ Analytics (optional, privacy-first)             │  │
│  │  └─ Local Storage (SharedPreferences)               │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↓                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Backend Services (Cloud)                   │  │
│  │  ├─ Supabase PostgreSQL (prayers, users, readings)  │  │
│  │  ├─ Supabase Auth (email, OAuth, anonymous)         │  │
│  │  ├─ Supabase Storage (user uploads - Phase 2)       │  │
│  │  └─ Firebase Cloud Messaging (push notifications)   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Layered Architecture Explanation

**Presentation Layer (UI)**
- Manages all screens and widgets
- Receives user input
- Displays data through Riverpod listeners
- NO business logic (separated from domain)

**Domain Layer (Business Logic)**
- Defines core business rules
- Abstract repositories (interfaces only)
- Use cases encapsulate business operations
- Independent of frameworks

**Data Layer (Repositories)**
- Implements repository interfaces
- Manages remote (Supabase) and local (Isar) data
- Handles caching strategy
- Provides clean data to domain layer

**External Services**
- State management (Riverpod)
- Dependency injection
- Notifications (FCM)
- Analytics (privacy-first)

---

## Tech Stack

### Frontend Framework
- **Flutter 3.x** (latest stable)
  - *Why:* Single codebase for iOS/Android, exceptional performance, beautiful UI out of box

### State Management
- **Riverpod 2.x**
  - *Why:* Modern, reactive, compile-time safe, excellent for DI, no boilerplate
  - Providers for: User state, prayers, readings, favorites, theme, notifications

### Offline Database
- **Isar 3.x**
  - *Why:* Relational, extremely fast (native Dart), great for Flutter, supports complex queries
  - Stores: Prayers, readings, favorites, user progress, cached content

### HTTP Client
- **Dio 5.x**
  - *Why:* Request/response interceptors, timeout handling, retry logic, easy testing

### Authentication
- **Supabase Auth** (via supabase_flutter package)
  - *Why:* Email/password, Google OAuth, Apple ID, anonymous → upgrade flow, built-in JWT

### Backend as a Service
- **Supabase** (PostgreSQL + Auth + Real-time)
  - *Why:* Open-source, self-hostable, powerful API, real-time subscriptions, built-in auth
  - Hosted or self-hosted (flexible for open-source community)

### Push Notifications
- **Firebase Cloud Messaging (FCM)** via firebase_messaging
  - *Why:* Reliable, free, works on both Android/iOS, easy integration with Supabase

### Local Storage (Preferences)
- **Shared Preferences** (flutter_secure_storage for sensitive data)
  - *Why:* Simple key-value for app settings, theme, notification preferences

### Navigation
- **Go Router 10.x** (declarative routing)
  - *Why:* Named routes, deep linking, type-safe, works with Riverpod

### UI & Theme
- **Flutter Material 3** + custom theming
  - *Why:* Modern design system, dark/light/sepia modes, accessibility built-in
- **Google Fonts** (for typography)
  - *Why:* Modern typography, locally cached

### Localization
- **easy_localization 3.x**
  - *Why:* Simple YAML configuration, supports plural/gender, easy to add languages
  - Languages: English, Swahili (extensible to French, Portuguese)

### Date & Time
- **intl** package + **timezone**
  - *Why:* Proper date handling, liturgical calendar calculations, timezone support

### Testing
- **flutter_test** (unit & widget tests)
- **mocktail** (mocking)
- **integration_test** (end-to-end tests)

### Code Quality
- **flutter_lints** (recommended lint rules)
- **dart_code_metrics** (code complexity analysis)
- **coverage** (test coverage reporting)

### Deployment & CI/CD
- **GitHub Actions** (automated testing, build, deploy)
- **Firebase App Distribution** (beta testing on Play Store)
- **Fastlane** (iOS/Android automation)

### Documentation
- **dartdoc** (API documentation)
- **README.md** (this file)

---

## Project Structure

```
sala_katoliki/
├── .github/
│   └── workflows/
│       ├── test.yml                 # Run tests on push
│       ├── build_android.yml        # Build APK/AAB
│       └── build_ios.yml            # Build IPA
│
├── lib/
│   ├── config/
│   │   ├── theme/                   # App theming (colors, typography)
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   └── theme_data.dart
│   │   ├── routes/
│   │   │   └── app_router.dart      # Go Router configuration
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   └── env/
│   │       └── env_config.dart      # Environment variables
│   │
│   ├── core/
│   │   ├── extensions/              # Dart extensions
│   │   │   ├── string_extensions.dart
│   │   │   ├── datetime_extensions.dart
│   │   │   └── context_extensions.dart
│   │   ├── utils/
│   │   │   ├── logger.dart          # Logging utility
│   │   │   ├── validators.dart      # Input validation
│   │   │   └── date_utils.dart
│   │   ├── errors/
│   │   │   ├── failures.dart        # Custom exceptions
│   │   │   └── error_handler.dart
│   │   └── services/
│   │       ├── notification_service.dart
│   │       ├── analytics_service.dart
│   │       └── storage_service.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   └── auth_response_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── signup_usecase.dart
│   │   │   │       ├── logout_usecase.dart
│   │   │   │       └── get_current_user_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── auth_state_provider.dart
│   │   │       │   └── user_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── signup_screen.dart
│   │   │       │   └── onboarding_screen.dart
│   │   │       └── widgets/
│   │   │           ├── auth_form.dart
│   │   │           └── password_field.dart
│   │   │
│   │   ├── home/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── home_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── daily_verse_model.dart
│   │   │   │   │   └── saint_of_day_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── home_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── daily_verse_entity.dart
│   │   │   │   │   └── saint_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── home_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_daily_verse_usecase.dart
│   │   │   │       └── get_saint_of_day_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── daily_verse_provider.dart
│   │   │       │   └── saint_of_day_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       └── widgets/
│   │   │           ├── greeting_card.dart
│   │   │           ├── quick_access_cards.dart
│   │   │           ├── daily_verse_section.dart
│   │   │           └── saint_of_day_card.dart
│   │   │
│   │   ├── prayer_library/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── prayer_remote_datasource.dart
│   │   │   │   │   └── prayer_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── prayer_model.dart
│   │   │   │   │   ├── category_model.dart
│   │   │   │   │   └── prayer_with_category_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── prayer_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── prayer_entity.dart
│   │   │   │   │   └── category_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── prayer_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_all_prayers_usecase.dart
│   │   │   │       ├── search_prayers_usecase.dart
│   │   │   │       ├── get_categories_usecase.dart
│   │   │   │       └── get_prayers_by_category_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── prayers_provider.dart
│   │   │       │   ├── categories_provider.dart
│   │   │       │   └── search_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── prayer_library_screen.dart
│   │   │       │   └── prayer_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── prayer_card.dart
│   │   │           ├── category_filter.dart
│   │   │           ├── search_bar.dart
│   │   │           └── prayer_actions.dart
│   │   │
│   │   ├── rosary/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── rosary_remote_datasource.dart
│   │   │   │   │   └── rosary_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── rosary_model.dart
│   │   │   │   │   ├── mystery_model.dart
│   │   │   │   │   └── rosary_progress_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── rosary_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── rosary_entity.dart
│   │   │   │   │   ├── mystery_entity.dart
│   │   │   │   │   └── rosary_progress_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── rosary_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_rosary_of_day_usecase.dart
│   │   │   │       ├── start_rosary_usecase.dart
│   │   │   │       ├── advance_bead_usecase.dart
│   │   │   │       └── complete_rosary_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── rosary_provider.dart
│   │   │       │   └── rosary_progress_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── rosary_screen.dart
│   │   │       └── widgets/
│   │   │           ├── rosary_beads_display.dart
│   │   │           ├── bead_counter.dart
│   │   │           ├── prayer_display.dart
│   │   │           ├── rosary_controls.dart
│   │   │           └── mystery_selector.dart
│   │   │
│   │   ├── daily_readings/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── readings_remote_datasource.dart
│   │   │   │   │   └── readings_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── daily_reading_model.dart
│   │   │   │   │   └── lectionary_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── readings_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── daily_reading_entity.dart
│   │   │   │   │   └── lectionary_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── readings_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_today_reading_usecase.dart
│   │   │   │       ├── get_reading_by_date_usecase.dart
│   │   │   │       └── get_all_readings_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── daily_reading_provider.dart
│   │   │       │   └── reading_archive_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── daily_readings_screen.dart
│   │   │       └── widgets/
│   │   │           ├── reading_card.dart
│   │   │           ├── first_reading_section.dart
│   │   │           ├── psalm_section.dart
│   │   │           ├── gospel_section.dart
│   │   │           └── reflection_section.dart
│   │   │
│   │   ├── saints/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── saints_remote_datasource.dart
│   │   │   │   │   └── saints_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── saint_model.dart
│   │   │   │   │   └── feast_day_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── saints_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── saint_entity.dart
│   │   │   │   │   └── feast_day_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── saints_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_saint_of_day_usecase.dart
│   │   │   │       ├── get_all_saints_usecase.dart
│   │   │   │       ├── search_saints_usecase.dart
│   │   │   │       └── get_saints_by_month_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── saints_provider.dart
│   │   │       │   └── saint_of_day_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── saints_screen.dart
│   │   │       │   └── saint_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── saint_card.dart
│   │   │           ├── saint_bio_section.dart
│   │   │           ├── feast_day_calendar.dart
│   │   │           └── saint_quote_display.dart
│   │   │
│   │   ├── favorites/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── favorites_remote_datasource.dart
│   │   │   │   │   └── favorites_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── favorite_prayer_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── favorites_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── favorite_prayer_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── favorites_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_favorites_usecase.dart
│   │   │   │       ├── add_favorite_usecase.dart
│   │   │   │       ├── remove_favorite_usecase.dart
│   │   │   │       └── sync_favorites_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── favorites_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── favorites_screen.dart
│   │   │       └── widgets/
│   │   │           └── favorite_prayer_card.dart
│   │   │
│   │   ├── settings/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── settings_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_preferences_model.dart
│   │   │   │   │   └── notification_settings_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── settings_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── user_preferences_entity.dart
│   │   │   │   │   └── notification_settings_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── settings_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_settings_usecase.dart
│   │   │   │       ├── update_language_usecase.dart
│   │   │   │       ├── update_theme_usecase.dart
│   │   │   │       └── update_notification_settings_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── settings_provider.dart
│   │   │       │   ├── language_provider.dart
│   │   │       │   └── theme_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── settings_screen.dart
│   │   │       │   ├── language_settings_screen.dart
│   │   │       │   ├── notification_settings_screen.dart
│   │   │       │   └── about_screen.dart
│   │   │       └── widgets/
│   │   │           ├── settings_tile.dart
│   │   │           └── settings_switch.dart
│   │   │
│   │   └── notifications/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   └── notifications_local_datasource.dart
│   │       │   ├── models/
│   │       │   │   └── notification_model.dart
│   │       │   └── repositories/
│   │       │       └── notifications_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── notification_entity.dart
│   │       │   ├── repositories/
│   │       │   │   └── notifications_repository.dart
│   │       │   └── usecases/
│   │       │       ├── schedule_notifications_usecase.dart
│   │       │       └── handle_notification_usecase.dart
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── notifications_provider.dart
│   │           └── services/
│   │               └── notification_handler.dart
│   │
│   ├── main.dart                     # App entry point
│   └── app.dart                      # App widget config
│
├── test/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources_test.dart
│   │   │   │   ├── models_test.dart
│   │   │   │   └── repositories_test.dart
│   │   │   ├── domain/
│   │   │   │   └── usecases_test.dart
│   │   │   └── presentation/
│   │   │       ├── providers_test.dart
│   │   │       └── screens_test.dart
│   │   ├── prayer_library/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── ... (similar for other features)
│   ├── core/
│   │   ├── extensions_test.dart
│   │   ├── utils_test.dart
│   │   └── services_test.dart
│   └── helpers/
│       ├── test_fixtures.dart        # Test data
│       └── mock_providers.dart       # Mock Riverpod providers
│
├── integration_test/
│   ├── auth_flow_test.dart
│   ├── prayer_library_flow_test.dart
│   ├── rosary_flow_test.dart
│   └── app_test.dart
│
├── assets/
│   ├── images/
│   │   ├── app_icon.png
│   │   ├── splash_screen.png
│   │   └── illustrations/
│   ├── fonts/
│   │   └── (custom fonts if needed)
│   ├── translations/
│   │   ├── en.json                  # English translations
│   │   └── sw.json                  # Swahili translations
│   └── data/
│       ├── prayers.json             # Bundled prayers (offline)
│       ├── readings.json            # Bundled readings
│       └── saints.json              # Bundled saints data
│
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml
│   │       │   └── res/
│   │       └── release/
│   │           └── AndroidManifest.xml (signing config)
│   └── gradle/
│       └── wrapper/
│
├── ios/
│   ├── Runner/
│   │   ├── Info.plist              # iOS configuration
│   │   └── Assets.xcassets/        # App icons
│   └── Runner.xcworkspace/
│
├── web/ (optional for future web companion)
│   └── index.html
│
├── pubspec.yaml                     # Dependencies
├── pubspec.lock                     # Lock file
├── analysis_options.yaml            # Lint rules
├── .env.example                     # Environment variables template
├── .gitignore
├── README.md                        # This file
├── ARCHITECTURE.md                  # Detailed architecture guide
├── CONTRIBUTING.md                  # Contribution guidelines
└── LICENSE                          # MIT License

```

### Folder Organization Principles

1. **Feature-Based Structure**
   - Each feature (auth, prayer_library, rosary) is self-contained
   - Contains all layers: data, domain, presentation
   - Can be developed and tested independently

2. **Clean Architecture Layers**
   - **Data:** External communication (APIs, databases)
   - **Domain:** Business logic (entities, use cases, repositories)
   - **Presentation:** UI and state management

3. **Separation of Concerns**
   - **Models** (data layer) — Map external data
   - **Entities** (domain layer) — Pure business objects
   - **DTOs** (data layer) — Data transfer objects

4. **Core Utilities**
   - Shared extensions, utilities, services
   - Error handling, logging
   - Not tied to specific features

---

## Navigation Architecture

### Navigation Philosophy

Navigation in Sala Katoliki follows **calm, logical flow** that mirrors spiritual progression:

```
┌─────────────────────────────────────────┐
│         Splash Screen (2 sec)           │
│      [Calm, minimal animation]          │
└────────────────┬────────────────────────┘
                 │
       ┌─────────▼─────────┐
       │  Check Auth State │
       └────┬────────┬─────┘
           │        │
    ┌──────▼──┐  ┌──▼───────┐
    │ Logged  │  │ Guest /  │
    │ In?     │  │ Not Auth │
    └────┬────┘  └────┬─────┘
         │            │
         │      ┌─────▼──────────┐
         │      │ Onboarding     │
         │      │ (3 screens)    │
         │      └────┬───────────┘
         │           │
         │      ┌────▼─────────────────┐
         │      │ Auth Selection       │
         │      │ - Guest Mode         │
         │      │ - Email/Password     │
         │      │ - Google OAuth       │
         │      │ - Apple ID           │
         │      └────┬────────┬────────┘
         │           │        │
    ┌────▼────┐  ┌───▼────────▼───┐
    │ Home    │  │ Auth Screens   │
    │ Screen  │  │ (Login/Signup) │
    └────┬────┘  └────┬───────────┘
         │            │
         │      ┌─────▼──────────┐
         │      │ Home Screen    │
         └──────┼────────────────┘
                │
         ┌──────▼──────────────────────┐
         │   Main Navigation Tabs      │
         │  ┌─────┬──────┬──────┬──────┤
         │  │Home │Prayer│Rosary│ Menu │
         │  └──┬──┴──┬───┴──┬───┴──┬───┘
         │     │     │      │      │
    ┌────▼──┐ │  ┌──▼────┐│ ┌────▼─┐
    │Quick  │ │  │Prayer ││ │Stgs/ │
    │Access │ │  │Details││ │About │
    │Cards  │ │  └───┬───┘│ └──┬───┘
    └───────┘ │      │    │    │
              │  ┌───▼────▼────▼─────┐
              │  │ Detailed Views    │
              │  │ - Prayer Library  │
              │  │ - Rosary Mode     │
              │  │ - Daily Readings  │
              │  │ - Saints          │
              │  │ - Favorites       │
              │  │ - Settings        │
              │  └───────────────────┘

```

### Go Router Configuration

```dart
// lib/config/routes/app_router.dart

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
        routes: [
          // Auth Routes
          GoRoute(
            path: 'onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),

          // Main App Routes
          GoRoute(
            path: 'home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'prayer/:id',
                builder: (context, state) => PrayerDetailScreen(
                  prayerId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'prayer-library',
                builder: (context, state) => const PrayerLibraryScreen(),
              ),
              GoRoute(
                path: 'rosary',
                builder: (context, state) => const RosaryScreen(),
              ),
              GoRoute(
                path: 'daily-readings',
                builder: (context, state) => const DailyReadingsScreen(),
              ),
              GoRoute(
                path: 'saints',
                builder: (context, state) => const SaintsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => SaintDetailScreen(
                      saintId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'language',
                    builder: (context, state) =>
                        const LanguageSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) =>
                        const NotificationSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
});
```

### Route Structure

| Route | Purpose | Auth Required | State |
|-------|---------|---------------|-------|
| `/` | Splash screen | No | Loading |
| `/onboarding` | Welcome carousel | No | Initial |
| `/login` | Login screen | No | Not authenticated |
| `/signup` | Sign up screen | No | Not authenticated |
| `/home` | Home dashboard | No* | Main app |
| `/home/prayer/:id` | Prayer details | No | Content view |
| `/home/prayer-library` | Browse prayers | No | Browse |
| `/home/rosary` | Rosary experience | No | Active |
| `/home/daily-readings` | Daily Mass readings | No | Archive |
| `/home/saints` | Saints calendar | No | Browse |
| `/home/saints/:id` | Saint details | No | Detail |
| `/home/favorites` | Saved prayers | Recommended* | User data |
| `/home/settings` | App settings | Recommended* | User config |

*No auth required, but guest mode has limitations

---

## Data Flow

### User Authentication Flow

```
┌──────────────────────────────────────────────┐
│          User Taps "Create Account"          │
└────────────────┬─────────────────────────────┘
                 │
        ┌────────▼────────┐
        │ Sign Up Screen  │
        │ - Email         │
        │ - Password      │
        │ - Name (opt)    │
        └────────┬────────┘
                 │
        ┌────────▼──────────────────┐
        │ SignupUseCase             │
        │ .call(email, password)    │
        └────────┬──────────────────┘
                 │
        ┌────────▼──────────────────────┐
        │ AuthRepositoryImpl            │
        │ _signUpWithEmail()            │
        └────────┬───────────────────────┘
                 │
        ┌────────▼──────────────────────┐
        │ AuthRemoteDataSource         │
        │ .signUpWithEmail()           │
        │ (calls Supabase API)         │
        └────────┬───────────────────────┘
                 │
        ┌────────▼──────────────────────────┐
        │ Supabase Auth                     │
        │ - Creates user in PostgreSQL      │
        │ - Generates JWT token            │
        │ - Returns session                │
        └────────┬───────────────────────────┘
                 │
        ┌────────▼──────────────────────┐
        │ AuthLocalDataSource           │
        │ .cacheAuthToken()             │
        │ (saves to SecureStorage)      │
        └────────┬───────────────────────┘
                 │
        ┌────────▼──────────────────────┐
        │ Riverpod State Updates        │
        │ .authStateProvider            │
        │ .currentUserProvider          │
        └────────┬───────────────────────┘
                 │
        ┌────────▼──────────────────────┐
        │ UI Rebuilds                   │
        │ - Navigate to Home Screen     │
        │ - Show personalized content   │
        └────────────────────────────────┘
```

### Prayer Fetch & Cache Flow

```
┌──────────────────────────────────────────────┐
│    App Loads / User Opens Prayer Library    │
└────────────────┬─────────────────────────────┘
                 │
        ┌────────▼──────────────────────┐
        │ GetPrayersUseCase             │
        │ .call()                       │
        └────────┬───────────────────────┘
                 │
        ┌────────▼──────────────────────────┐
        │ PrayerRepositoryImpl               │
        │ .getAllPrayers()                  │
        └────────┬───────────────────────────┘
                 │
                 │ Check local cache first
                 │
        ┌────────▼──────────────────────────┐
        │ PrayerLocalDataSource             │
        │ .getAllPrayersFromIsar()          │
        │ (if exists, return cached data)   │
        └────────┬───────────────────────────┘
                 │
            ┌────▴────┐
            │ Found?  │
            └────┬────┘
            Yes  │  No
                 │
    ┌────────────┤
    │            │
┌───▼────┐   ┌───▼─────────────────────────┐
│ Return │   │ Fetch from Supabase (API)   │
│ Cached │   └───┬───────────────────────────┘
│ Data   │       │
└────────┘   ┌───▼──────────────────────┐
             │ PrayerRemoteDataSource   │
             │ .getAllPrayers()         │
             │ (HTTP request to API)    │
             └───┬──────────────────────┘
                 │
             ┌───▼──────────────────────┐
             │ Parse JSON Response      │
             │ Convert to Models        │
             └───┬──────────────────────┘
                 │
             ┌───▼──────────────────────┐
             │ Cache Locally            │
             │ (Isar database)          │
             └───┬──────────────────────┘
                 │
             ┌───▼──────────────────────┐
             │ Return to Repository     │
             │ (Entities)               │
             └───┬──────────────────────┘
                 │
             ┌───▼──────────────────────┐
             │ Riverpod Provider Updates│
             │ prayersProvider.state    │
             └───┬──────────────────────┘
                 │
             ┌───▼──────────────────────┐
             │ UI Listens to Provider   │
             │ Rebuilds with new data   │
             └──────────────────────────┘
```

### Offline Mode Flow

```
┌────────────────────────────────────────┐
│     App Launched (No Internet)         │
└────────────────┬──────────────────────┘
                 │
        ┌────────▼───────────────┐
        │ Check Network Status   │
        │ (connectivity package) │
        └────────┬───────────────┘
                 │
            ┌────▴────┐
            │ Online? │
            └────┬────┘
           No    │    Yes
                 │
    ┌────────────┤
    │            │
┌───▼────────────▼────────┐
│ Load All from Local DB  │
│ (Isar - instant load)   │
│                         │
│ Features:               │
│ - All prayers           │
│ - All readings          │
│ - All saints            │
│ - Favorites (synced)    │
│ - Rosary (full feature) │
└─────────┬───────────────┘
          │
    ┌─────▼──────────────┐
    │ UI Shows Offline   │
    │ Indicator          │
    │ (small icon)       │
    └─────┬──────────────┘
          │
    ┌─────▼──────────────┐
    │ User Can:          │
    │ ✓ Read prayers     │
    │ ✓ Use rosary       │
    │ ✓ Read readings    │
    │ ✓ Browse saints    │
    │ ✓ Search          │
    │ ✗ Sync favorites  │
    │ ✗ Login/signup    │
    └────────────────────┘

When internet restored:
┌──────────────────────────────┐
│ Automatic Sync Triggered     │
│ - Sync favorites             │
│ - Pull updates               │
│ - Update locally cached data │
└──────────────────────────────┘
```

---

## Setup & Installation

### Prerequisites

- **Flutter 3.x** (stable channel)
- **Dart 3.x**
- **Git**
- **Android Studio** / **Xcode** (for building)
- **Firebase Account** (for FCM)
- **Supabase Account** (backend)

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/sala-katoliki.git
cd sala-katoliki
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment

Create `.env` file from template:

```bash
cp .env.example .env
```

Edit `.env` with your values:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Firebase (for FCM)
FIREBASE_PROJECT_ID=your-firebase-project-id

# App Configuration
APP_VERSION=1.0.0
ENVIRONMENT=development
```

### 4. Generate Code

Some packages require code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run App

**Development (hot reload):**

```bash
flutter run --flavor development
```

**Production:**

```bash
flutter run --release
```

### 6. Run Tests

```bash
# Unit & widget tests
flutter test

# With coverage
flutter test --coverage
coverage/lcov.info

# Integration tests
flutter test integration_test/
```

---

## Development Guidelines

### Code Style

1. **Naming Conventions**
   - Classes: `PascalCase` (e.g., `PrayerLibraryScreen`)
   - Variables: `camelCase` (e.g., `prayerCount`)
   - Constants: `camelCase` (e.g., `kDefaultPadding`)
   - Private: prefix with `_` (e.g., `_buildHeader()`)

2. **Folder Organization**
   - Keep features independent
   - Use relative imports within features
   - Absolute imports from `lib/`

3. **Documentation**
   - Document public APIs with `///`
   - Include examples in docstrings
   - Keep README.md updated

### Riverpod Provider Conventions

```dart
// Provider naming: [entity]Provider
final prayerProvider = FutureProvider<Prayer>((ref) async {
  // Fetch prayer data
});

// State notifier: [entity]StateNotifierProvider
final favoritesPodcastProvider = 
  StateNotifierProvider<FavoritesNotifier, List<Prayer>>((ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});

// Family modifier for parameters
final prayerByIdProvider = FutureProvider.family<Prayer, String>((ref, id) async {
  final repository = ref.watch(prayerRepositoryProvider);
  return repository.getPrayerById(id);
});
```

### Exception Handling

```dart
// Create custom exceptions in lib/core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Use in repositories
Future<Either<Failure, List<Prayer>>> getPrayers() async {
  try {
    // Fetch data
  } on SocketException {
    return left(NetworkFailure('No internet connection'));
  } catch (e) {
    return left(GeneralFailure('An error occurred: $e'));
  }
}
```

### Testing Strategy

```dart
// Unit test example
void main() {
  group('GetPrayersUseCase', () {
    late GetPrayersUseCase useCase;
    late MockPrayerRepository mockRepository;

    setUp(() {
      mockRepository = MockPrayerRepository();
      useCase = GetPrayersUseCase(mockRepository);
    });

    test('should return List<Prayer> when successful', () async {
      // Arrange
      const mockPrayers = [
        PrayerEntity(id: '1', title: 'Prayer 1', ...),
        PrayerEntity(id: '2', title: 'Prayer 2', ...),
      ];
      when(mockRepository.getPrayers())
          .thenAnswer((_) async => mockPrayers);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, equals(mockPrayers));
      verify(mockRepository.getPrayers()).called(1);
    });
  });
}
```

### Git Workflow

1. **Branch naming:**
   ```
   feature/prayer-library-search
   bugfix/offline-mode-crash
   refactor/riverpod-migration
   docs/setup-instructions
   ```

2. **Commit messages:**
   ```
   feat: Add prayer search functionality
   fix: Fix rosary bead increment bug
   refactor: Migrate to Riverpod state management
   docs: Update README with setup steps
   test: Add unit tests for favorites
   ```

3. **Pull Requests:**
   - Link to GitHub issues
   - Include description of changes
   - Add test coverage report
   - Get review before merging

---

## Testing Strategy

### Test Coverage Goals

- **Unit Tests:** 70%+ (business logic)
- **Widget Tests:** 50%+ (UI logic)
- **Integration Tests:** Critical flows (auth, favorites, prayers)

### Test File Structure

```
test/
├── features/
│   └── prayer_library/
│       ├── data/
│       │   ├── models/
│       │   │   └── prayer_model_test.dart
│       │   ├── repositories/
│       │   │   └── prayer_repository_impl_test.dart
│       │   └── datasources/
│       │       ├── prayer_remote_datasource_test.dart
│       │       └── prayer_local_datasource_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       └── get_prayers_usecase_test.dart
│       └── presentation/
│           └── screens/
│               └── prayer_library_screen_test.dart
└── helpers/
    ├── test_fixtures.dart
    └── mock_providers.dart
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/prayer_library/data/models/prayer_model_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --list coverage/lcov.info
```

---

## CI/CD Pipeline

### GitHub Actions Workflows

**1. Test on Push** (`.github/workflows/test.yml`)

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.x
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

**2. Build Android APK** (`.github/workflows/build_android.yml`)

```yaml
name: Build Android

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.x
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/apk/release/app-release.apk
```

**3. Deploy to Play Store (manual trigger)**

Use Fastlane for automated Play Store deployment:

```bash
# Install fastlane
sudo gem install fastlane -NV

# Initialize
fastlane init android

# Deploy (requires service account JSON)
fastlane android deploy
```

---

## Deployment

### Google Play Store (Android)

**Preparation:**
1. Create app in Google Play Console
2. Generate keystore for signing
3. Create service account for automated publishing

**Build:**
```bash
flutter build appbundle --release
```

**Upload:**
- Manual: Via Play Console
- Automated: Via Fastlane (recommended for CI/CD)

### App Store (iOS - Phase 2)

**Preparation:**
1. Enroll in Apple Developer Program
2. Create app in App Store Connect
3. Set up code signing certificates

**Build:**
```bash
flutter build ipa --release
```

**Upload:**
- Via Transporter (Apple)
- Via Fastlane automation

### Version Management

Use semantic versioning:

```
1.0.0-alpha    # Initial alpha release
1.0.0-beta.1   # Beta testing
1.0.0          # Release version
1.0.1          # Patch (bug fixes)
1.1.0          # Minor (features)
2.0.0          # Major (breaking changes)
```

Update version in:
- `pubspec.yaml`: `version: 1.0.0+1`
- `android/app/build.gradle`: `versionCode`, `versionName`
- `ios/Runner/Info.plist`: `CFBundleShortVersionString`

---

## Design Philosophy

### Core Principles

#### 1. **Peace First**
Every screen, every interaction, every animation should feel calm and meditative.

- ✅ Soft colors, generous whitespace, smooth animations
- ❌ Aggressive notifications, flashing elements, constant alerts

#### 2. **Spiritual Understanding**
The app should feel like it understands Catholic spiritual life, not just deliver features.

- ✅ Liturgical calendar, feast days, saint information, contemplative design
- ❌ Generic "prayer app" treatment, meditation buzzwords

#### 3. **Zero Friction**
New users should find value within 30 seconds without forced signup.

- ✅ Guest mode, instant content access, offline capability
- ❌ Paywalls, forced signup, locked features

#### 4. **Offline Respect**
Internet is not guaranteed. The app should work beautifully offline.

- ✅ Local database, bundled content, sync when available
- ❌ API-only design, streaming-only content

#### 5. **Emotional Resonance**
Users should want to return because the app brings them peace.

- ✅ Daily readings, reminders, favorites, progress tracking
- ❌ Gamification hacks, engagement tricks, dark patterns

### Design System

**Colors:**
- Primary: #1F4788 (Deep Catholic Blue)
- Secondary: #6B8E23 (Sage Green)
- Background: #F5F1E8 (Warm White)
- Text: #2C3E50 (Dark Slate)
- Accent: #D4A574 (Warm Gold - for highlights)

**Typography:**
- Headers: SF Pro Display / Inter (bold)
- Body: Inter / Poppins (regular)
- Sizes: 12px (small), 16px (body), 20px (title), 28px (heading)

**Spacing:**
- Padding: 8px, 16px, 24px, 32px
- Margin: 16px, 24px, 32px
- Line height: 1.5x font size (readability for prayer text)

**Animations:**
- Duration: 200-400ms (never jarring)
- Easing: ease-out, ease-in-out
- No heavy animations that distract

### Content Principles

1. **Prayer Quality Over Quantity**
   - Start with 50-100 high-quality prayers
   - All properly sourced and attributed
   - EN + SW versions for all content

2. **Accuracy & Respect**
   - Use official Catholic liturgy
   - Proper translations (not machine translation)
   - Review by subject experts

3. **Localization**
   - Not just translation (mechanical)
   - Cultural adaptation (spiritual meaning preserved)
   - Native speaker review

---

## Contributing

### For Open-Source Contributors

We welcome contributions! Here's how:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow code style guidelines
   - Write tests for new features
   - Update README.md if needed

4. **Commit with clear messages**
   ```bash
   git commit -m 'feat: Add amazing feature'
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Describe what you've done
   - Link to related issues
   - Include test coverage report

### Contribution Areas

- 🙏 **Content:** Add prayers, readings, saints (EN + SW)
- 🐛 **Bug fixes:** Report and fix issues
- ✨ **Features:** Enhance user experience
- 📚 **Documentation:** Improve guides and README
- 🌐 **Localization:** Translate to French, Portuguese
- 🧪 **Tests:** Improve test coverage
- 🎨 **Design:** UI/UX improvements

### Reporting Issues

Use GitHub Issues with:
- Clear title
- Description of problem
- Steps to reproduce
- Screenshots (if UI related)
- Device/OS information

---

## License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) file for details.

### MIT License Summary

You are free to:
- ✅ Use commercially
- ✅ Modify the code
- ✅ Distribute copies
- ✅ Use privately

You must:
- ✅ Include license and copyright notice
- ✅ Disclose changes

You cannot:
- ❌ Hold liable for warranty
- ❌ Use trademark

For full terms, see LICENSE file.

---

## Troubleshooting

### Common Issues

**1. Flutter Version Mismatch**
```bash
flutter upgrade
flutter pub get
```

**2. Build Cache Issues**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

**3. Supabase Connection Error**
- Check `.env` file credentials
- Verify Supabase project is active
- Check network connectivity
- Review Supabase console logs

**4. Isar Database Errors**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**5. FCM Notifications Not Working**
- Ensure Firebase project is linked
- Check device token registration
- Verify notification permissions granted
- Check Android/iOS config files

### Getting Help

1. **Check documentation:** Review README.md, ARCHITECTURE.md
2. **Search issues:** Look for similar GitHub issues
3. **Open new issue:** If not found, create detailed issue
4. **Ask community:** Discussions tab on GitHub

---

## Roadmap

### Phase 1 (MVP - Q2 2024)
- [x] Core prayer library (200+ prayers)
- [x] Rosary interactive experience
- [x] Daily readings (365 days)
- [x] Saints & feast days
- [x] Offline capability
- [x] Multi-language (EN, SW)
- [x] User authentication
- [x] Favorites & bookmarks
- [x] Settings & preferences

### Phase 2 (Q3-Q4 2024)
- [ ] Audio narration for prayers
- [ ] Community contributions (moderated)
- [ ] Sepia reading mode
- [ ] Beautiful share cards
- [ ] Prayer streak gamification
- [ ] iOS App Store launch

### Phase 3 (2025+)
- [ ] AI prayer assistant
- [ ] Parish locator
- [ ] Confession preparation
- [ ] Bible reading plans
- [ ] Wearable support (Apple Watch)
- [ ] Smart recommendations
- [ ] Meditation timer integration
- [ ] Additional languages (French, Portuguese)

---

## Acknowledgments

- **Catholic Church** for liturgy and spirituality
- **Flutter team** for an amazing framework
- **Supabase community** for backend infrastructure
- **Contributors** who help build this app

---

## Contact

**Project Lead:** Melkizedek Fredy  
**Email:** fredymelkizedek@gmail.com  
**GitHub:** @fredy-me(https://github.com/fredy-me)

---

**Last Updated:** 26-05-2026  
**Version:** 1.0.0 (README)  
**Status:** Open Source - MIT License