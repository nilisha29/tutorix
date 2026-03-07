import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';
import 'package:tutorix/app/theme/theme_mode_provider.dart';

class DarkModeSensorPage extends ConsumerStatefulWidget {
  const DarkModeSensorPage({super.key});

  @override
  ConsumerState<DarkModeSensorPage> createState() => _DarkModeSensorPageState();
}

class _DarkModeSensorPageState extends ConsumerState<DarkModeSensorPage> {
  final Light _light = Light();
  StreamSubscription<dynamic>? _lightSubscription;
  Timer? _noDataTimer;

  bool _autoMode = true;
  double _thresholdLux = 25;
  double? _lux;
  String? _sensorError;

  @override
  void initState() {
    super.initState();

    _noDataTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_lux == null && _sensorError == null) {
        setState(() {
          _sensorError = 'No light sensor data. Use manual slider to test dark mode.';
        });
      }
    });

    _lightSubscription = _light.lightSensorStream.listen(
      _onLightEvent,
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _sensorError = 'Light sensor not available on this device';
        });
      },
    );
  }

  void _onLightEvent(dynamic event) {
    final value = event is num ? event.toDouble() : double.tryParse(event.toString());
    if (!mounted) return;

    setState(() {
      _lux = value;
      _sensorError = null;
    });
    _noDataTimer?.cancel();

    if (_autoMode && value != null) {
      _applyThemeFromLux(value);
    }
  }

  void _applyThemeFromLux(double lux) {
    final shouldDark = lux <= _thresholdLux;
    ref.read(themeModeProvider.notifier).toggleDarkMode(shouldDark);
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    _noDataTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLux = _lux ?? _thresholdLux + 1;
    final predictedDark = currentLux <= _thresholdLux;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode Sensor'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Auto Dark Mode by Sensor'),
            subtitle: const Text('Turns dark mode on/off from ambient light'),
            value: _autoMode,
            onChanged: (v) {
              setState(() => _autoMode = v);
              if (v && _lux != null) {
                _applyThemeFromLux(_lux!);
              }
            },
          ),
          const SizedBox(height: 12),
          _panel(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sensorError ?? 'Current light: ${_lux?.toStringAsFixed(1) ?? '--'} lx',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  predictedDark ? 'Theme decision: DARK' : 'Theme decision: LIGHT',
                  style: TextStyle(
                    color: predictedDark ? Colors.teal : Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _panel(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Threshold: ${_thresholdLux.toStringAsFixed(0)} lx',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                Slider(
                  value: _thresholdLux,
                  min: 5,
                  max: 200,
                  divisions: 39,
                  label: _thresholdLux.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() => _thresholdLux = value);
                    if (_autoMode && _lux != null) {
                      _applyThemeFromLux(_lux!);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Manual test lux (for devices without light sensor)',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
                Slider(
                  value: currentLux.clamp(0, 300),
                  min: 0,
                  max: 300,
                  divisions: 60,
                  label: currentLux.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() => _lux = value);
                    if (_autoMode) {
                      _applyThemeFromLux(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: child,
    );
  }
}
