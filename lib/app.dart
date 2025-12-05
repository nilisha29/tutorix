import 'package:flutter/material.dart';
import 'package:tutorix/screens/splash_screen.dart';
import 'package:tutorix/screens/welcome_page.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

