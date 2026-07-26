---
name: Content Request
about: Request addition of prayer, novena, or rosary content
title: "[CONTENT] "
labels: content, needs-triage
assignees: ''
---

## Content Type

What type of content are you requesting?

- [ ] Prayer (Common, Marian, Confession, Mass, Divine Mercy, Other)
- [ ] Novena (9-day devotion)
- [ ] Rosary (Mysteries, Prayers)
- [ ] Category update
- [ ] Metadata update

## Language

- [ ] English
- [ ] Kiswahili
- [ ] Both

## Content Details

### Title
[Enter the prayer/novena title]

### Category
[Enter the category ID, e.g., common_prayers, marian_prayers]

### Description
[Brief description of the content]

### Source
[Where does this content come from? Is it public domain?]

### Licensing
- [ ] Public domain
- [ ] Creative Commons (specify license)
- [ ] Written permission obtained (attach proof)
- [ ] Traditional Catholic prayer (no known copyright)

## JSON Draft

If you have the content ready, paste the JSON here:

```json
{
  "id": "unique_snake_case_id",
  "type": "prayer",
  "category": "category_id",
  "language": "en",
  "title": "Prayer Title",
  "body": "Prayer text here..."
}
```

## Content Rights Confirmation

By submitting this request, you confirm:

- [ ] You have verified the content is not copyrighted
- [ ] You have obtained permission if the content is copyrighted
- [ ] You have included proper attribution in the `source` field
- [ ] You understand this content will be publicly available under GPL-3.0

## Checklist

- [ ] I have searched existing content to avoid duplicates
- [ ] I have verified content rights and licensing
- [ ] I have prepared JSON in the correct format
- [ ] I have included source attribution
- [ ] I have confirmed both English and Kiswahili versions (if applicable)
