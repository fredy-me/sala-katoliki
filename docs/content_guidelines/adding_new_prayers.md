# Adding New Prayers

Prayer additions must be content-only changes unless a new content type is introduced.

## Rule

Do not create a new Flutter screen for a new prayer. Add or edit JSON content, then let the app render it dynamically.

Bad:

```dart
Text("Hail Mary, full of grace...")
```

Good:

```text
assets/content/prayers/en/common_prayers.json
assets/content/prayers/sw/common_prayers.json
```

## Steps

1. Choose the correct category file, such as `common_prayers.json` or `marian_prayers.json`.
2. Add an English record under `assets/content/prayers/en/`.
3. Add the Kiswahili record under `assets/content/prayers/sw/` when translation is available.
4. Use the same `id` across translations.
5. Include required fields: `id`, `type`, `category`, `language`, `title`, and `body`.
6. Include source and version metadata when available.
7. Run content validation before release.
8. Verify the prayer appears in category, detail, favorites, and search flows.

## Example

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

## Validation Checklist

- ID is lowercase snake_case.
- ID is unique.
- Language is `en` or `sw`.
- Category exists in `categories.json`.
- Body is not empty.
- Source is reviewed before release.
- Prayer can be found offline through search.
