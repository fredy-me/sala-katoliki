# Content Guide

Sala Katoliki MVP content must be bundled locally as JSON and rendered dynamically by the UI.

Adding a new prayer must require content changes only, not a new screen.

## Recommended Asset Structure

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
        holy_spirit_novena.json
        st_joseph_novena.json
        st_jude_novena.json
      sw/
        divine_mercy_novena.json
        holy_spirit_novena.json
        st_joseph_novena.json
        st_jude_novena.json
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

The current project may still contain older content under `assets/data/`. During restructuring, move MVP content to `assets/content/` and register it in `pubspec.yaml`.

Detailed content workflows are documented in:

- [Adding New Prayers](content_guidelines/adding_new_prayers.md)
- [Translation Guidelines](content_guidelines/translation_guidelines.md)
- [Content Rights](content_guidelines/content_rights.md)

## Prayer Schema

Required fields:

```json
{
  "id": "hail_mary",
  "type": "prayer",
  "category": "common_prayers",
  "language": "en",
  "title": "Hail Mary",
  "body": "Hail Mary, full of grace..."
}
```

Recommended full fields:

```json
{
  "id": "hail_mary",
  "type": "prayer",
  "category": "common_prayers",
  "language": "en",
  "title": "Hail Mary",
  "description": "Traditional Marian prayer.",
  "body": "Hail Mary, full of grace...",
  "tags": ["marian", "daily", "rosary"],
  "source": "Traditional Catholic prayer",
  "version": 1,
  "last_updated": "2026-06-02",
  "is_offline_available": true
}
```

## Category Schema

```json
{
  "id": "common_prayers",
  "title": {
    "en": "Common Prayers",
    "sw": "Sala za Kawaida"
  },
  "description": {
    "en": "Essential Catholic prayers for daily use.",
    "sw": "Sala muhimu za Kikatoliki kwa matumizi ya kila siku."
  },
  "sort_order": 1,
  "icon": "hands_prayer"
}
```

## ID And Language Rules

- IDs must be lowercase `snake_case`.
- Prayer IDs must be unique across the loaded content set.
- Supported language codes for MVP are `en` and `sw`.
- Category IDs in prayers must reference an existing category.
- Missing optional fields must not crash the app.
- Missing translations must use a safe fallback or unavailable message.

## Content Validation

Validation should fail when:

- A required field is missing.
- A language code is not `en` or `sw`.
- A duplicate ID exists.
- A prayer references an unknown category.
- A novena does not contain exactly 9 valid day objects.
- Rosary steps reference unknown prayers or mystery IDs.

## Legal And Attribution

Every content source must be reviewed before publishing.

Use of copyrighted Bible translations, Mass readings, or devotional content requires written permission or valid licensing. If a content item has a known source, include it in the `source` field and surface it in Prayer Detail or About where appropriate.
