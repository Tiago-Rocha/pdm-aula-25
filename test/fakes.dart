// Pieces for the tests: data that never changes, repositories that
// answer straight away, and a way to draw a screen with everything
// it needs around it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempo_acores/data/auth_repository.dart';
import 'package:tempo_acores/data/favorites_repository.dart';
import 'package:tempo_acores/data/forecast_repository.dart';
import 'package:tempo_acores/data/session_store.dart';
import 'package:tempo_acores/location/location_service.dart';
import 'package:tempo_acores/models/forecast.dart';
import 'package:tempo_acores/models/island.dart';
import 'package:tempo_acores/models/user.dart';
import 'package:tempo_acores/state/favorites_notifier.dart';
import 'package:tempo_acores/state/forecast_notifier.dart';
import 'package:tempo_acores/state/location_notifier.dart';
import 'package:tempo_acores/state/session_notifier.dart';
import 'package:tempo_acores/state/settings.dart';

const saoMiguel = Island(
  id: 'sao-miguel',
  name: 'São Miguel',
  imageUrl: '',
  latitude: 37.78,
  longitude: -25.50,
);
const terceira = Island(
  id: 'terceira',
  name: 'Terceira',
  imageUrl: '',
  latitude: 38.72,
  longitude: -27.22,
);
const corvo = Island(
  id: 'corvo',
  name: 'Corvo',
  imageUrl: '',
  latitude: 39.70,
  longitude: -31.10,
);
const islands = [saoMiguel, terceira, corvo];

/// A position, as the phone would give it.
Position positionAt(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime(2026, 11, 16),
  accuracy: 50,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

/// A day of forecast, as the API sends it.
Map<String, dynamic> dayJson({
  String date = '2026-11-16',
  double tMin = 14,
  double tMax = 19,
}) => {
  'date': date,
  'weatherType': {'category': 'rain'},
  'tMin': tMin,
  'tMax': tMax,
  'rainChance': 80,
  'wind': {'class': 2},
};

/// Answers straight away. [failing] makes it throw, like a phone offline.
class FakeForecastRepository implements ForecastRepository {
  bool failing = false;
  int islandCalls = 0; // how many times the islands were asked for

  @override
  Future<List<Island>> fetchIslands() async {
    islandCalls++;
    if (failing) throw Exception('Sem ligação');
    return islands;
  }

  @override
  Future<Forecast> fetchForecast(String islandId) async => Forecast(
    location: islandId,
    days: [DayForecast.fromJson(dayJson())],
  );
}

/// The favourites, in memory.
class FakeFavoritesRepository implements FavoritesRepository {
  final saved = <String>{};

  @override
  Future<Set<String>> fetchIslandIds() async => {...saved};

  @override
  Future<void> add(String islandId) async => saved.add(islandId);

  @override
  Future<void> remove(String islandId) async => saved.remove(islandId);
}

/// Login, storage and GPS are never called in these tests.
class _Unused {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeAuth extends _Unused implements AuthRepository {}

class _FakeStore extends _Unused implements SessionStore {}

class _FakeLocation extends _Unused implements LocationService {}

/// Draws [screen] with the notifiers the app gives it, already loaded,
/// and Ana logged in.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  FakeForecastRepository? forecast,
  FakeFavoritesRepository? favorites,
}) async {
  SharedPreferences.setMockInitialValues({});
  final settings = await Settings.load();
  final session = SessionNotifier(_FakeAuth(), _FakeStore())
    ..isRestoring = false
    ..session = const Session(
      user: AppUser(id: '1', email: 'ana@example.com', name: 'Ana'),
      accessToken: 'a',
      refreshToken: 'r',
    );
  final islandsState = ForecastNotifier(
    forecast ?? FakeForecastRepository(),
  );
  await islandsState.load();
  final favoritesState = FavoritesNotifier(
    favorites ?? FakeFavoritesRepository(),
  );
  await favoritesState.load();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: islandsState),
        ChangeNotifierProvider.value(value: favoritesState),
        ChangeNotifierProvider(create: (_) => LocationNotifier(_FakeLocation())),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}
