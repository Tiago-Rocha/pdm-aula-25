import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_acores/screens/islands_screen.dart';

import '../fakes.dart';

void main() {
  testWidgets('says hello and shows the islands', (tester) async {
    await pumpScreen(tester, const IslandsScreen());

    expect(find.text('Olá, Ana'), findsOneWidget);
    expect(find.text('São Miguel'), findsOneWidget);
    expect(find.text('Corvo'), findsOneWidget);
  });

  testWidgets('offline, shows the error and a button', (tester) async {
    final repository = FakeForecastRepository()..failing = true;

    await pumpScreen(tester, const IslandsScreen(), forecast: repository);

    expect(find.textContaining('Sem ligação'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });
}
