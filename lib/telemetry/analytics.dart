import 'telemetry.dart';

/// Analytics: what the person did, to learn how the app is used.
/// One name per action, in the past tense: `analytics.event(...)`.
final analytics = Analytics();

class Analytics {
  void event(String name, [Map<String, Object?> properties = const {}]) {
    telemetry.add('event', 'info', name, properties);
    final detail = properties.entries.map((p) => '${p.key}=${p.value}');
    telemetry.lastEvent = [name, ...detail].join(' ');
  }
}
