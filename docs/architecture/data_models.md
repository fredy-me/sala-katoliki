# Data Models

These are the MVP data models used by the bundled JSON content architecture.

## Prayer

Required fields:

- `id`: unique lowercase snake_case identifier.
- `type`: content type, usually `prayer`.
- `category`: category ID.
- `language`: `en` or `sw`.
- `title`: localized prayer title.
- `body`: localized prayer text.

Optional fields:

- `description`
- `tags`
- `source`
- `version`
- `last_updated`
- `is_offline_available`

Example:

```json
[
  {
    "id": "hail_mary",
    "type": "prayer",
    "category": "common_prayers",
    "language": "en",
    "title": "Hail Mary",
    "description": "A traditional Marian prayer.",
    "body": "Hail Mary, full of grace, the Lord is with thee...",
    "tags": ["mary", "marian", "rosary"],
    "source": "Traditional Catholic Prayer",
    "version": 1,
    "last_updated": "2026-06-02",
    "is_offline_available": true
  }
]
```

Kiswahili example:

```json
[
  {
    "id": "hail_mary",
    "type": "prayer",
    "category": "common_prayers",
    "language": "sw",
    "title": "Salamu Maria",
    "description": "Sala ya kimapokeo kwa Bikira Maria.",
    "body": "Salamu Maria, umejaa neema...",
    "tags": ["maria", "rozari", "sala"],
    "source": "Sala ya Kimapokeo ya Kikatoliki",
    "version": 1,
    "last_updated": "2026-06-02",
    "is_offline_available": true
  }
]
```

## Category

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

## Novena

Expected fields:

- `id`
- `language`
- `title`
- `description`
- `days`: array of exactly 9 day objects.
- `source`
- `version`
- `last_updated`

Each day object should include:

- `day`: integer from 1 to 9.
- `title`
- `body`

## Rosary

Rosary content is split into:

- Prayers used by Rosary sequence.
- Mystery definitions and day mapping.
- Runtime progress stored locally as `mystery_id` and `step_index`.

## User Preferences

Stored locally:

- `selected_language`
- `font_size`
- `theme`
- `reminder_enabled`
- `reminder_time`

## Favorite

Stored locally:

- `prayer_id`

## Novena Progress

Stored locally:

- `novena_id`
- `completed_days`

## Rosary Progress

Stored locally:

- `mystery_id`
- `step_index`
