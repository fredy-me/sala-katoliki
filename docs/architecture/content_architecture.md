# Content Architecture

Sala Katoliki content is local, bundled, structured JSON. Flutter screens must render content dynamically instead of embedding prayer text in widgets.

## Hard Rule

Do not put prayer text directly in Flutter screens:

```dart
Text("Hail Mary, full of grace...")
```

Prayer text must come from content files such as:

```text
assets/content/prayers/en/common_prayers.json
assets/content/prayers/sw/common_prayers.json
```

The screen loads a prayer entity and displays its `title`, `readingText`, metadata, and favorite state. Reading widgets interpret the explicit markers in `readingText`; `body`/`text()` remove those markers for search, sharing, and widget snippets. Formatting roles and profiles are documented in [the content guide](../CONTENT_GUIDE.md#explicit-reading-markers-part-67).

## Content Groups

### Categories

`assets/content/categories/categories.json`

Defines category IDs, localized titles, descriptions, icons, and sort order.

### Prayers

`assets/content/prayers/{language}/{category_file}.json`

Stores prayer records by language and category. MVP languages are:

- `en`: English.
- `sw`: Kiswahili.

### Novenas

`assets/content/novenas/{language}/{novena_id}.json`

Stores ordered novena days with a required integer `day_count` matching the array length and both translations. Standard novenas have nine days; the existing 12-day St Rita exception remains recorded in the implementation plan. The app derives progress bounds from the array rather than an ID-specific constant.

### Rosary

`assets/content/rosary/{language}/rosary_prayers.json`

Stores prayers used by Rosary step flow.

`assets/content/rosary/{language}/mysteries.json`

Stores mystery groups and local-day mapping.

### Metadata

`assets/content/metadata/languages.json`

Lists supported languages.

`assets/content/metadata/content_manifest.json`

Lists available content files, versions, and validation metadata.

`assets/content/metadata/app_info.json`

Stores content source, support, privacy, and app information shown in About.

## Dynamic Rendering Flow

```text
Flutter screen
  -> controller/provider
  -> repository
  -> local content datasource
  -> JSON asset
  -> model
  -> domain entity
  -> rendered UI
```

## Why This Structure Is Required

- Clean Flutter code.
- Offline-first support.
- Easy prayer additions later.
- English and Kiswahili support.
- Separation between UI, business logic, and content.
- Future backend or content sync support behind repository contracts.
- Better tests and open-source contribution workflow.
