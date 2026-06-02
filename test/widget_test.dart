import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salakatoliki/app.dart';

void main() {
  testWidgets('shows Sala Katoliki onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    expect(find.text('Sala za kila siku za Kikatoliki'), findsOneWidget);
    expect(find.text('Endelea'), findsOneWidget);
  });

  testWidgets('opens offline prayer library and detail', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    await tester.tap(find.text('Ruka'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pray'));
    await tester.pumpAndSettle();

    expect(find.text('Tafuta sala...'), findsOneWidget);
    expect(find.text('Baba Yetu'), findsOneWidget);

    await tester.tap(find.text('Baba Yetu').first);
    await tester.pumpAndSettle();

    expect(find.text('SALA ZA ROZARI'), findsOneWidget);
    expect(find.textContaining('Baba yetu uliye mbinguni'), findsOneWidget);
  });
}
