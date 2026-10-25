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

Legacy prayer content under `assets/data/` has been removed. MVP content must live under `assets/content/` and be registered in `pubspec.yaml`.

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
  "style": "standard",
  "body": "[[plain]]Hail Mary, full of grace...[[/plain]]"
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
  "style": "standard",
  "body": "[[plain]]Hail Mary, full of grace...[[/plain]]",
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
- A novena has no days, unordered/duplicate/missing day numbers, an incorrect optional `day_count`, or different day counts across languages.
- A content file is missing from the manifest, a listed file is absent, or a path is duplicated.
- EN/SW prayer or novena IDs differ without a valid declared prayer alias.
- Rosary steps reference unknown prayers or mystery IDs.

## Legal And Attribution

Every content source must be reviewed before publishing.

Use of copyrighted Bible translations, Mass readings, or devotional content requires written permission or valid licensing. If a content item has a known source, include it in the `source` field and surface it in Prayer Detail or About where appropriate.

## Generate The Manifest

Add matching English and Kiswahili content under `assets/content/prayers/en/`
and `sw/`, or `assets/content/novenas/en/` and `sw/`. Prayer files contain arrays;
each novena file contains one object. Keep IDs stable so saved favorites,
progress, and links continue to resolve. New novenas can have any positive
number of days, numbered in array order from 1 through the last day.

Run one command to register new files:

```bash
dart run tool/generate_content_manifest.dart
```

The generator preserves existing file order and appends new paths in sorted
order. It changes membership, not prayer text. Then validate:

```bash
dart run tools/validate_content.dart
dart run tool/generate_content_manifest.dart --check
```

`--check` reads only and fails if the manifest is stale. The validator also
checks manifest membership against disk. Do not use the manifest generator as
approval to delete content that existing users have favorited or started.

English and Kiswahili should use identical IDs. The existing Divine Mercy
exception is declared in `assets/content/metadata/id_aliases.json` as
`prayer_id_aliases` mapping the Swahili ID to the English ID. Both endpoints
must exist; this declaration is shared by validation and deep-link resolution.
It does not rename IDs already stored in favorites or recents.

Presentation profiles and explicit body markers are declared in JSON. New
content using the documented roles requires no Dart edits. A new visual
treatment still requires implementation. Localization consolidation (6.8)
is pending.

### Declaring presentation styles (Part 6.1)

Every prayer and novena must declare a top-level `style` string. The validator
rejects missing or unknown styles. The reading screens use this field rather
than content IDs or prayer categories to select their text renderer.

| Content | Style | Rendering |
| --- | --- | --- |
| Prayer | `standard` | Standard prayer paragraphs |
| Prayer | `litany` | Litany paragraphs |
| Prayer | `litany_st_rita` | Litany with the existing St Rita response formatting |
| Novena | `standard` | Standard novena paragraphs |
| Novena | `all_saints` | All Saints paragraph formatting |
| Novena | `holy_spirit` | All Saints formatting with virtue headings |
| Novena | `st_rita` | All Saints formatting with St Rita responses and the existing uncarded closing/thanksgiving sections |

Use the same style for both translations. These profiles preserve the existing
rendering; they do not change prayer text or saved progress. For novenas other
than `st_rita`, closing and thanksgiving sections retain their existing cards.
Bundled readings declare formatting with the markers below. The legacy
prefix rules remain only for unmarked widget callers; validation requires
explicit markers in all bundled content.

After creating or changing content, run:

```sh
dart run tool/generate_content_manifest.dart
dart run tools/validate_content.dart
```


### Explicit reading markers (Part 6.7)

Wrap each non-empty prayer/litany line, or each novena paragraph, in a paired
marker. Keep existing newlines between lines and blank lines between novena
paragraphs. Marker names are lowercase and do not depend on language or wording.

```json
{
  "id": "authoring_probe",
  "type": "prayer",
  "category": "common_prayers",
  "language": "en",
  "title": "Authoring probe",
  "style": "standard",
  "body": "[[heading]]A rephrased title[[/heading]]\n\n[[plain]]Prayer text.[[/plain]]\n[[response]]A rephrased answer.[[/response]]"
}
```

| Reading | Allowed roles |
| --- | --- |
| Standard prayer | `plain`, `heading`, `response` |
| Litany, including a novena closing prayer | `plain`, `heading`, `response`, `lamb`, `panel_gold`, `panel_outline` |
| Novena day or thanksgiving | `plain`, `heading`, `response`, `invocation`, `italic`, `rich`, `group`, `highlight` |

`heading` keeps the existing heading appearance (uppercased for litanies and
novenas). `invocation` adds the existing colored cross before a novena opening.
`response` uses the selected prayer/litany response appearance; a novena response
is colored italic text. `lamb` is italic in the St Rita litany profile and an
outlined inline panel in the standard litany profile. `panel_gold` and
`panel_outline` reproduce existing standard-litany line highlights; use them
with `style: "litany"`. `highlight` reproduces the existing individual novena
line panel. None of these markers wraps a whole reading in a card.

Use `group` for parts of one novena paragraph separated by the existing small
vertical gap. Each non-empty child must have its own marker:

```text
[[group]][[heading]]Let us pray:[[/heading]][[plain]]The prayer body.[[/plain]][[/group]]
```

Use `rich` for inline italic text without a paragraph break. Only `italic`
markers may be nested inside `rich`:

```text
[[rich]]Prayer text, [[italic]]an italic refrain[[/italic]], and more text.[[/rich]]
```

Other leaf roles cannot contain nested markers. Groups may contain supported
novena roles; nesting is limited to eight levels. Keep each group or rich block
inside one paragraph. Standard prayer underscore italics remain supported
inside a marked line; existing asterisks retain their previous display behavior.

Models expose `readingText` to reading widgets. Their `body`/`text()` APIs
remove only these annotations, so search, sharing, native widget snippets, and
saved-progress keys keep their existing content. Do not pass raw marked asset
strings to those plain-text consumers.

Validation rejects unknown/mismatched markers, missing declarations, empty
blocks, roles unsupported by the renderer, and invalid nesting. Rephrasing the
text inside a marker keeps its declared formatting. After editing either
translation, run the generator and validator shown above. Corpus parity tests
compare all bundled readings with the pre-marker renderer; intended future
appearance/content changes require a deliberate update to that evidence.
