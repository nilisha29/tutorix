


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/app/theme/theme_mode_provider.dart';
import 'package:tutorix/features/sensors/presentation/pages/dark_mode_sensor_page.dart';
import 'package:tutorix/features/sensors/presentation/pages/accelerometer_sensor_page.dart';
import 'package:tutorix/features/sensors/presentation/pages/sensors_hub_page.dart';
import 'package:tutorix/features/splash/presentation/pages/splash_page.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF5ED5C0),
          secondary: Color(0xFF5ED5C0),
          surface: Colors.black,
          onSurface: Colors.white,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onError: Colors.white,
          error: Color(0xFFFF6B6B),
        ),
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        cardColor: const Color(0xFF111111),
        dividerColor: Colors.white24,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111111),
          hintStyle: const TextStyle(color: Colors.white60),
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      routes: {
        '/sensors': (_) => const SensorsHubPage(),
        '/sensors/dark-mode': (_) => const DarkModeSensorPage(),
        '/sensors/accelerometer': (_) => const AccelerometerSensorPage(),
        '/sensors/motion': (_) => const AccelerometerSensorPage(),
      },
      home: const SplashPage(),
    );
  }
}