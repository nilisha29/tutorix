import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:tutorix/app/theme/theme_mode_provider.dart';

final lightLuxProvider = StateProvider<double?>((ref) => null);
final lightSensorErrorProvider = StateProvider<String?>((ref) => null);
final lightSensorCoveredProvider = StateProvider<bool>((ref) => false);
final lightAutoDarkModeProvider = StateProvider<bool>((ref) => true);
final lightManualModeProvider = StateProvider<bool>((ref) => false);

class LightSensorPage extends ConsumerStatefulWidget {
  const LightSensorPage({super.key});

  @override
  ConsumerState<LightSensorPage> createState() => _LightSensorPageState();
}

class _LightSensorPageState extends ConsumerState<LightSensorPage> {
  static const double _darkLuxThreshold = 50;
  static const double _blockedLuxThreshold = 1.5;
  static const double _brightLuxThreshold = 180;

  final Light _light = Light();
  StreamSubscription<dynamic>? _lightSubscription;
  Timer? _noDataTimer;

  String? _brightnessError;

  @override
  void initState() {
    super.initState();

    _noDataTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      final lux = ref.read(lightLuxProvider);
      final err = ref.read(lightSensorErrorProvider);
      if (lux == null && err == null) {
        ref.read(lightSensorErrorProvider.notifier).state =
            'No light sensor readings received on this device';
      }
    });

    _lightSubscription = _light.lightSensorStream.listen(
      _onLightEvent,
      onError: (_) {
        if (!mounted) return;
        ref.read(lightSensorErrorProvider.notifier).state =
            'Light sensor not available on this device';
      },
    );
  }

  void _onLightEvent(dynamic event) {
    if (ref.read(lightManualModeProvider)) return;

    final nextLux = event is num ? event.toDouble() : double.tryParse(event.toString());
    if (!mounted) return;

    ref.read(lightLuxProvider.notifier).state = nextLux;
    ref.read(lightSensorErrorProvider.notifier).state = null;

    final isCovered = (nextLux ?? 9999) <= _blockedLuxThreshold;
    ref.read(lightSensorCoveredProvider.notifier).state = isCovered;

    _noDataTimer?.cancel();

    if (ref.read(lightAutoDarkModeProvider) && nextLux != null) {
      final shouldUseDark = nextLux <= _darkLuxThreshold;
      final targetMode = shouldUseDark ? ThemeMode.dark : ThemeMode.light;
      if (ref.read(themeModeProvider) != targetMode) {
        ref.read(themeModeProvider.notifier).setThemeMode(targetMode);
      }
      _applyRecommendedBrightness(nextLux);
    }
  }

  Future<void> _applyRecommendedBrightness(double lux) async {
    final value = _recommendedBrightness(lux);
    try {
      await ScreenBrightness().setApplicationScreenBrightness(value);
      if (!mounted) return;
      if (_brightnessError != null) setState(() => _brightnessError = null);
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
    final lux = ref.watch(lightLuxProvider);
    final lightError = ref.watch(lightSensorErrorProvider);
    final isCovered = ref.watch(lightSensorCoveredProvider);
    final autoDarkMode = ref.watch(lightAutoDarkModeProvider);
    final manualMode = ref.watch(lightManualModeProvider);
    final recommendation = _recommendedBrightness(lux);

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
              subtitle: const Text('Switches theme based on room light level'),
              value: autoDarkMode,
              onChanged: (value) {
                ref.read(lightAutoDarkModeProvider.notifier).state = value;
                final currentLux = ref.read(lightLuxProvider);
                if (value && currentLux != null) {
                  final shouldUseDark = currentLux <= _darkLuxThreshold;
                  final targetMode = shouldUseDark ? ThemeMode.dark : ThemeMode.light;
                  ref.read(themeModeProvider.notifier).setThemeMode(targetMode);
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
                  value: manualMode,
                  onChanged: (value) {
                    ref.read(lightManualModeProvider.notifier).state = value;
                  },
                ),
                if (manualMode)
                  Slider(
                    value: (lux ?? 60).clamp(0, 300),
                    min: 0,
                    max: 300,
                    divisions: 60,
                    label: (lux ?? 60).toStringAsFixed(0),
                    onChanged: (value) {
                      ref.read(lightLuxProvider.notifier).state = value;
                      ref.read(lightSensorErrorProvider.notifier).state = null;
                      final covered = value <= _blockedLuxThreshold;
                      ref.read(lightSensorCoveredProvider.notifier).state = covered;

                      if (autoDarkMode) {
                        final shouldUseDark = value <= _darkLuxThreshold;
                        final targetMode = shouldUseDark ? ThemeMode.dark : ThemeMode.light;
                        ref.read(themeModeProvider.notifier).setThemeMode(targetMode);
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
            line1: lightError ?? (lux == null ? '--' : '${lux.toStringAsFixed(1)} lx'),
            line2: isCovered
                ? 'Sensor is covered/blocked: treating as dark environment.'
                : _brightnessHint(lux),
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
