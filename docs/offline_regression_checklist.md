# Sala Katoliki Offline Regression Checklist

Use this checklist before release candidates and after changes touching content loading, local storage, routing, reminders, Rosary, or novenas.

Source of truth: `docs/implementation_phases.md`, Phase 11.

## Setup

- Install the app on a device or emulator.
- Open the app once online only if required to install dependencies or assets during development.
- Enable airplane mode.
- Confirm Wi-Fi and mobile data are disabled.
- Relaunch the app.

## Required Offline Checks

### Onboarding

- First launch shows language selection.
- English selection opens Today.
- Kiswahili selection opens Today.
- Selected language persists after app restart.

### Today

- Today loads without network.
- Daily prayer card is visible.
- Novena card shows either no active novena or active progress.
- Rosary card opens Rosary.
- Reminder row reflects local reminder settings.

### Prayers

- Pray tab loads category JSON.
- Category opens prayer list.
- Prayer detail opens and shows title, body, category, and source.
- Search works for title, body, tags, and category.
- Empty search state is readable.

### Favorites And Library

- Favorite/unfavorite works offline.
- Favorites persist after restart.
- Library search works offline.
- Recently opened prayers persist after restart.

### Rosary

- Rosary home loads bundled mysteries.
- Today mystery is suggested from local weekday.
- Start opens guided step flow.
- Previous, next, pause, continue, restart, and finish work.
- Saved progress survives navigation away from the Rosary screen.
- Corrupt stored mystery ID or step index resets safely.

### Novenas

- Novenas list loads bundled JSON.
- Starting a novena stores active novena ID.
- Day reading opens offline.
- Marking a day complete updates local progress.
- Today continues to the next novena day.
- Invalid completed day values are ignored safely.

### Settings And About

- Language changes persist.
- Font size changes persist.
- Theme mode changes persist.
- Daily reminder can be enabled, changed, and disabled.
- Notification permission is requested only when enabling reminders.
- Permission denial leaves a readable message and keeps reminders disabled.
- About shows version, developer, open-source note, content sources, disclaimer, and contact/website note.

## External Links

The current MVP does not open external links from the app. Production links for support, website, and privacy policy must be added only after they are available and must fail gracefully when offline.

## Pass Criteria

- No screen blocks on internet access.
- No crash from missing network.
- No crash from corrupt local progress.
- User-facing error states are readable and non-technical.
