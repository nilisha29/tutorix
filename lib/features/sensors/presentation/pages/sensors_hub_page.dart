import 'package:flutter/material.dart';
import 'package:tutorix/features/sensors/presentation/pages/dark_mode_sensor_page.dart';
import 'package:tutorix/features/sensors/presentation/pages/light_sensor_page.dart';
import 'package:tutorix/features/sensors/presentation/pages/motion_sensor_page.dart';

class SensorsHubPage extends StatelessWidget {
  const SensorsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SensorNavTile(
            icon: Icons.light_mode,
            title: 'Light Sensor',
            subtitle: 'Ambient light + brightness recommendation',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LightSensorPage()),
            ),
          ),
          _SensorNavTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode Sensor',
            subtitle: 'Auto dark mode based on light threshold',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DarkModeSensorPage()),
            ),
          ),
          _SensorNavTile(
            icon: Icons.speed,
            title: 'Motion Sensors',
            subtitle: 'Accelerometer + gyroscope readings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MotionSensorPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorNavTile extends StatelessWidget {
  const _SensorNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
