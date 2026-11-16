import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_acores/telemetry/analytics.dart';
import 'package:tempo_acores/telemetry/app_log.dart';

void main() {
  setUp(() => telemetry.pending.clear());

  test('an event and a log line leave by the same pipe, marked apart', () {
    analytics.event('forecast_opened', {'island': 'corvo'});
    log.info('islands loaded', {'count': 9});

    final [event, line] = telemetry.pending;
    expect(event['kind'], 'event');
    expect(event['message'], 'forecast_opened');
    expect(line['kind'], 'log');
  });

  test('an error says what the person had just done', () {
    analytics.event('forecast_opened', {'island': 'corvo'});
    log.error(StateError('boom'), StackTrace.empty);

    final error = telemetry.pending.last;
    expect(error['level'], 'error');
    expect(error['last_event'], 'forecast_opened island=corvo');
  });
}
