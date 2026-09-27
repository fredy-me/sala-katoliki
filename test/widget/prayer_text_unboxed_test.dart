import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/shared/widgets/app_card.dart';
import 'package:salakatoliki/shared/widgets/litany_text_view.dart';
import 'package:salakatoliki/shared/widgets/novena_text_view.dart';

/// Enforces the rule in app_optimization.md section 0.1: prayer and novena
/// reading text is never boxed.
///
/// The two text views cannot draw a card, so this fails the moment anyone
/// reintroduces a container on them by any route.
///
/// One thing this deliberately does NOT forbid: the inline scripture highlight.
/// An opening line such as "In the name of the Father" is drawn on a subtle
/// `surfaceContainerHighest` panel with a gold rule. That is per-line text
/// styling inside a paragraph, not a card around the reading, and removing it
/// would be an unrequested visual change. It is pinned by its own test below
/// so nobody "simplifies" it away while chasing this invariant.
void main() {
  testWidgets('novena text renders its content with no card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NovenaTextView(
            text: 'First paragraph.\n\nSecond paragraph.',
          ),
        ),
      ),
    );

    expect(find.text('First paragraph.'), findsOneWidget);
    expect(find.text('Second paragraph.'), findsOneWidget);
    expect(find.byType(AppCard), findsNothing);
  });

  testWidgets('novena text renders no card in any style', (tester) async {
    final views = <NovenaTextView>[
      const NovenaTextView(text: 'Body.'),
      const NovenaTextView(text: 'Body.', allSaintsStyle: true),
      const NovenaTextView(
        text: 'Body.',
        allSaintsStyle: true,
        holySpiritStyle: true,
      ),
      const NovenaTextView(
        text: 'Body.',
        allSaintsStyle: true,
        stRitaStyle: true,
      ),
      const NovenaTextView(
        text: 'Body.',
        allSaintsStyle: true,
        thanksgivingStyle: true,
      ),
      const NovenaTextView(
        text: 'Body.',
        fontScale: 1.8,
        allSaintsStyle: true,
        stRitaStyle: true,
      ),
    ];

    for (final view in views) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: view)));

      expect(
        find.byType(AppCard),
        findsNothing,
        reason: 'novena text gained a card for $view',
      );
    }
  });

  testWidgets('litany text renders its content with no card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LitanyTextView(text: 'Line one.\nLine two.')),
      ),
    );

    expect(find.text('Line one.'), findsOneWidget);
    expect(find.text('Line two.'), findsOneWidget);
    expect(find.byType(AppCard), findsNothing);
  });

  testWidgets('litany text renders no card in st rita style', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LitanyTextView(text: 'Line one.', stRitaStyle: true),
        ),
      ),
    );

    expect(find.byType(AppCard), findsNothing);
  });

  testWidgets('the inline scripture highlight is kept', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NovenaTextView(
            text: 'In the name of the Father\nand of the Son.',
          ),
        ),
      ),
    );

    expect(
      _highlightedPanels(tester),
      isNotEmpty,
      reason:
          'the inline opening-line highlight disappeared. It is intentional '
          'styling and is not the card this suite forbids',
    );
    expect(find.byType(AppCard), findsNothing);
  });

  test('text views declare no card capability', () {
    for (final path in _textViewPaths) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        isNot(contains('showContainer')),
        reason: '$path reintroduced the showContainer flag',
      );
      expect(
        source,
        isNot(contains('AppCard(')),
        reason:
            '$path can now draw a card; the card must live at the call site',
      );
      expect(
        source,
        isNot(contains('app_card.dart')),
        reason: '$path imports AppCard, so it can be boxed again',
      );
    }
  });

  test('the two novena surfaces that show a card still do', () {
    final thanksgiving = File(_thanksgivingPath).readAsStringSync();
    final closing = File(_closingPath).readAsStringSync();

    expect(
      thanksgiving,
      contains('AppCard('),
      reason: 'novena thanksgiving lost its card for non st-rita novenas',
    );
    expect(
      closing,
      contains('AppCard('),
      reason: 'novena closing prayer lost its card for non st-rita novenas',
    );
  });
}

const _textViewPaths = [
  'lib/shared/widgets/novena_text_view.dart',
  'lib/shared/widgets/litany_text_view.dart',
];

const _thanksgivingPath =
    'lib/features/novenas/presentation/screens/novena_thanksgiving_screen.dart';

const _closingPath =
    'lib/features/novenas/presentation/screens/novena_closing_prayer_screen.dart';

/// The inline highlight panels, which are per-line styling rather than cards.
List<BoxDecoration> _highlightedPanels(WidgetTester tester) {
  final panels = <BoxDecoration>[];

  void visit(Element element) {
    final widget = element.widget;
    if (widget is Container) {
      final decoration = widget.decoration;
      if (decoration is BoxDecoration) {
        panels.add(decoration);
      }
    }
    element.visitChildren(visit);
  }

  visit(tester.element(find.byType(NovenaTextView)));
  return panels;
}
