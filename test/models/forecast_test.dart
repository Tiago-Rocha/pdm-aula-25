import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_acores/models/forecast.dart';

import '../fakes.dart';

void main() {
  test('reads the weather, the rain and the wind', () {
    final day = DayForecast.fromJson(dayJson());

    expect(day.type, WeatherType.rain);
    expect(day.rainChance, 80);
    expect(day.windClass, 2);
  });

  test('reads every day of the forecast', () {
    final forecast = Forecast.fromJson({
      'location': 'Ponta Delgada',
      'days': [dayJson(date: '2026-11-16'), dayJson(date: '2026-11-17')],
    });

    expect(forecast.location, 'Ponta Delgada');
    expect(forecast.days.length, 2);
    expect(forecast.days.last.date, DateTime(2026, 11, 17));
  });
}
