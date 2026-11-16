import 'telemetry.dart';

export 'telemetry.dart' show appVersion, telemetry;

/// The log: what the code did, to find out why something broke.
/// `log.info(...)`, `log.warn(...)`, `log.error(...)`.
final log = AppLog();

class AppLog {
  void info(String message, [Map<String, Object?> context = const {}]) =>
      telemetry.add('log', 'info', message, context);

  void warn(String message, [Map<String, Object?> context = const {}]) =>
      telemetry.add('log', 'warn', message, context);

  void error(
    Object error,
    StackTrace? stack, [
    Map<String, Object?> context = const {},
  ]) {
    telemetry.add('log', 'error', '$error', {
      ...context,
      'error_type': error.runtimeType.toString(),
      'stack': stack?.toString(),
      // the breadcrumb: what the person had just done
      'last_event': telemetry.lastEvent,
    });
    telemetry.flush(); // errors do not wait
  }
}
