import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_acores/state/favorites_notifier.dart';

import '../fakes.dart';

void main() {
  test('load brings the favourites saved in the account', () async {
    final repository = FakeFavoritesRepository()..saved.add('corvo');
    final notifier = FavoritesNotifier(repository);

    await notifier.load();

    expect(notifier.isFavorite('corvo'), isTrue);
    expect(notifier.isFavorite('terceira'), isFalse);
  });

  test('toggle saves the favourite in the account', () async {
    final repository = FakeFavoritesRepository();
    final notifier = FavoritesNotifier(repository);

    await notifier.toggle('terceira');

    expect(repository.saved, contains('terceira'));
  });
}
