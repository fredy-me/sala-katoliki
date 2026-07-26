# Screenshots

This directory contains screenshots of the Sala Katoliki app for documentation and store listing purposes.

## Required Screenshots

The following screenshots are needed to complete the app documentation:

| # | Filename | Screen | Description |
|---|----------|--------|-------------|
| 1 | `onboarding_english.png` | Language Selection | English option selected |
| 2 | `onboarding_kiswahili.png` | Language Selection | Kiswahili option selected |
| 3 | `today.png` | Today Screen | Daily prayer card, novena card, Rosary shortcut, quick actions |
| 4 | `rosary_home.png` | Rosary Home | Today's mystery hero, start/continue actions |
| 5 | `rosary_step.png` | Rosary Step | Bead progress, prayer title/body, navigation controls |
| 6 | `prayer_categories.png` | Pray Categories | Search field and category cards |
| 7 | `prayer_detail.png` | Prayer Detail | Prayer title, body, and favorite button |
| 8 | `novenas_list.png` | Novenas List | Active novena hero and browse list |
| 9 | `novena_detail.png` | Novena Detail | Progress panel, day list, reminder toggle |
| 10 | `novena_day.png` | Novena Day Reading | Day content and mark-complete action |
| 11 | `favorites.png` | Favorites | Saved prayers list |
| 12 | `settings.png` | Settings | Language, font, theme, reminder options |
| 13 | `about.png` | About | App identity, version, sources, disclaimer |

## How to Take Screenshots

### Requirements

- Use a physical Android device or emulator
- Device resolution: 1080x2400 or similar (modern Android phone)
- Take screenshots in both English and Kiswahili if applicable
- Use light theme for consistency

### Steps

1. Run the app on a device or emulator
2. Navigate to each screen listed above
3. Take a screenshot using device controls:
   - **Android**: Power + Volume Down
   - **Emulator**: Use the screenshot button in the toolbar
4. Crop the screenshot to remove device chrome (status bar, navigation bar)
5. Save with the filename from the table above
6. Place the file in this directory

### Image Guidelines

- **Format**: PNG
- **Resolution**: 1080px width minimum
- **Aspect ratio**: 9:19.5 (standard Android phone)
- **Background**: Use the app's actual background (warm cream/off-white)
- **State**: Show realistic content, not placeholder text
- **Privacy**: Do not show personal information

## How to Add Screenshots

1. Take the screenshot following the guidelines above
2. Save with the correct filename from the table
3. Place in this directory (`docs/screenshots/`)
4. Submit a pull request with the screenshots
5. The README.md will automatically reference them

## Updating the README

Once screenshots are added, update the main `README.md` to include them:

```markdown
## Screenshots

| Onboarding | Today | Pray |
|------------|-------|------|
| ![Onboarding](docs/screenshots/onboarding_english.png) | ![Today](docs/screenshots/today.png) | ![Pray](docs/screenshots/prayer_categories.png) |

| Rosary | Novenas | Favorites |
|--------|---------|-----------|
| ![Rosary](docs/screenshots/rosary_step.png) | ![Novenas](docs/screenshots/novena_detail.png) | ![Favorites](docs/screenshots/favorites.png) |

| Settings | About |
|----------|-------|
| ![Settings](docs/screenshots/settings.png) | ![About](docs/screenshots/about.png) |
```
