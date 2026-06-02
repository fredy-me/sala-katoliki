# Architecture

Sala Katoliki uses a simple offline-first Flutter architecture defined by the MVP SRS.

The canonical target folder structure is documented in [folder_structure.md](architecture/folder_structure.md). Content-specific architecture is documented in [content_architecture.md](architecture/content_architecture.md), and JSON model details are documented in [data_models.md](architecture/data_models.md).

```text
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

## Layer Responsibilities

### Presentation

Screens and widgets. This layer renders app state, receives taps and text input, and delegates work to providers/use cases.

Examples:

- Language selection screen.
- Today screen.
- Prayer category list.
- Prayer detail screen.
- Rosary step screen.
- Novena detail screen.
- Settings screen.

### Domain

Entities, repository contracts, and use cases. This layer holds business rules without knowing whether content came from bundled JSON or a future remote service.

Examples:

- `Prayer`
- `Category`
- `Novena`
- `RosaryProgress`
- `PrayerRepository`
- `GetPrayersByCategory`
- `SearchPrayers`

### Data And Content

Models, JSON parsing, content loading, and repository implementations.

The MVP reads bundled JSON assets. Future remote content may be added behind the same repository contracts, but the app must not depend on remote content for core MVP behavior.

### Local Storage

Local device persistence for low-sensitivity user data:

- Selected language.
- Theme preference.
- Font size.
- Favorite prayer IDs.
- Reminder preference and time.
- Active Rosary progress.
- Active novena and completed days.

Encrypted storage is not required for MVP because no sensitive personal data is collected.

### Notifications

Local notifications only. Push notifications are not part of the MVP.

The notification service should be isolated so Android/iOS permission and scheduling details do not leak into feature UI.

## State Model

Content loading follows this SRS state flow:

```text
Uninitialized
  -> LoadingSettings
  -> LoadingContent
  -> Ready
```

Failure path:

```text
LoadingContent
  -> Error
  -> FallbackContent
  -> Ready
```

Rosary progress follows:

```text
Not Started
  -> In Progress
  -> Paused
  -> Completed
  -> Reset
```

## Navigation

The MVP uses four main sections:

- Today.
- Pray.
- Novenas.
- Library.

Search, Favorites, Prayer Detail, Rosary Step, Novena Detail, Settings, and About may be pushed from those sections.

## Permissions

Allowed:

- Notification permission where required by the OS.

Not allowed for MVP:

- Location.
- Camera.
- Microphone.
- Contacts.
- Biometrics.
- Bluetooth.
- NFC.
- Health APIs.
- Payment APIs.

## Performance Targets

- Cold startup: under 2 seconds on modern devices, under 3 seconds on low-end supported Android devices.
- Prayer detail load: under 1 second from tap to rendered bundled content.
- Search response: under 1 second for MVP content size.
- Runtime memory target: under 150 MB on common devices.
- App remains text-first and avoids audio/video assets in MVP.
