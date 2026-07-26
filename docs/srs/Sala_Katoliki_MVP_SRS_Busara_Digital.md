# Sala Katoliki / Catholic Prayer Mobile Application

## MVP Software Requirements Specification

| Field | Value |
|-------|-------|
| **Product** | Sala Katoliki / Catholic Prayer |
| **Version** | 1.0 - MVP SRS |
| **Date** | 2 June 2026 |
| **Prepared For** | Busara Digital |
| **Technology** | Flutter, Dart, bundled local JSON content, local storage |
| **Status** | Production (6 releases shipped) |

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [MVP Scope](#2-mvp-scope)
3. [Required Features](#3-required-features)
4. [Non-MVP Items](#4-non-mvp-items)
5. [Technical Constraints](#5-technical-constraints)
6. [Architecture Requirements](#6-architecture-requirements)
7. [Content Requirements](#7-content-requirements)
8. [Data Models](#8-data-models)
9. [Functional Requirements](#9-functional-requirements)
10. [Non-Functional Requirements](#10-non-functional-requirements)
11. [Acceptance Criteria](#11-acceptance-criteria)
12. [Release Constraints](#12-release-constraints)
13. [Store Readiness](#13-store-readiness)

---

## 1. Product Overview

### 1.1 Purpose

Sala Katoliki is an offline-first Catholic prayer app for mobile devices. It provides essential Catholic prayer resources in English and Kiswahili without requiring account registration, backend dependency, paid features, or media-heavy content.

### 1.2 Target Users

- Catholic faithful worldwide
- Users who want free, ad-free, privacy-respecting prayer resources
- Users in areas with limited or no internet connectivity

### 1.3 Key Differentiators

- **Offline-first**: Core features work without internet
- **Privacy-first**: All data stays on the device
- **Free and open-source**: GPL-3.0 licensed
- **No tracking**: No accounts, no ads, no data collection

---

## 2. MVP Scope

### 2.1 In Scope

The MVP is an Android-first, offline-first Flutter prayer app providing:

- English and Kiswahili bundled prayer content
- Today screen with quick access to prayer actions
- Prayer category browsing and detail reading
- Favorites and recent prayers
- Offline search
- Interactive Rosary with mystery selection
- Novenas with 9-day progress tracking
- Local daily reminders
- Settings for language, theme, font size
- About and content source information

### 2.2 Out of Scope

The MVP must not depend on:

- Authentication, accounts, profiles, or social sign-in
- Backend CMS, admin dashboard, cloud sync, or remote database
- Payments, donations, subscriptions, or ads
- Audio, video, podcasts, or guided meditation library
- Community posting, chat, comments, or parish social network
- Full Bible, full Catechism, Mass booking, parish management, or sacrament scheduling
- AI spiritual advisor or automated pastoral guidance
- Copyrighted Bible translations, Mass readings, or devotional content without permission

---

## 3. Required Features

| ID | Feature | Description |
|----|---------|-------------|
| FR-001 | Language Selection | First-launch language selection for English and Kiswahili. Language persists after restart. |
| FR-002 | Today Screen | Daily prayer hub with quick access to prayer actions, novena continuation, Rosary shortcut. |
| FR-003 | Categories | Prayer category browsing loaded from bundled JSON. |
| FR-004 | Prayer List | Prayer list for each category with dynamic content. |
| FR-005 | Prayer Detail | Prayer detail screen showing title, body, category, source. |
| FR-006 | Bundled Content | Common Catholic prayer library loaded from bundled JSON. |
| FR-007 | Favorites | Add/remove/display/persist favorite prayers. |
| FR-008 | Offline Search | Full-text search across title, body, tags, category. |
| FR-009 | Interactive Rosary | Mystery selection by day, step-by-step progress, save/resume. |
| FR-010 | Novenas | 9-day novena progress tracking with day completion. |
| FR-011 | Daily Reminder | Local notification scheduling, changing, and disabling. |
| FR-012 | Offline Mode | Core features work without internet. |
| FR-013 | Settings | Language, font size, theme, reminder preferences. |
| FR-014 | Attribution | Content source and legal notes in About screen. |
| FR-015 | Add Prayer | New prayer content appears without creating new UI code. |

---

## 4. Non-MVP Items

The following features must NOT be implemented in the MVP:

| Category | Excluded Items |
|----------|----------------|
| **Authentication** | Registration, profiles, social sign-in, accounts |
| **Backend** | CMS, admin dashboard, cloud sync, remote database |
| **Monetization** | Payments, donations, subscriptions, ads |
| **Media** | Audio, video, podcasts, guided meditation |
| **Community** | Posting, chat, comments, social network |
| **Content** | Full Bible, Catechism, Mass booking, sacrament scheduling |
| **AI** | Spiritual advisor, pastoral automation |
| **Copyright** | Bible translations, Mass readings without permission |

---

## 5. Technical Constraints

### 5.1 Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| Language | Dart SDK ^3.10.4 |
| State Management | Riverpod |
| Navigation | Go Router |
| Local Storage | SharedPreferences |
| Localization | Riverpod-based (English/Kiswahili) |
| Content | Bundled JSON under `assets/` |
| Notifications | flutter_local_notifications |

### 5.2 Platform Requirements

| Platform | Requirement |
|----------|-------------|
| Android | Primary target |
| iOS | Secondary (Flutter codebase supports it) |
| Minimum SDK | Android 7.0 (API 24) |
| Target SDK | Android 16 (API 36) |

### 5.3 Permissions

**Allowed:**

- Notification permission (where required by OS)

**Not Allowed:**

- Location
- Camera
- Microphone
- Contacts
- Biometrics
- Bluetooth
- NFC
- Health APIs
- Payment APIs

### 5.4 Performance Targets

| Metric | Target |
|--------|--------|
| Cold startup | < 2 seconds (modern devices), < 3 seconds (low-end) |
| Prayer detail load | < 1 second |
| Search response | < 1 second |
| Runtime memory | < 150 MB |

---

## 6. Architecture Requirements

### 6.1 Layer Separation

```
lib/
  features/     # Presentation (screens, widgets, providers)
  data/         # Models, repositories, datasources
  core/         # Theme, constants, utils, localization
  shared/       # Reusable widgets and services
```

### 6.2 Architecture Flow

```
User
  -> Flutter UI
  -> State Manager
  -> Content Repository
  -> Local JSON Assets

User
  -> Flutter UI
  -> State Manager
  -> Local Storage
  -> Preferences / Favorites / Progress

User
  -> Settings
  -> Local Notifications Service
  -> OS Notification System
```

### 6.3 State Model

**Content Loading:**

```
Uninitialized
  -> LoadingSettings
  -> LoadingContent
  -> Ready
```

**Failure Path:**

```
LoadingContent
  -> Error
  -> FallbackContent
  -> Ready
```

**Rosary Progress:**

```
Not Started
  -> In Progress
  -> Paused
  -> Completed
  -> Reset
```

### 6.4 Navigation

Four main sections:

1. Today
2. Pray
3. Novenas
4. Settings (SRS originally specified Library)

Additional screens pushed from main sections:

- Search
- Favorites
- Prayer Detail
- Rosary Step
- Novena Detail
- About

---

## 7. Content Requirements

### 7.1 Content Structure

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

### 7.2 Content Rules

- All prayer content must be data-driven
- UI screens must not hard-code one screen per prayer
- Adding a new prayer must require content changes only, not a new screen
- Content must work offline

### 7.3 Content Rights

- Do not publish copyrighted Bible translations, Mass readings, or devotional text without written permission
- Traditional Catholic prayers may be public domain, but each source needs review
- All content must include source attribution where available

---

## 8. Data Models

### 8.1 Prayer

**Required Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique lowercase snake_case identifier |
| `type` | String | Content type (usually "prayer") |
| `category` | String | Category ID reference |
| `language` | String | "en" or "sw" |
| `title` | String | Localized prayer title |
| `body` | String | Localized prayer text |

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `description` | String | Prayer description |
| `tags` | List<String> | Search tags |
| `source` | String | Content source attribution |
| `version` | int | Content version |
| `last_updated` | String | ISO date string |
| `is_offline_available` | bool | Offline availability flag |

### 8.2 Category

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique category identifier |
| `title` | Map<String, String> | Localized titles |
| `description` | Map<String, String> | Localized descriptions |
| `sort_order` | int | Display order |
| `icon` | String | Icon identifier |

### 8.3 Novena

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique novena identifier |
| `language` | String | "en" or "sw" |
| `title` | String | Localized title |
| `description` | String | Localized description |
| `days` | List<NovenaDay> | Exactly 9 day objects |
| `source` | String | Content source |
| `version` | int | Content version |
| `last_updated` | String | ISO date string |

**Novena Day:**

| Field | Type | Description |
|-------|------|-------------|
| `day` | int | Day number (1-9) |
| `title` | String | Day title |
| `body` | String | Day prayer text |

### 8.4 Rosary

**Mystery:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Mystery identifier |
| `language` | String | "en" or "sw" |
| `title` | String | Mystery title |
| `description` | String | Mystery description |
| `days` | List<String> | Weekdays for this mystery |
| `mysteries` | List<String> | Individual mystery names |
| `virtues` | List<String> | Associated virtues |

**Prayer Step:**

| Field | Type | Description |
|-------|------|-------------|
| `prayer_id` | String | Reference to prayer |
| `repeat_count` | int | Number of repetitions |

### 8.5 Local Storage

| Key | Type | Description |
|-----|------|-------------|
| `selected_language` | String | User's language choice |
| `theme_mode` | String | Theme preference |
| `font_size` | double | Font scale factor |
| `favorite_prayer_ids` | List<String> | Saved prayer IDs |
| `recent_prayer_ids` | List<String> | Recently viewed prayers |
| `reminder_enabled` | bool | Reminder on/off |
| `reminder_time` | String | Reminder time |
| `rosary_mystery_id` | String | Current mystery |
| `rosary_step_index` | int | Current step |
| `active_novena_id` | String | Started novena |
| `completed_novena_days` | List<int> | Completed days |

---

## 9. Functional Requirements

### 9.1 Onboarding (FR-001)

- First launch shows language selection screen
- User selects English or Kiswahili
- Selection persists after restart
- Language change available in Settings
- Content loads based on selected language

### 9.2 Today Screen (FR-002)

- Daily prayer hero card
- Active novena continuation card (if any)
- Rosary shortcut card
- Quick actions grid
- Reminder status row
- Recently opened prayer

### 9.3 Prayer Library (FR-003, FR-004, FR-005, FR-006)

- Category grid loaded from JSON
- Category card shows icon, title, description, prayer count
- Prayer list for selected category
- Prayer detail shows title, body, category, source
- Share prayer functionality
- Source metadata display

### 9.4 Favorites (FR-007)

- Add/remove favorite from prayer detail
- Favorites screen shows saved prayers
- Persist favorites locally
- Handle invalid prayer IDs safely

### 9.5 Search (FR-008)

- Search bar on Pray screen
- Full-text search across title, body, tags, category
- Search results with relevance scoring
- Empty/no-match state is clear

### 9.6 Rosary (FR-009)

- Mystery selection by day of week
- Today's mystery suggested automatically
- Guided step-by-step flow
- Bead progress indicator
- Previous/next navigation
- Pause and save progress
- Resume from saved position
- Restart option
- Corrupt progress recovery

### 9.7 Novenas (FR-010)

- Novena list with active novena hero
- Start novena action
- Day-by-day progress tracking
- Mark day complete action
- Continue from Today screen
- Closing prayer section
- Thanksgiving section
- Invalid progress handling

### 9.8 Reminders (FR-011)

- Enable/disable daily reminder
- Set reminder time
- Local notification scheduling
- Permission request flow
- Permission denial handling
- Cancel reminder

### 9.9 Settings (FR-013)

- Language selection
- Font size adjustment
- Theme mode (light/dark/system)
- Reminder settings
- Link to About screen

### 9.10 About (FR-014)

- App logo and name
- Version number
- Developer information
- Open-source license note
- Content sources
- Disclaimer
- Contact/website links

---

## 10. Non-Functional Requirements

### 10.1 Offline Operation (FR-012)

- All core features must work without internet
- No screen blocks on internet access
- No crash from missing network
- No crash from corrupt local progress
- User-facing error states are readable and non-technical

### 10.2 Accessibility

- Minimum touch target: 48 x 48 dp
- Readable text at default font size
- High contrast between text and background
- Screen reader compatible labels

### 10.3 Localization

- English and Kiswahili for MVP
- All UI text must be localizable
- Content loads based on selected language
- Fallback to English if translation missing

---

## 11. Acceptance Criteria

The app must satisfy these criteria:

| # | Criterion |
|---|-----------|
| 1 | First-time user selects English or Kiswahili and reaches Today |
| 2 | Offline user can open prayers, search, use Rosary, use novenas, and view favorites |
| 3 | Common prayers are loaded from JSON, not hard-coded in screen files |
| 4 | A new valid prayer JSON entry appears without creating a new screen |
| 5 | Favorites and settings persist after restart |
| 6 | Rosary can start, navigate next/previous, exit, continue, and restart |
| 7 | Novena can start, mark days complete, and continue from Today |
| 8 | Daily reminder can be scheduled, changed, and disabled |
| 9 | App does not request camera, microphone, contacts, location, NFC, Bluetooth, or biometric permissions |
| 10 | Store listing includes support link, privacy policy link, content attribution, and minimal permission declaration |

---

## 12. Release Constraints

### 12.1 Android

- Package ID: `com.busaradigital.salakatoliki`
- Minimum SDK: 24 (Android 7.0)
- Target SDK: 36 (Android 16)
- Release signing via `android/key.properties`
- AAB build for Play Store

### 12.2 iOS

- Flutter iOS project exists
- iOS deployment pending
- Notification behavior verification needed
- Physical device/TestFlight build required

### 12.3 Permissions

| Permission | Justification |
|------------|---------------|
| `POST_NOTIFICATIONS` | Daily prayer reminder notifications |

**Not Required:**

- Camera, microphone, contacts, location, Bluetooth, NFC, SMS, phone, calendar, storage, biometric

---

## 13. Store Readiness

### 13.1 Google Play

- App name: Sala Katoliki
- Category: Lifestyle
- Tags: Prayer, Catholic, Rosary, Devotional
- Developer: Busara Digital
- Store listing with full description
- Data safety declaration
- Content rating questionnaire

### 13.2 Required Before Public Release

- [ ] All content rights reviewed and approved
- [ ] Support contact link functional
- [ ] Privacy policy link functional
- [ ] Website link functional
- [ ] Content attribution complete
- [ ] Permission declaration accurate
- [ ] Signed AAB built and tested
- [ ] Performance QA on representative devices
- [ ] Exploratory QA completed

---

## Appendix A: Verification Checklist

Run before release candidates:

1. `dart run tools/validate_content.dart`
2. `flutter analyze`
3. `flutter test`
4. Run integration tests on Android emulator/device
5. Follow offline regression checklist in airplane mode
6. Verify first launch, language switching, prayer search, favorites, Rosary resume, novena completion, reminder enable/change/disable, theme/font scaling
7. Test at 320 dp width and representative Android devices
8. Build and install release-signed AAB
9. Complete iOS readiness phase (if in scope)

---

## Appendix B: Known Reconciliation Items

These items represent differences between the original SRS and current implementation:

| # | Item | Original SRS | Current State |
|---|------|--------------|---------------|
| 1 | Navigation | Today / Pray / Novenas / Library | Today / Pray / Novenas / Settings |
| 2 | Novena duration | Exactly 9 days | Includes 12-day St. Rita novena |
| 3 | Novena completion | Explicit completed state | Active state retained after final day |

---

*This document is the Software Requirements Specification for Sala Katoliki MVP. It was prepared for Busara Digital on 2 June 2026.*
