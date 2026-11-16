import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Which build is running: the commit, set by the deploy. 'dev' on your PC.
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

/// Where the lines go. In the app, the course API (POST /v1/logs);
/// in the tests, nowhere.
typedef LogSink = Future<void> Function(List<Map<String, Object?>> lines);

/// The pipe both loggers share: `log` and `analytics` write here.
final telemetry = Telemetry();

/// Lines wait in memory and leave in batches every few seconds.
/// Offline, they wait for the network.
class Telemetry {
  LogSink? sink; // main.dart sets it; until then, lines stay here
  final List<Map<String, Object?>> pending = [];

  /// Same id on every line of this run: to find one phone in the logs.
  final String run = Random().nextInt(1 << 30).toRadixString(36);

  /// The last thing the person did, e.g. 'forecast_opened island=corvo'.
  String? lastEvent;
  Timer? _timer;

  /// [kind] is 'log' (what the code did) or 'event' (what the person did).
  void add(String kind, String level, String message, Map context) {
    if (kDebugMode) debugPrint('[$kind $level] $message $context');
    pending.add({
      'kind': kind,
      'level': level,
      'message': message,
      ...context,
      'version': appVersion,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'run': run,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    if (pending.length > 200) pending.removeAt(0); // offline for too long
    if (sink == null) return; // tests: lines stay in [pending]
    _timer ??= Timer(const Duration(seconds: 5), flush);
  }

  /// Sends what is waiting. If it fails, the lines stay for the next time.
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    final send = sink;
    if (send == null || pending.isEmpty) return;
    final batch = pending.take(50).toList();
    try {
      await send(batch);
      pending.removeRange(0, batch.length);
      if (pending.isNotEmpty) _timer ??= Timer(Duration.zero, flush);
    } catch (_) {
      // no network: try again in 30 s, never log about the log
      _timer = Timer(const Duration(seconds: 30), flush);
    }
  }
}
