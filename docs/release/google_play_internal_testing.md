# Google Play Internal Testing Metadata

## App Listing Draft

App name: Sala Katoliki

Short description:

Offline Catholic prayers, Rosary, novenas, and daily reminders in English and Kiswahili.

Full description:

Sala Katoliki is an offline-first Catholic prayer app for personal devotion. The MVP includes English and Kiswahili prayers, Rosary guidance, novena progress tracking, favorites, search, and optional local daily reminders. Prayer content is bundled with the app so core features work without internet access.

## Category

- App category: Lifestyle
- Tags: Prayer, Catholic, Rosary, Devotional

## Contact And Policy

- Developer: Busara Digital
- Support email: to be confirmed before public release
- Website: to be confirmed before public release
- Privacy policy: to be confirmed before public release

Public release is blocked until support and privacy policy links are live.

## Data Safety Draft

The MVP:

- Does not require account registration.
- Does not collect names, phone numbers, email addresses, location, contacts, photos, audio, or payment data.
- Stores preferences, favorites, reminder settings, Rosary progress, and novena progress locally on the device.
- Does not send user content or prayer progress to a backend.

Notification permission is requested only when the user enables reminders.

## Internal Testing Release Notes — 1.1.0 (build 13)

Mid-size update to the existing Android MVP:

- Prayer and novena content now supports declared presentation styles and a
  variable number of novena days, including the 12-day St. Rita devotion.
- Switching between bottom-navigation tabs keeps each visited tab's scroll
  position.
- Content loading, startup work, and reading rendering have been streamlined.
- English and Kiswahili prayer, Rosary, favorites, search, and local reminders
  remain available offline.

Device visual and performance checks are still required before publishing these
notes with a release.

Known limitations:

- Support, website, and privacy policy links must be finalized before public production release.
- Content rights review remains release-blocking for public distribution.
- Remote content sync is not included in the MVP.
