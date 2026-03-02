import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tutorix/app/theme/theme_mode_provider.dart';

class SensorsPage extends ConsumerStatefulWidget {
  const SensorsPage({super.key});

  @override
  ConsumerState<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends ConsumerState<SensorsPage> {
  static const double _darkLuxThreshold = 25;

  final Light _light = Light();

  StreamSubscription<dynamic>? _lightSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  double? _lux;
  bool _autoDarkMode = true;
  AccelerometerEvent? _accelerometer;
  String? _lightError;

  @override
  void initState() {
    super.initState();

    _lightSubscription = _light.lightSensorStream.listen(
      _onLightEvent,
      onError: (Object _) {
        if (!mounted) return;
        setState(() {
          _lightError = 'Light sensor not available on this device';
        });
      },
    );

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!mounted) return;
      setState(() => _accelerometer = event);
    });
  }

  void _onLightEvent(dynamic event) {
    final double? nextLux = event is num ? event.toDouble() : double.tryParse(event.toString());
    if (!mounted) return;

    setState(() {
      _lux = nextLux;
      _lightError = null;
    });

    if (_autoDarkMode && nextLux != null) {
      final shouldUseDark = nextLux <= _darkLuxThreshold;
      final isCurrentlyDark = ref.read(themeModeProvider) == ThemeMode.dark;
      if (shouldUseDark != isCurrentlyDark) {
        ref.read(themeModeProvider.notifier).toggleDarkMode(shouldUseDark);
      }
    }
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  String _format(double? value) {
    if (value == null) return '--';
    return value.toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Sensors'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111111) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Auto Dark Mode (Light Sensor)',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                subtitle: Text(
                  'Dark mode turns on when light is low',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
                value: _autoDarkMode,
                onChanged: (value) {
                  setState(() => _autoDarkMode = value);
                  if (value && _lux != null) {
                    final shouldUseDark = _lux! <= _darkLuxThreshold;
                    ref.read(themeModeProvider.notifier).toggleDarkMode(shouldUseDark);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _SensorCard(
              title: 'Light Sensor',
              subtitle: 'Ambient light (lux)',
              x: _lightError != null ? _lightError! : '${_format(_lux)} lx',
              y: 'Threshold: ${_darkLuxThreshold.toStringAsFixed(0)} lx',
              z: _lux == null
                  ? 'Waiting for sensor data...'
                  : (_lux! <= _darkLuxThreshold ? 'Environment: Dark' : 'Environment: Bright'),
              isDark: isDark,
              icon: Icons.light_mode,
            ),
            const SizedBox(height: 12),
            _SensorCard(
              title: 'Accelerometer',
              subtitle: 'x, y, z (m/s²)',
              x: _format(_accelerometer?.x),
              y: _format(_accelerometer?.y),
              z: _format(_accelerometer?.z),
              isDark: isDark,
              icon: Icons.speed,
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.title,
    required this.subtitle,
    required this.x,
    required this.y,
    required this.z,
    required this.isDark,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String x;
  final String y;
  final String z;
  final bool isDark;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isDark ? Colors.white : Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          _AxisRow(label: '1', value: x, isDark: isDark),
          _AxisRow(label: '2', value: y, isDark: isDark),
          _AxisRow(label: '3', value: z, isDark: isDark),
        ],
      ),
    );
  }
}

class _AxisRow extends StatelessWidget {
  const _AxisRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
