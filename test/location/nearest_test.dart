import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_acores/location/nearest.dart';

import '../fakes.dart';

void main() {
  test('São Miguel is about 160 km from Terceira', () {
    final pontaDelgada = positionAt(37.74, -25.67);

    final metres = distanceTo(pontaDelgada, terceira);

    expect(metres / 1000, closeTo(160, 15));
  });

  test('short distances in metres, long ones in kilometres', () {
    expect(formatDistance(850), '850 m');
    expect(formatDistance(16400), '16 km');
  });
}
