import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/theme/app_theme.dart';
import 'package:salakatoliki/shared/content/reading_markup.dart';
import 'package:salakatoliki/shared/widgets/litany_text_view.dart';
import 'package:salakatoliki/shared/widgets/novena_text_view.dart';
import 'package:salakatoliki/shared/widgets/prayer_text_view.dart';

import '../helpers/legacy_reading/litany_text_view.dart';
import '../helpers/legacy_reading/novena_text_view.dart';
import '../helpers/legacy_reading/prayer_text_view.dart';

class _Reading {
  _Reading(
    this.label,
    this.text,
    this.mode, {
    this.st = false,
    this.hs = false,
    this.allSaints = false,
    this.thanks = false,
  });
  final String label;
  final String text;
  final String mode;
  final bool st, hs, allSaints, thanks;

  Widget widget(bool legacy) {
    final value = legacy ? ReadingMarkup.plainText(text) : text;
    if (mode == 'prayer') {
      return legacy
          ? LegacyPrayerTextView(text: value, fontScale: _scale)
          : PrayerTextView(text: value, fontScale: _scale);
    }
    if (mode == 'litany') {
      return legacy
          ? LegacyLitanyTextView(
              text: value,
              stRitaStyle: st,
              fontScale: _scale,
            )
          : LitanyTextView(text: value, stRitaStyle: st, fontScale: _scale);
    }
    return legacy
        ? LegacyNovenaTextView(
            text: value,
            allSaintsStyle: allSaints,
            stRitaStyle: st,
            holySpiritStyle: hs,
            thanksgivingStyle: thanks,
            fontScale: _scale,
          )
        : NovenaTextView(
            text: value,
            allSaintsStyle: allSaints,
            stRitaStyle: st,
            holySpiritStyle: hs,
            thanksgivingStyle: thanks,
            fontScale: _scale,
          );
  }
}

double _scale = 1;

Iterable<_Reading> _readings(String language) sync* {
  for (final file in Directory(
    'assets/content/prayers/$language',
  ).listSync().whereType<File>()) {
    for (final json in jsonDecode(file.readAsStringSync()) as List) {
      yield _Reading(
        '$language:${json['id']}',
        json['body'] as String,
        json['style'] == 'standard' ? 'prayer' : 'litany',
        st: json['style'] == 'litany_st_rita',
      );
      // Rosary has always used the St Rita renderer for litany steps.
      if (json['style'] == 'litany') {
        yield _Reading(
          '$language:${json['id']}:rosary',
          json['body'] as String,
          'litany',
          st: true,
        );
      }
    }
  }
  for (final file in Directory(
    'assets/content/novenas/$language',
  ).listSync().whereType<File>()) {
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final st = json['style'] == 'st_rita';
    for (final day in json['days'] as List) {
      yield _Reading(
        '$language:${json['id']}:day${day['day']}',
        day['body'] as String,
        'novena',
        st: st,
        hs: json['style'] == 'holy_spirit',
        allSaints: json['style'] != 'standard',
      );
    }
    final closing = json['closing_prayer'] as Map?;
    if (closing != null)
      yield _Reading(
        '$language:${json['id']}:closing',
        closing['body'] as String,
        'litany',
        st: st,
      );
    final thanks = json['thanksgiving_section'] as Map?;
    if (thanks != null)
      yield _Reading(
        '$language:${json['id']}:thanks',
        thanks['body'] as String,
        'novena',
        allSaints: st,
        thanks: st,
      );
  }
}

/// Capture actual laid-out text, inherited span styles, and painted highlight
/// geometry. This covers the entire reading, including off-screen paragraphs.
List<Object?> _snapshot(WidgetTester tester) {
  final result = <Object?>[];
  void visit(RenderObject object) {
    if (object is RenderParagraph) {
      final spans = <Object?>[];
      void flatten(InlineSpan span, TextStyle? parent) {
        if (span is TextSpan) {
          final style = parent?.merge(span.style) ?? span.style;
          if (span.text != null) spans.add([span.text, style]);
          for (final child in span.children ?? <InlineSpan>[]) {
            flatten(child, style);
          }
        }
      }

      flatten(object.text, null);
      result.add([
        'text',
        spans,
        object.size,
        object.localToGlobal(Offset.zero),
      ]);
    } else if (object is RenderDecoratedBox) {
      result.add([
        'decoration',
        object.decoration,
        object.size,
        object.localToGlobal(Offset.zero),
      ]);
    }
    object.visitChildren(visit);
  }

  visit(tester.renderObject(find.byKey(const ValueKey('reading'))));
  return result;
}

void main() {
  for (final language in ['en', 'sw']) {
    for (final narrow in [false, true]) {
      testWidgets(
        'marked $language corpus preserves rendering (${narrow ? '320dp dark enlarged' : '390dp light'})',
        (tester) async {
          tester.view.physicalSize = Size(narrow ? 320 : 390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          _scale = narrow ? 1.3 : 1;
          Future<List<Object?>> render(Widget child) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: narrow ? AppTheme.dark : AppTheme.light,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: SizedBox(
                      key: const ValueKey('reading'),
                      width: double.infinity,
                      child: child,
                    ),
                  ),
                ),
              ),
            );
            expect(tester.takeException(), isNull);
            return _snapshot(tester);
          }

          for (final reading in _readings(language)) {
            final before = await render(reading.widget(true));
            final after = await render(reading.widget(false));
            expect(after, before, reason: reading.label);
          }
        },
        timeout: const Timeout(Duration(minutes: 5)),
      );
    }
  }
}
