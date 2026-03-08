import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/app/theme/theme_mode_provider.dart';

class DarkModeSensorPage extends ConsumerStatefulWidget {
  const DarkModeSensorPage({super.key});

  @override
  ConsumerState<DarkModeSensorPage> createState() => _DarkModeSensorPageState();
}

class _DarkModeSensorPageState extends ConsumerState<DarkModeSensorPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode Sensor'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _panel(
            isDark: isDark,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Dark Mode'),
              subtitle: const Text('When enabled, app stays in dark mode'),
              value: enabled,
              onChanged: (value) async {
                await ref.read(themeModeProvider.notifier).toggleDarkMode(value);
              },
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
