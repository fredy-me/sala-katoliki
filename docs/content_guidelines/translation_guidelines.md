# Translation Guidelines

Sala Katoliki MVP supports English and Kiswahili.

## Language Codes

- `en`: English.
- `sw`: Kiswahili.

## Translation Rules

- Use the same `id` for the same prayer in every language.
- Set the `language` field to the file language.
- Translate `title`, `description`, `body`, and `tags`.
- Keep `category`, `type`, and source metadata consistent unless the source differs.
- Do not rely on machine translation without human review.
- Missing translations must not crash the app. The UI should show a fallback or a clear unavailable message.

## Kiswahili Example

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

## Review Checklist

- Prayer meaning is preserved.
- Catholic terminology is appropriate.
- Title matches common local usage where known.
- Text is readable on mobile.
- Source or approval status is documented.
