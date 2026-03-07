import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:tutorix/app/theme/theme_mode_provider.dart';

class LightSensorPage extends ConsumerStatefulWidget {
  const LightSensorPage({super.key});

  @override
  ConsumerState<LightSensorPage> createState() => _LightSensorPageState();
}

class _LightSensorPageState extends ConsumerState<LightSensorPage> {
  static const double _darkLuxThreshold = 25;
  static const double _brightLuxThreshold = 180;

  final Light _light = Light();
  StreamSubscription<dynamic>? _lightSubscription;
  Timer? _noDataTimer;

  double? _lux;
  bool _autoDarkMode = true;
  String? _lightError;
  String? _brightnessError;
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();

    _noDataTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_lux == null && _lightError == null) {
        setState(() {
          _lightError = 'No light sensor readings received on this device';
        });
      }
    });

    _lightSubscription = _light.lightSensorStream.listen(
      _onLightEvent,
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _lightError = 'Light sensor not available on this device';
        });
      },
    );
  }

  void _onLightEvent(dynamic event) {
    if (_manualMode) return;
    final nextLux = event is num ? event.toDouble() : double.tryParse(event.toString());
    if (!mounted) return;

    setState(() {
      _lux = nextLux;
      _lightError = null;
    });
    _noDataTimer?.cancel();

    if (_autoDarkMode && nextLux != null) {
      final shouldUseDark = nextLux <= _darkLuxThreshold;
      final isCurrentlyDark = ref.read(themeModeProvider) == ThemeMode.dark;
      if (shouldUseDark != isCurrentlyDark) {
        ref.read(themeModeProvider.notifier).toggleDarkMode(shouldUseDark);
      }
      _applyRecommendedBrightness(nextLux);
    }
  }

  Future<void> _applyRecommendedBrightness(double lux) async {
    final value = _recommendedBrightness(lux);
    try {
      await ScreenBrightness().setApplicationScreenBrightness(value);
      if (!mounted) return;
      if (_brightnessError != null) {
        setState(() => _brightnessError = null);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _brightnessError = 'Unable to control app brightness on this device';
      });
    }
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    _noDataTimer?.cancel();
    super.dispose();
  }

  String _brightnessHint(double? lux) {
    if (lux == null) return 'Waiting for light sensor data...';
    if (lux <= _darkLuxThreshold) return 'Low light: increase screen brightness.';
    if (lux >= _brightLuxThreshold) return 'Bright environment: lower brightness for comfort.';
    return 'Normal light: keep medium brightness.';
  }

  double _recommendedBrightness(double? lux) {
    if (lux == null) return 0.5;
    if (lux <= _darkLuxThreshold) return 0.9;
    if (lux >= _brightLuxThreshold) return 0.35;
    return 0.6;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recommendation = _recommendedBrightness(_lux);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Sensor'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto Dark Mode'),
              subtitle: const Text('Uses ambient light like a real phone behavior'),
              value: _autoDarkMode,
              onChanged: (value) {
                setState(() => _autoDarkMode = value);
                if (value && _lux != null) {
                  ref.read(themeModeProvider.notifier).toggleDarkMode(_lux! <= _darkLuxThreshold);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Manual Lux Mode'),
                  subtitle: const Text('Use if your phone has no light sensor'),
                  value: _manualMode,
                  onChanged: (value) {
                    setState(() => _manualMode = value);
                  },
                ),
                if (_manualMode)
                  Slider(
                    value: (_lux ?? 60).clamp(0, 300),
                    min: 0,
                    max: 300,
                    divisions: 60,
                    label: (_lux ?? 60).toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _lux = value;
                        _lightError = null;
                      });
                      if (_autoDarkMode) {
                        final shouldUseDark = value <= _darkLuxThreshold;
                        ref.read(themeModeProvider.notifier).toggleDarkMode(shouldUseDark);
                        _applyRecommendedBrightness(value);
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SensorCard(
            title: 'Ambient Light',
            line1: _lightError ?? (_lux == null ? '--' : '${_lux!.toStringAsFixed(1)} lx'),
            line2: _brightnessHint(_lux),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _SensorCard(
            title: 'Recommended Brightness',
            line1: '${(recommendation * 100).toStringAsFixed(0)}%',
            line2: _brightnessError ?? 'Based on current lux reading',
            isDark: isDark,
            meterValue: recommendation,
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.title,
    required this.line1,
    required this.line2,
    required this.isDark,
    this.meterValue,
  });

  final String title;
  final String line1;
  final String line2;
  final bool isDark;
  final double? meterValue;

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
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            line1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            line2,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          if (meterValue != null) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: meterValue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ],
      ),
    );
  }
}
