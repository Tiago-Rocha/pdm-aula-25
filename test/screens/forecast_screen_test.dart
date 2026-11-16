import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_acores/screens/forecast_screen.dart';

import '../fakes.dart';

void main() {
  testWidgets('São Miguel: the nickname and the days', (tester) async {
    await pumpScreen(tester, const ForecastScreen(island: saoMiguel));

    expect(find.text('Ilha Verde'), findsOneWidget);
    expect(find.textContaining('Chuva'), findsOneWidget);
  });
}
