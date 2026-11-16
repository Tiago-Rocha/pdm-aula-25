import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_acores/state/forecast_notifier.dart';

import '../fakes.dart';

void main() {
  test('after load, the islands are there and there is no error', () async {
    final notifier = ForecastNotifier(FakeForecastRepository());

    await notifier.load();

    expect(notifier.islands.length, 3);
    expect(notifier.error, isNull);
    expect(notifier.isLoading, isFalse);
  });

  test('offline, load keeps the error for the screen', () async {
    final repository = FakeForecastRepository()..failing = true;
    final notifier = ForecastNotifier(repository);

    await notifier.load();

    expect(notifier.error, contains('Sem ligação'));
  });
}
