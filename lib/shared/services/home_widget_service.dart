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

  /// The payload most recently written successfully.
  ///
  /// Set only after a successful write, so a failed attempt is retried on the
  /// next call rather than being silently skipped.
  static String? _lastWrittenPayload;

  static Future<void> updateTodayPrayer({
    required PrayerEntity prayer,
    required String languageCode,
  }) async {
    final title = prayer.localizedTitle;
    final snippet = _snippet(prayer);
    final label = languageCode == 'sw' ? _labelSw : _labelEn;

    // The prayer of the day only changes once a day, but this is called on
    // every rebuild of the today screen. Skip the platform round trip when
    // nothing actually changed.
    final payload = '$title\u0000$snippet\u0000$label\u0000${prayer.id}';
    if (payload == _lastWrittenPayload) {
      return;
    }

    try {
      await Future.wait([
        HomeWidget.saveWidgetData(_titleKey, title),
        HomeWidget.saveWidgetData(_snippetKey, snippet),
        HomeWidget.saveWidgetData(_labelKey, label),
        HomeWidget.saveWidgetData(_prayerIdKey, prayer.id),
      ]);
      await HomeWidget.updateWidget(androidName: _providerClassName);
      _lastWrittenPayload = payload;
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
