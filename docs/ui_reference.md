# UI Reference

The UI reference folder for Sala Katoliki is:

`/home/meck/Desktop/Sala-picturesUI`

It contains 13 PNG mobile screenshots. These screenshots are the visual implementation reference for the MVP, while the SRS remains the product and requirements source of truth.

## Referenced Screens

| File | Screen / State | Notes |
| --- | --- | --- |
| `Pasted image.png` | Language selection, English selected | First-launch language selection in English. |
| `Pasted image (2).png` | Language selection, Kiswahili selected | Kiswahili copy and continue action. |
| `Pasted image (3).png` | Today | Daily prayer card, active novena card, Rosary shortcut, quick actions, reminder row. |
| `Pasted image (4).png` | Holy Rosary home | Today mystery hero, start/continue actions, mystery list. |
| `Pasted image (5).png` | Rosary step | Current mystery, bead progress, prayer title/body, previous/next/pause/restart. |
| `Pasted image (6).png` | Pray categories | Search field and two-column category cards. |
| `Pasted image (7).png` | Novenas list | Active novena hero and browse novenas list. |
| `Pasted image (8).png` | Novena detail, Day 1 | Progress panel, day list, reminder toggle. |
| `Pasted image (9).png` | Library | Search, favorites carousel, tool rows, settings/about entries. |
| `Pasted image (10).png` | About | App identity, version, source/disclaimer/contact cards. |
| `Pasted image (11).png` | Favorites | Saved prayers list and localized bottom nav labels. |
| `Pasted image (12).png` | Novena detail, Day 3 | Completed/current/locked day states. |
| `Pasted image (13).png` | Novena day reading | Day content sections and mark-complete action. |

## Visual Rules

- Use a warm cream/off-white app background.
- Use dark navy for primary cards and primary filled buttons.
- Use gold for highlights, selected states, progress, and active nav icons.
- Use white rounded cards with subtle borders/shadows for lists and modules.
- Use serif headings for prayer/product titles and readable body text for prayer content.
- Keep mobile-first spacing generous, but dense enough for repeated daily use.
- Maintain a four-tab bottom navigation: Today, Pray, Novenas, Library.
- Primary touch targets should be at least 48 x 48 dp where practical.
- Prayer reading screens should avoid visual clutter and prioritize readable text.

## Screen Implementation Targets

### Onboarding

- Splash and language selection.
- English and Kiswahili options.
- Selected option uses gold border/tint and check state.
- Continue button appears once a language is selected.

### Today

- Greeting/eyebrow text.
- App title.
- Today's prayer hero card.
- Continue novena card with progress.
- Rosary today card.
- Quick actions grid.
- Reminder status row.

### Pray

- Title and short subtitle.
- Search bar.
- Two-column prayer category cards.
- Category card includes icon, title, description, and prayer count.

### Rosary

- Rosary home with today's mystery hero.
- Mystery cards with day mapping.
- Rosary step screen with:
  - mystery title,
  - bead progress,
  - decade/bead label,
  - current prayer title and body,
  - previous/next controls,
  - pause/save and restart actions.

### Novenas

- Active novena hero on list screen.
- Browse list with start/continue state.
- Detail screen with progress panel and nine day rows.
- Completed, current, locked/not-started, and open states.
- Day reading screen with opening prayer, intention, main prayer, closing prayer, and mark-complete action.

### Library

- Search entry.
- Favorites carousel.
- Rows for Favorites, Recently Opened, All Prayers, Offline Content, Settings, and About.

### Settings And About

- Settings reachable from Library and bottom navigation flows where appropriate.
- About screen includes app logo, name, version, developer, open-source note, content sources, disclaimer, and contact/website.

## Implementation Notes

- Build reusable cards, list rows, search bars, bottom navigation, progress bars, and prayer text views in `lib/shared/widgets/`.
- Keep all screen text localizable.
- Do not hard-code prayer body text in widgets.
- Use dynamic content counts from repositories instead of static values once content loading is implemented.
- Verify layouts at 320 dp logical width and common Android/iOS phone sizes.
