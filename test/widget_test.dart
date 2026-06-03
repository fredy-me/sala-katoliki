import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salakatoliki/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows Sala Katoliki language selection', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    await tester.pumpAndSettle();

    expect(find.text('Choose Your Prayer Language'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('Kiswahili'), findsOneWidget);
  });

  testWidgets('opens offline prayer library and detail', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Endelea'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pray'));
    await tester.pumpAndSettle();

    expect(find.text('Tafuta sala...'), findsOneWidget);
    expect(find.text('Sala za Kawaida'), findsOneWidget);

    await tester.tap(find.text('Sala za Kawaida').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Baba Yetu').first);
    await tester.pumpAndSettle();

    expect(find.text('SALA ZA KAWAIDA'), findsOneWidget);
    expect(find.textContaining('Baba yetu uliye mbinguni'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
  });

  testWidgets('persists favorite prayers and shows favorites screen', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Endelea'));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Pray'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Sala za Kawaida').first);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Save favorite').first);
    await tester.pump(const Duration(milliseconds: 300));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('favorite_prayer_ids'),
      contains('our_father'),
    );

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Library'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Baba Yetu'), findsOneWidget);
    expect(find.text('1 sala zilizohifadhiwa'), findsOneWidget);

    await tester.tap(find.text('Vipendwa').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Remove favorite').first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      preferences.getStringList('favorite_prayer_ids'),
      isNot(contains('our_father')),
    );
    expect(find.text('Hakuna vipendwa bado'), findsOneWidget);
  });
}
