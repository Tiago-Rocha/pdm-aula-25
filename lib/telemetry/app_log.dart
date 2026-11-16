import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Which build is running: the commit, set by the deploy. 'dev' on your PC.
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

/// Where the lines go. In the app, the course API (POST /v1/logs);
/// in the tests, nowhere.
typedef LogSink = Future<void> Function(List<Map<String, Object?>> lines);

/// One log for the whole app: `log.info(...)`, `log.error(...)`.
final log = AppLog();

/// Log lines with context: what happened, where, to whom, in which version.
/// Lines wait in memory and leave in batches every few seconds. Offline,
/// they wait for the network.
class AppLog {
  LogSink? sink; // main.dart sets it; until then, lines stay here
  final List<Map<String, Object?>> pending = [];

  /// Same id on every line of this run: to find one phone in the logs.
  final String run = Random().nextInt(1 << 30).toRadixString(36);
  Timer? _timer;

  void info(String message, [Map<String, Object?> context = const {}]) =>
      _add('info', message, context);

  void warn(String message, [Map<String, Object?> context = const {}]) =>
      _add('warn', message, context);

  void error(
    Object error,
    StackTrace? stack, [
    Map<String, Object?> context = const {},
  ]) {
    _add('error', '$error', {
      ...context,
      'error_type': error.runtimeType.toString(),
      'stack': stack?.toString(),
    });
    flush(); // errors do not wait
  }

  void _add(String level, String message, Map<String, Object?> context) {
    if (kDebugMode) debugPrint('[$level] $message $context');
    pending.add({
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
