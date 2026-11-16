import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempo_acores/state/settings.dart';

void main() {
  test('the last email is still there after closing the app', () async {
    SharedPreferences.setMockInitialValues({}); // an empty phone
    final before = await Settings.load();

    await before.saveLastEmail('ana@example.com');
    final after = await Settings.load(); // the app opens again

    expect(after.lastEmail, 'ana@example.com');
  });
}
