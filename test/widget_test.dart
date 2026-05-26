import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salakatoliki/app.dart';

void main() {
  testWidgets('shows Sala Katoliki onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    expect(find.text('Sala za kila siku za Kikatoliki'), findsOneWidget);
    expect(find.text('Endelea'), findsOneWidget);
  });
}
