import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/forecast.dart';
import '../models/island.dart';
import '../state/forecast_notifier.dart';
import '../telemetry/analytics.dart';

/// What each island is called by the people who live there.
const _nicknames = {
  'sao-miguel': 'Ilha Verde',
  'santa-maria': 'Ilha Amarela',
  'terceira': 'Ilha Lilás',
  'graciosa': 'Ilha Branca',
  'sao-jorge': 'Ilha Castanha',
  'pico': 'Ilha Montanha',
  'faial': 'Ilha Azul',
  'flores': 'Ilha Rosa',
};

/// Five days of weather for one island.
class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key, required this.island});

  final Island island;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late Future<Forecast> _forecast;

  @override
  void initState() {
    super.initState();
    _load();
    analytics.event('forecast_opened', {'island': widget.island.id});
  }

  void _load() {
    _forecast = context.read<ForecastNotifier>().forecastFor(widget.island.id);
  }

  @override
  Widget build(BuildContext context) {
    final island = widget.island;
    return Scaffold(
      appBar: AppBar(title: Text(island.name)),
      body: ListView(
        children: [
          Image.network(
            island.imageUrl,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(height: 180),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _nicknames[island.id]!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          FutureBuilder(
            future: _forecast,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    const Text('Sem ligação'),
                    TextButton(
                      onPressed: () => setState(_load),
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                );
              }
              final forecast = snapshot.data;
              if (forecast == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [for (final day in forecast.days) _DayTile(day)],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile(this.day);

  final DayForecast day;

  @override
  Widget build(BuildContext context) {
    String deg(double t) => '${t.toStringAsFixed(1).replaceAll('.', ',')}°';
    final date = '${day.date.day}/${day.date.month}';
    return ListTile(
      leading: Icon(day.type.icon),
      title: Text('$date · ${day.type.description}'),
      subtitle: Text(
        'Mín ${deg(day.tMin)} · Máx ${deg(day.tMax)} · '
        'amplitude ${deg(day.amplitude)} · chuva ${day.rainChance}%',
      ),
    );
  }
}
