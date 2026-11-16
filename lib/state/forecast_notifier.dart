import 'package:flutter/foundation.dart';

import '../data/forecast_repository.dart';
import '../models/forecast.dart';
import '../models/island.dart';
import '../telemetry/app_log.dart';

/// The state of the islands screen. Knows the repository, not the widgets.
class ForecastNotifier extends ChangeNotifier {
  ForecastNotifier(this._repository); // injected, not created here

  final ForecastRepository _repository;

  bool isLoading = false;
  String? error;
  List<Island> islands = const [];

  Future<Forecast> forecastFor(String islandId) =>
      _repository.fetchForecast(islandId);

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners(); // the screen shows the spinner
    try {
      islands = await _repository.fetchIslands();
      log.info('islands loaded', {'count': islands.length});
    } catch (e) {
      error = '$e';
      log.warn('islands failed', {'error': error});
    } finally {
      isLoading = false;
      notifyListeners(); // the screen shows the islands or the error
    }
  }
}
