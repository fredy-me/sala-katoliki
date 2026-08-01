import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/prayers/domain/entities/prayer_entity.dart';

/// Bridges the in-app "prayer of the day" with the Android home-screen widget.
///
/// The native widget cannot read Flutter assets, so the app pushes the
/// localized prayer data it already loads and asks the platform to redraw.
abstract final class HomeWidgetService {
  static const _providerClassName = 'SalaWidgetProvider';
  static const _titleKey = 'widget_prayer_title';
  static const _snippetKey = 'widget_prayer_snippet';
  static const _labelKey = 'widget_prayer_label';
  static const _prayerIdKey = 'widget_prayer_id';

  static const _labelEn = "TODAY'S PRAYER";
  static const _labelSw = 'SALA YA LEO';
  static const _snippetMaxLength = 140;

  static Future<void> updateTodayPrayer({
    required PrayerEntity prayer,
    required String languageCode,
  }) async {
    try {
      await HomeWidget.saveWidgetData(_titleKey, prayer.localizedTitle);
      await HomeWidget.saveWidgetData(_snippetKey, _snippet(prayer));
      await HomeWidget.saveWidgetData(
        _labelKey,
        languageCode == 'sw' ? _labelSw : _labelEn,
      );
      await HomeWidget.saveWidgetData(_prayerIdKey, prayer.id);
      await HomeWidget.updateWidget(androidName: _providerClassName);
    } on MissingPluginException {
      // Widget support is unavailable (for example, in widget tests).
    } on PlatformException {
      // The widget simply keeps its previous content; this is non-critical.
    }
  }

  static String _snippet(PrayerEntity prayer) {
    final hasDescription = prayer.description?.trim().isNotEmpty ?? false;
    final text = hasDescription
        ? prayer.description!
        : prayer.body.replaceAll('\n', ' ').trim();
    if (text.length <= _snippetMaxLength) {
      return text;
    }
    return '${text.substring(0, _snippetMaxLength - 3)}...';
  }
}
