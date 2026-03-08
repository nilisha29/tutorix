import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerSensorPage extends StatefulWidget {
  const AccelerometerSensorPage({super.key});

  @override
  State<AccelerometerSensorPage> createState() => _AccelerometerSensorPageState();
}

class _AccelerometerSensorPageState extends State<AccelerometerSensorPage> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _noDataTimer;

  AccelerometerEvent? _accelerometer;
  String? _sensorError;

  @override
  void initState() {
    super.initState();
    _noDataTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_accelerometer == null &&
          _sensorError == null) {
        setState(() {
          _sensorError = 'No accelerometer readings received on this device';
        });
      }
    });

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        _accelerometer = event;
        _sensorError = null;
      });
      _noDataTimer?.cancel();
    }, onError: (_) {
      if (!mounted) return;
      setState(() {
        _sensorError = 'Accelerometer not available on this device';
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _noDataTimer?.cancel();
    super.dispose();
  }

  String _format(double? value) => value == null ? '--' : value.toStringAsFixed(3);

  String _motionState() {
    final ax = _accelerometer?.x ?? 0;
    final ay = _accelerometer?.y ?? 0;
    final az = _accelerometer?.z ?? 0;
    final magnitude = (ax * ax + ay * ay + az * az);
    if (_accelerometer == null) return 'Waiting for motion data...';
    if (magnitude > 130) return 'High movement detected';
    if (magnitude > 90) return 'Phone in motion';
    return 'Phone mostly stable';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accelerometer Sensor'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_sensorError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _sensorError!,
                style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600),
              ),
            ),
          _SensorCard(
            title: 'Accelerometer (m/s²)',
            value1: _format(_accelerometer?.x),
            value2: _format(_accelerometer?.y),
            value3: _format(_accelerometer?.z),
            stateText: _motionState(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.title,
    required this.value1,
    required this.value2,
    required this.value3,
    required this.stateText,
    required this.isDark,
  });

  final String title;
  final String value1;
  final String value2;
  final String value3;
  final String stateText;
  final bool isDark;

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
          const SizedBox(height: 10),
          _row('X', value1, isDark),
          _row('Y', value2, isDark),
          _row('Z', value3, isDark),
          const SizedBox(height: 10),
          Text(
            stateText,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }
}
