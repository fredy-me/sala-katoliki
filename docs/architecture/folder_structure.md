# Folder Structure

This is the target MVP folder structure for Sala Katoliki. It supports Flutter development, offline-first bundled content, dynamic prayer rendering, local storage, and future content expansion without hard-coded prayer screens.

The structure is documentation-first at this stage. Move files into this shape during the architecture refactor, not by breaking current imports in one uncontrolled change.

```text
sala_katoliki/
|
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
|
├── assets/
│   ├── images/
│   │   ├── logo/
│   │   │   └── app_logo.png
│   │   ├── icons/
│   │   └── illustrations/
│   ├── fonts/
│   └── content/
│       ├── categories/
│       │   └── categories.json
│       ├── prayers/
│       │   ├── en/
│       │   │   ├── common_prayers.json
│       │   │   ├── marian_prayers.json
│       │   │   ├── confession_prayers.json
│       │   │   ├── mass_prayers.json
│       │   │   └── divine_mercy.json
│       │   └── sw/
│       │       ├── common_prayers.json
│       │       ├── marian_prayers.json
│       │       ├── confession_prayers.json
│       │       ├── mass_prayers.json
│       │       └── divine_mercy.json
│       ├── novenas/
│       │   ├── en/
│       │   │   ├── divine_mercy_novena.json
│       │   │   ├── holy_spirit_novena.json
│       │   │   ├── st_joseph_novena.json
│       │   │   └── st_jude_novena.json
│       │   └── sw/
│       │       ├── divine_mercy_novena.json
│       │       ├── holy_spirit_novena.json
│       │       ├── st_joseph_novena.json
│       │       └── st_jude_novena.json
│       ├── rosary/
│       │   ├── en/
│       │   │   ├── rosary_prayers.json
│       │   │   └── mysteries.json
│       │   └── sw/
│       │       ├── rosary_prayers.json
│       │       └── mysteries.json
│       └── metadata/
│           ├── languages.json
│           ├── content_manifest.json
│           └── app_info.json
|
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── asset_paths.dart
│   │   │   └── storage_keys.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_spacing.dart
│   │   ├── localization/
│   │   │   ├── app_localizations.dart
│   │   │   ├── localization_service.dart
│   │   │   └── supported_languages.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   └── failure.dart
│   │   └── utils/
│   │       ├── app_date_utils.dart
│   │       ├── json_loader.dart
│   │       └── text_utils.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   └── environment.dart
│   ├── routes/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── app_bottom_nav.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_empty_state.dart
│   │   │   ├── app_error_state.dart
│   │   │   ├── app_loading.dart
│   │   │   ├── app_search_bar.dart
│   │   │   ├── prayer_text_view.dart
│   │   │   └── section_header.dart
│   │   ├── models/
│   │   │   └── language_model.dart
│   │   └── services/
│   │       ├── local_storage_service.dart
│   │       └── notification_service.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── prayer_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── novena_model.dart
│   │   │   ├── rosary_model.dart
│   │   │   └── user_preferences_model.dart
│   │   ├── repositories/
│   │   │   ├── prayer_repository.dart
│   │   │   ├── category_repository.dart
│   │   │   ├── novena_repository.dart
│   │   │   ├── rosary_repository.dart
│   │   │   └── settings_repository.dart
│   │   └── datasources/
│   │       ├── local_content_datasource.dart
│   │       ├── local_storage_datasource.dart
│   │       └── notification_datasource.dart
│   └── features/
│       ├── onboarding/
│       ├── today/
│       ├── prayers/
│       ├── rosary/
│       ├── novenas/
│       ├── library/
│       └── settings/
|
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
|
├── docs/
│   ├── srs/
│   ├── architecture/
│   └── content_guidelines/
|
├── tools/
│   ├── validate_content.dart
│   └── generate_content_manifest.dart
|
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── LICENSE
└── .gitignore
```

## Most Important MVP Folders

- `assets/content/`: all prayer, Rosary, novena, category, and metadata JSON.
- `lib/data/`: shared models, repositories, and local data sources.
- `lib/features/`: feature screens, controllers, widgets, and feature services.
- `lib/shared/`: reusable UI and app-level services.
- `lib/core/`: constants, theme, localization, errors, and utilities.

## Pubspec Asset Registration

Register content and visual assets like this when the folders exist:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/logo/
    - assets/images/icons/
    - assets/images/illustrations/
    - assets/content/categories/
    - assets/content/prayers/en/
    - assets/content/prayers/sw/
    - assets/content/novenas/en/
    - assets/content/novenas/sw/
    - assets/content/rosary/en/
    - assets/content/rosary/sw/
    - assets/content/metadata/
```

Do not register non-existent directories before creating them, because Flutter asset validation can fail.
