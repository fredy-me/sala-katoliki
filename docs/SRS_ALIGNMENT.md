# SRS Alignment

This repository follows the Sala Katoliki / Catholic Prayer Mobile Application MVP SRS prepared for Kilimanjaro Technology.

Source document:

`/home/meck/Downloads/Sala_Katoliki_MVP_SRS_Kilimanjaro_Technology.pdf`

Document metadata:

- Product: Sala Katoliki / Catholic Prayer.
- Version: 1.0 - MVP SRS.
- Date: 2 June 2026.
- Technology: Flutter, Dart, bundled local JSON content, local storage.
- Status: Development-ready baseline.

## Source Of Truth Rule

The SRS controls MVP scope, architecture, data models, acceptance criteria, and release constraints.

If repository documentation or code conflicts with the SRS:

1. Follow the SRS.
2. Update the conflicting repo document or implementation.
3. Record any approved change in documentation before implementation.

## Required MVP Modules

- Onboarding language selection.
- Today screen.
- Prayer category browsing.
- Prayer detail reading.
- Favorites.
- Offline search.
- Interactive Rosary.
- Novenas with 9-day progress.
- Daily local reminder.
- Settings.
- About and content source information.

## MVP Constraints

- Flutter and Dart implementation.
- Android-first, iOS-capable codebase.
- Bundled local JSON content.
- Dynamic UI rendering from content metadata.
- Local storage for preferences, favorites, reminders, Rosary progress, and novena progress.
- Core features must work offline.
- No unnecessary hardware permissions.
- Content must include source or attribution metadata where available.

## Explicit Non-MVP Items

These must not be implemented as MVP dependencies:

- Authentication, accounts, profiles, or social sign-in.
- Backend CMS, admin dashboard, cloud sync, or remote database.
- Payments, donations, subscriptions, or ads.
- Audio, video, podcasts, or guided meditation library.
- Community posting, chat, comments, or parish social network.
- Full Bible, full Catechism, Mass booking, parish management, or sacrament scheduling.
- AI spiritual advisor or automated pastoral guidance.
- Copyrighted Bible translations, Mass readings, or devotional content without permission.

## Acceptance Areas

The MVP is not complete until these SRS areas pass:

- Onboarding.
- Offline operation.
- Prayer content loaded from JSON.
- Add-new-prayer workflow.
- Favorites.
- Search.
- Rosary.
- Novenas.
- Reminder.
- Settings.
- Permissions.
- Store readiness.
