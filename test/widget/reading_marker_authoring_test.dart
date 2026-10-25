import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/theme/app_theme.dart';
import 'package:salakatoliki/shared/widgets/prayer_text_view.dart';
import 'package:salakatoliki/shared/widgets/litany_text_view.dart';
import 'package:salakatoliki/shared/widgets/novena_text_view.dart';

void main() {
  testWidgets('declared roles survive rephrasing and override legacy wording', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              PrayerTextView(
                text: '[[heading]]A newly worded title[[/heading]]',
              ),
              LitanyTextView(
                text:
                    '[[response]]A newly translated answer[[/response]]\n[[plain]]ALL CAPS REMAINS PLAIN[[/plain]]',
                stRitaStyle: true,
              ),
              NovenaTextView(
                text:
                    '[[invocation]]A newly worded invocation[[/invocation]]\n\n[[heading]]A newly worded section[[/heading]]\n\n[[rich]]Before [[italic]]a newly worded refrain[[/italic]] after[[/rich]]',
              ),
            ],
          ),
        ),
      ),
    );
    final title =
        tester.widget<Text>(find.byType(Text).first).textSpan! as TextSpan;
    expect(
      (title.children!.first as TextSpan).style!.fontWeight,
      FontWeight.w800,
    );
    expect(find.text('A newly translated answer'), findsOneWidget);
    final response = tester.widget<Text>(
      find.text('A newly translated answer'),
    );
    expect(response.style!.fontStyle, FontStyle.italic);
    final plain = tester.widget<Text>(find.text('ALL CAPS REMAINS PLAIN'));
    expect(plain.style!.fontWeight, FontWeight.w400);
    expect(
      find.text('+A newly worded invocation', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('A NEWLY WORDED SECTION'), findsOneWidget);
    expect(
      find.text('Before a newly worded refrain after', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('[[', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
